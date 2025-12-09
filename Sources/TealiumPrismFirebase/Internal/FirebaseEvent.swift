//
//  FirebaseEvent.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 5/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import FirebaseAnalytics

// MARK: - Firebase Event Mappings

/// Maps Tealium event names to Firebase Analytics predefined event constants.
///
/// Custom event names are also supported by Firebase - if an event name is not found
/// in the mapping, the original name is returned and will be sent as a custom event.
///
/// Firebase SDK Reference:
/// - Events: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Constants
/// - logEvent: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#/c:objc(cs)FIRAnalytics(cm)logEventWithName:parameters:
struct FirebaseEvent {
    
    /// Maps event_* keys to Firebase Analytics event constants.
    ///
    /// Usage: Send `event_purchase` in payload → mapped to `AnalyticsEventPurchase`
    static let mapping: [String: String] = [
        "event_ad_impression": AnalyticsEventAdImpression,
        "event_add_payment_info": AnalyticsEventAddPaymentInfo,
        "event_add_shipping_info": AnalyticsEventAddShippingInfo,
        "event_add_to_cart": AnalyticsEventAddToCart,
        "event_add_to_wishlist": AnalyticsEventAddToWishlist,
        "event_app_open": AnalyticsEventAppOpen,
        "event_begin_checkout": AnalyticsEventBeginCheckout,
        "event_campaign_details": AnalyticsEventCampaignDetails,
        "event_earn_virtual_currency": AnalyticsEventEarnVirtualCurrency,
        "event_generate_lead": AnalyticsEventGenerateLead,
        "event_join_group": AnalyticsEventJoinGroup,
        "event_level_end": AnalyticsEventLevelEnd,
        "event_level_start": AnalyticsEventLevelStart,
        "event_level_up": AnalyticsEventLevelUp,
        "event_login": AnalyticsEventLogin,
        "event_post_score": AnalyticsEventPostScore,
        "event_purchase": AnalyticsEventPurchase,
        "event_refund": AnalyticsEventRefund,
        "event_remove_cart": AnalyticsEventRemoveFromCart,
        "event_screen_view": AnalyticsEventScreenView,
        "event_search": AnalyticsEventSearch,
        "event_select_content": AnalyticsEventSelectContent,
        "event_select_item": AnalyticsEventSelectItem,
        "event_select_promotion": AnalyticsEventSelectPromotion,
        "event_share": AnalyticsEventShare,
        "event_signup": AnalyticsEventSignUp,
        "event_spend_virtual_currency": AnalyticsEventSpendVirtualCurrency,
        "event_tutorial_begin": AnalyticsEventTutorialBegin,
        "event_tutorial_complete": AnalyticsEventTutorialComplete,
        "event_unlock_achievement": AnalyticsEventUnlockAchievement,
        "event_view_cart": AnalyticsEventViewCart,
        "event_view_item": AnalyticsEventViewItem,
        "event_view_item_list": AnalyticsEventViewItemList,
        "event_view_promotion": AnalyticsEventViewPromotion,
        "event_view_search_results": AnalyticsEventViewSearchResults
    ]
    
    /// Returns the mapped Firebase event name, or the original name if no mapping exists.
    ///
    /// If no mapping is found, the original name is returned unchanged.
    /// Firebase allows custom event names as long as they follow these rules:
    /// - Max 40 characters
    /// - Must start with an alphabetic character
    /// - Only alphanumeric characters and underscores allowed
    /// - Reserved prefixes (`firebase_`, `google_`, `ga_`) cannot be used
    /// - Case-sensitive (two events differing only in case are distinct)
    ///
    /// - Parameter eventName: The Tealium event name (e.g., "event_purchase" or custom "my_event")
    /// - Returns: The Firebase Analytics event constant, or the original name for custom events
    static func map(_ eventName: String) -> String {
        return mapping[eventName] ?? eventName
    }
    
}
