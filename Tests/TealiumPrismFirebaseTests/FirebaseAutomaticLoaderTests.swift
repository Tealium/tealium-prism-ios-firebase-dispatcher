//
//  FirebaseAutomaticLoaderTests.swift
//  TealiumPrismFirebaseTests
//
//  Created by Sebastian Krajna on 21/09/2026.
//  Copyright © 2026 Tealium. All rights reserved.
//

import XCTest

@testable import TealiumPrismCore
@testable import TealiumPrismFirebase

/// Verifies that `FirebaseDispatcher` auto-registers as a default module at process start —
/// via the ObjC `+load` -> `FirebaseAutomaticLoader.setup()` chain wired in `TealiumPrismFirebaseObjC` —
/// the same way `Lifecycle` does in core, without any `config.addModule(...)` call.
final class FirebaseAutomaticLoaderTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // `Modules.addDefaultModule` (triggered by `+load` at process start) hops onto
        // `TealiumQueue.worker`, a serial queue. Blocking on it here guarantees the
        // registration has completed before we inspect `ModuleRegistry`.
        TealiumQueue.worker.dispatchQueue.sync {}
    }

    private var registeredFirebaseFactory: (any ModuleFactory)? {
        ModuleRegistry.shared.defaultModules.first { $0.moduleType == Modules.Types.firebaseDispatcher }
    }

    func test_firebaseDispatcher_is_registered_as_a_default_module() {
        XCTAssertNotNil(registeredFirebaseFactory, "FirebaseDispatcher must auto-register via FirebaseAutomaticLoader.")
    }

    func test_firebaseDispatcher_default_module_has_no_enforced_settings() {
        // Empty enforced settings is what keeps the module from auto-enabling on its own:
        // it only activates once SDKSettings explicitly provide a ModuleSettings entry for it.
        XCTAssertTrue(registeredFirebaseFactory?.getEnforcedSettings().isEmpty ?? false)
    }
}

/// Verifies the settings-driven enablement mechanism `ModuleManager` relies on to create
/// `FirebaseDispatcher` purely from `SDKSettings`, without the module ever being passed to
/// `TealiumConfig.addModule(...)`. The full path through a real `ModuleManager` is covered
/// end-to-end by `FirebaseAutomaticLoaderEndToEndTests` below.
final class FirebaseModuleSettingsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        TealiumQueue.worker.dispatchQueue.sync {}
    }

    /// A config that never registers Firebase via `addModule`, with default modules merged in
    /// exactly like `TealiumImpl.init` does for every real `Tealium` instance at startup.
    private func configWithMergedDefaults() -> TealiumConfig {
        var config = TealiumConfig(account: "test", profile: "test", environment: "dev")
        TealiumImpl.addMandatoryAndRemoveDuplicateModules(from: &config)
        return config
    }

    func test_firebaseDispatcher_factory_is_merged_in_without_addModule() {
        let config = configWithMergedDefaults()

        XCTAssertTrue(config.modules.contains { $0.moduleType == Modules.Types.firebaseDispatcher })
    }

    func test_firebaseDispatcher_produces_no_enforced_SDKSettings_entry() {
        let config = configWithMergedDefaults()
        let enforcedSettings = SDKSettings(config.getEnforcedSDKSettings())

        XCTAssertNil(enforcedSettings.modules[Modules.Types.firebaseDispatcher],
                     "With no enforced settings, Firebase must not self-enable without explicit SDKSettings.")
    }

    func test_firebaseDispatcher_would_be_enabled_once_SDKSettings_mentions_it() {
        let config = configWithMergedDefaults()
        guard let factory = config.modules.first(where: { $0.moduleType == Modules.Types.firebaseDispatcher }) else {
            return XCTFail("FirebaseDispatcher factory missing from merged config.")
        }
        let moduleSettings = ModuleSettings(moduleType: Modules.Types.firebaseDispatcher)

        XCTAssertTrue(factory.shouldBeEnabled(by: moduleSettings))
    }
}

