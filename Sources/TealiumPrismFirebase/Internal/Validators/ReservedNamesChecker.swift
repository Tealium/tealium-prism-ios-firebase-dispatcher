//
//  ReservedNamesChecker.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 10/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation

/// Utility for checking if names are in Firebase reserved lists.
struct ReservedNamesChecker {
    
    // MARK: - Constants
    
    static let reservedUserPropertyNames: Set<String> = [
        "first_open_time",
        "last_deep_link_referrer",
        "user_id"
    ]
    
    static let reservedEventNames: Set<String> = [
        "ad_activeview",
        "ad_click",
        "ad_exposure",
        "ad_query",
        "ad_reward",
        "adunit_exposure",
        "app_clear_data",
        "app_exception",
        "app_remove",
        "app_store_refund",
        "app_store_subscription_cancel",
        "app_store_subscription_convert",
        "app_store_subscription_renew",
        "app_update",
        "app_upgrade",
        "dynamic_link_app_open",
        "dynamic_link_app_update",
        "dynamic_link_first_open",
        "error",
        "firebase_campaign",
        "first_open",
        "first_visit",
        "notification_dismiss",
        "notification_foreground",
        "notification_open",
        "notification_receive",
        "os_update",
        "session_start",
        "session_start_with_rollout",
        "user_engagement"
    ]
    
    /// Events that support the `items` parameter according to Firebase Analytics documentation.
    static let eventsWithItems: Set<String> = [
        "add_payment_info",
        "add_shipping_info",
        "add_to_cart",
        "add_to_wishlist",
        "begin_checkout",
        "purchase",
        "refund",
        "remove_from_cart",
        "select_item",
        "select_promotion",
        "view_cart",
        "view_item",
        "view_item_list",
        "view_promotion"
    ]
    
    // MARK: - Methods
    
    static func isReservedEventName(_ name: String) -> Bool {
        return reservedEventNames.contains(name.lowercased())
    }
    
    static func isReservedUserPropertyName(_ name: String) -> Bool {
        return reservedUserPropertyNames.contains(name.lowercased())
    }
    
    /// Checks if the event name supports the `items` parameter.
    static func supportsItemsParameter(_ eventName: String) -> Bool {
        return eventsWithItems.contains(eventName)
    }
}

