//
//  FirebaseEventMapper.swift
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
/// Custom event names are supported if not found in the mapping.
///
/// Firebase SDK Reference:
/// - https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Constants
struct FirebaseEventMapper {
    
    /// Maps event_* keys to Firebase Analytics event constants.
    /// Example: `event_purchase` → `"purchase"`
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
        "event_remove_from_cart": AnalyticsEventRemoveFromCart,
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
    /// - Parameter eventName: The Tealium event name (e.g., "event_purchase" or custom "my_event")
    /// - Returns: The Firebase Analytics event constant, or the original name for custom events
    static func map(_ eventName: String) -> String {
        return mapping[eventName.lowercased()] ?? eventName
    }
    
}