/// End-to-end proof, through the real public `Tealium.create(config:)` entry point, that
/// `FirebaseDispatcher` gets created purely from `SDKSettings` — no `config.addModule(...)` call
/// anywhere below — mirroring `../tealium-prism-swift/Example/Tests/EndToEnd/Tealium+SettingsTests.swift`.
final class FirebaseAutomaticLoaderEndToEndTests: XCTestCase {

    /// Upper bound for `Tealium.create` reporting that an instance finished initializing.
    /// Deliberately much larger than `XCTestCase.longTimeout`: instance creation is real work
    /// (SQLite schema setup, settings merge, construction of every enabled module) and on a cold,
    /// contended CI iOS simulator it has taken well over five seconds. It is only ever waited out
    /// in full when initialization genuinely never completes.
    private static let startupTimeout: TimeInterval = 30

    // No `setUp` blocking on `TealiumQueue.worker` here, unlike the classes above: those read
    // `ModuleRegistry` directly from the test thread, while this class goes through
    // `Tealium.create`, which enqueues onto the same serial worker queue as the `+load`-time
    // `Modules.addDefaultModule` and therefore already observes the registration by FIFO order.
    // Blocking the main thread on that queue would also make one slow instance cascade into the
    // next test's setUp.

    /// A config that never registers Firebase via `addModule`. When `settingsFile` is provided,
    /// it is resolved from `Bundle.module` (this target's SPM resource bundle) instead of the
    /// `Bundle.main` default, and `databaseName = nil` switches to an in-memory database so
    /// repeated E2E runs never collide on a shared SQLite file path.
    private func makeConfig(settingsFile: String?, account: String) -> TealiumConfig {
        var config = TealiumConfig(account: account, profile: "test", environment: "dev", settingsFile: settingsFile)
        config.bundle = .module
        config.databaseName = nil
        return config
    }

    /// Creates the instance and returns only once the SDK reports initialization finished.
    ///
    /// `Tealium.create` builds `TealiumImpl` asynchronously on `TealiumQueue.worker`, and
    /// `ModuleProxy.getModule` stays silent until that construction has emitted. Waiting on the
    /// `create` completion — the public signal for "this instance is ready" — keeps start-up
    /// latency out of the module-query budget below, so a slow machine can no longer be
    /// misreported as "the module was not created".
    private func createTealium(settingsFile: String?, account: String) -> Tealium {
        let initialized = expectation(description: "Tealium initialized")
        let config = makeConfig(settingsFile: settingsFile, account: account)
        let teal = Tealium.create(config: config) { result in
            if case .failure(let error) = result {
                XCTFail("Tealium failed to initialize: \(error)")
            }
            initialized.fulfill()
        }
        wait(for: [initialized], timeout: Self.startupTimeout)
        return teal
    }

    /// Uses `Tealium.createModuleProxy(for:)` — the same public "get me a module" entry point a real
    /// module wrapper would use (and the direct equivalent of the Android sibling's
    /// `createModuleProxy(FirebaseDispatcher::class.java).getModule { }`) — to check whether
    /// `FirebaseDispatcher` was created. `Never` is used as the proxy's `Failure` type since
    /// `getModule` never routes through it.
    private func firebaseModuleIsPresent(in teal: Tealium) -> Bool {
        var isPresent = false
        let checked = expectation(description: "Module checked")
        let moduleProxy: ModuleProxy<FirebaseDispatcher, Never> = teal.createModuleProxy()
        moduleProxy.getModule { module in
            isPresent = module != nil
            checked.fulfill()
        }
        wait(for: [checked], timeout: Self.longTimeout)
        return isPresent
    }

    func test_firebaseDispatcher_is_enabled_by_local_settings_without_addModule() {
        let teal = createTealium(settingsFile: "firebase_default_module_settings", account: "e2e-firebase-enabled")

        XCTAssertTrue(firebaseModuleIsPresent(in: teal))
    }

    func test_firebaseDispatcher_stays_disabled_without_matching_settings() {
        let teal = createTealium(settingsFile: nil, account: "e2e-firebase-disabled")

        XCTAssertFalse(firebaseModuleIsPresent(in: teal))
    }
}
