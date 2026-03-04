//
//  ButtonViews.swift
//  Example
//
//  Created by Sebastian Krajna on 16/01/2026.
//  Copyright © 2026 Tealium, Inc. All rights reserved.
//

import SwiftUI

public struct TealiumButton: View {
    var view: AnyView
    var action: () -> Void
    
    public init(view: AnyView,
         _ action: @escaping () -> Void) {
        self.view = view
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) { view }
    }
}

public struct TealiumTextButton: View {
    var title: String
    var action: () -> Void
    
    public init(title: String,
                _ action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    var buttonView: some View {
        Text(title).tealiumButtonUI()
    }
    
    public var body: some View {
        TealiumButton(view: AnyView(buttonView)) {
            action()
        }
    }
}

public extension Color {
    static let tealBlue = Color(red: 0.0, green: 0.49, blue: 0.76)
}

public extension View {

    func tealiumButtonUI() -> some View {
        self.frame(width: 200.0)
            .padding()
            .background(Color.tealBlue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(radius: 8)
    }
}
