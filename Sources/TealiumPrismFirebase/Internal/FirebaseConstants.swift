//
//  FirebaseConstants.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 5/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation

/// Module-level constants for the Firebase Dispatcher.
///
/// Payload key strings for the command schema are defined in `FirebaseDestination`
/// and accessed via `FirebaseDestination.*.path`.
enum FirebaseConstants {

    // MARK: - Module Metadata

    static let version = "1.0.0"
    static let moduleType = "FirebaseDispatcher"

    /// The key used to identify the command to execute in the mapped payload.
    static let commandName = "command_name"

    // MARK: - Event Parameter Keys

    /// Tealium payload keys for Firebase event parameters.
    /// Used by both `FirebaseEventParameter.value` and `FirebaseParameterMapper.mapping`.
    enum EventParamKey {
        static let achievementId = "param_achievement_id"
        static let adFormat = "param_ad_format"
        static let adNetworkClickId = "param_ad_network_click_id"
        static let adPlatform = "param_ad_platform"
        static let adSource = "param_ad_source"
        static let adUnitName = "param_ad_unit_name"
        static let affiliation = "param_affiliation"
        static let campaign = "param_campaign"
        static let campaignId = "param_campaign_id"
        static let character = "param_character"
        static let content = "param_content"
        static let contentType = "param_content_type"
        static let coupon = "param_coupon"
        static let cp1 = "param_cp1"
        static let creativeFormat = "param_creative_format"
        static let creativeName = "param_creative_name"
        static let creativeSlot = "param_creative_slot"
        static let currency = "param_currency"
        static let destination = "param_destination"
        static let discount = "param_discount"
        static let endDate = "param_end_date"
        static let extendSession = "param_extend_session"
        static let flightNumber = "param_flight_number"
        static let groupId = "param_group_id"
        static let index = "param_index"
        static let itemBrand = "param_item_brand"
        static let itemCategory = "param_item_category"
        static let itemCategory2 = "param_item_category2"
        static let itemCategory3 = "param_item_category3"
        static let itemCategory4 = "param_item_category4"
        static let itemCategory5 = "param_item_category5"
        static let itemId = "param_item_id"
        static let itemListId = "param_item_list_id"
        static let itemListName = "param_item_list_name"
        static let itemName = "param_item_name"
        static let itemVariant = "param_item_variant"
        static let items = "param_items"
        static let level = "param_level"
        static let levelName = "param_level_name"
        static let location = "param_location"
        static let locationId = "param_location_id"
        static let marketingTactic = "param_marketing_tactic"
        static let medium = "param_medium"
        static let method = "param_method"
        static let numberOfNights = "param_number_nights"
        static let numberOfPassengers = "param_number_pax"
        static let numberOfRooms = "param_number_rooms"
        static let origin = "param_origin"
        static let paymentType = "param_payment_type"
        static let price = "param_price"
        static let promotionId = "param_promotion_id"
        static let promotionName = "param_promotion_name"
        static let quantity = "param_quantity"
        static let score = "param_score"
        static let screenClass = "param_screen_class"
        static let screenName = "param_screen_name"
        static let searchTerm = "param_search_term"
        static let shipping = "param_shipping"
        static let shippingTier = "param_shipping_tier"
        static let source = "param_source"
        static let sourcePlatform = "param_source_platform"
        static let startDate = "param_start_date"
        static let success = "param_success"
        static let tax = "param_tax"
        static let term = "param_term"
        static let transactionId = "param_transaction_id"
        static let travelClass = "param_travel_class"
        static let userAllowAdPersonalizationSignals = "param_user_allow_ad_personalization_signals"
        static let userSignupMethod = "param_user_signup_method"
        static let value = "param_value"
        static let virtualCurrencyName = "param_virtual_currency_name"
    }

    // MARK: - Item Parameter Keys

    /// Tealium payload keys for Firebase item parameters.
    /// Used by both `FirebaseItemParameter.value` and `FirebaseItemParameterMapper.mapping`.
    enum ItemParamKey {
        static let itemId = "param_items_item_id"
        static let itemName = "param_items_item_name"
        static let itemBrand = "param_items_item_brand"
        static let itemCategory = "param_items_item_category"
        static let itemCategory2 = "param_items_item_category2"
        static let itemCategory3 = "param_items_item_category3"
        static let itemCategory4 = "param_items_item_category4"
        static let itemCategory5 = "param_items_item_category5"
        static let itemVariant = "param_items_item_variant"
        static let itemListId = "param_items_item_list_id"
        static let itemListName = "param_items_item_list_name"
        static let index = "param_items_index"
        static let price = "param_items_price"
        static let quantity = "param_items_quantity"
        static let discount = "param_items_discount"
        static let affiliation = "param_items_affiliation"
        static let coupon = "param_items_coupon"
        static let locationId = "param_items_location_id"
        static let promotionId = "param_items_promotion_id"
        static let promotionName = "param_items_promotion_name"
        static let creativeName = "param_items_creative_name"
        static let creativeSlot = "param_items_creative_slot"
    }
}
