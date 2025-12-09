//
//  FirebaseParameter.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 5/12/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import FirebaseAnalytics

// MARK: - Firebase Parameter Mappings

/// Maps Tealium parameter names to Firebase Analytics predefined parameter constants.
///
/// Custom parameters are also supported by Firebase - if a parameter name is not found
/// in the mapping, the original name is returned and will be sent as a custom parameter.
///
/// Firebase SDK Reference:
/// - Parameters: https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Constants
struct FirebaseParameter {
    
    /// Maps param_* keys to Firebase Analytics parameter constants.
    ///
    /// Usage: Send `param_currency` in payload → mapped to `AnalyticsParameterCurrency`
    static let mapping: [String: String] = [
        "param_achievement_id": AnalyticsParameterAchievementID,
        "param_ad_format": AnalyticsParameterAdFormat,
        "param_ad_network_click_id": AnalyticsParameterAdNetworkClickID,
        "param_ad_platform": AnalyticsParameterAdPlatform,
        "param_ad_source": AnalyticsParameterAdSource,
        "param_ad_unit_name": AnalyticsParameterAdUnitName,
        "param_affiliation": AnalyticsParameterAffiliation,
        "param_campaign": AnalyticsParameterCampaign,
        "param_campaign_id": AnalyticsParameterCampaignID,
        "param_character": AnalyticsParameterCharacter,
        "param_content": AnalyticsParameterContent,
        "param_content_type": AnalyticsParameterContentType,
        "param_coupon": AnalyticsParameterCoupon,
        "param_cp1": AnalyticsParameterCP1,
        "param_creative_format": AnalyticsParameterCreativeFormat,
        "param_creative_name": AnalyticsParameterCreativeName,
        "param_creative_slot": AnalyticsParameterCreativeSlot,
        "param_currency": AnalyticsParameterCurrency,
        "param_destination": AnalyticsParameterDestination,
        "param_discount": AnalyticsParameterDiscount,
        "param_end_date": AnalyticsParameterEndDate,
        "param_extend_session": AnalyticsParameterExtendSession,
        "param_flight_number": AnalyticsParameterFlightNumber,
        "param_group_id": AnalyticsParameterGroupID,
        "param_index": AnalyticsParameterIndex,
        "param_item_brand": AnalyticsParameterItemBrand,
        "param_item_category": AnalyticsParameterItemCategory,
        "param_item_category2": AnalyticsParameterItemCategory2,
        "param_item_category3": AnalyticsParameterItemCategory3,
        "param_item_category4": AnalyticsParameterItemCategory4,
        "param_item_category5": AnalyticsParameterItemCategory5,
        "param_item_id": AnalyticsParameterItemID,
        "param_item_list_id": AnalyticsParameterItemListID,
        "param_item_list_name": AnalyticsParameterItemListName,
        "param_item_name": AnalyticsParameterItemName,
        "param_item_variant": AnalyticsParameterItemVariant,
        "param_items": AnalyticsParameterItems,
        "param_level": AnalyticsParameterLevel,
        "param_level_name": AnalyticsParameterLevelName,
        "param_location": AnalyticsParameterLocation,
        "param_location_id": AnalyticsParameterLocationID,
        "param_marketing_tactic": AnalyticsParameterMarketingTactic,
        "param_medium": AnalyticsParameterMedium,
        "param_method": AnalyticsParameterMethod,
        "param_number_nights": AnalyticsParameterNumberOfNights,
        "param_number_pax": AnalyticsParameterNumberOfPassengers,
        "param_number_rooms": AnalyticsParameterNumberOfRooms,
        "param_origin": AnalyticsParameterOrigin,
        "param_payment_type": AnalyticsParameterPaymentType,
        "param_price": AnalyticsParameterPrice,
        "param_promotion_id": AnalyticsParameterPromotionID,
        "param_promotion_name": AnalyticsParameterPromotionName,
        "param_quantity": AnalyticsParameterQuantity,
        "param_score": AnalyticsParameterScore,
        "param_screen_class": AnalyticsParameterScreenClass,
        "param_screen_name": AnalyticsParameterScreenName,
        "param_search_term": AnalyticsParameterSearchTerm,
        "param_shipping": AnalyticsParameterShipping,
        "param_shipping_tier": AnalyticsParameterShippingTier,
        "param_source": AnalyticsParameterSource,
        "param_source_platform": AnalyticsParameterSourcePlatform,
        "param_start_date": AnalyticsParameterStartDate,
        "param_success": AnalyticsParameterSuccess,
        "param_tax": AnalyticsParameterTax,
        "param_term": AnalyticsParameterTerm,
        "param_transaction_id": AnalyticsParameterTransactionID,
        "param_travel_class": AnalyticsParameterTravelClass,
        "param_user_allow_ad_personalization_signals": AnalyticsUserPropertyAllowAdPersonalizationSignals,
        "param_user_signup_method": AnalyticsUserPropertySignUpMethod,
        "param_value": AnalyticsParameterValue,
        "param_virtual_currency_name": AnalyticsParameterVirtualCurrencyName
    ]
    
    /// Returns the mapped Firebase parameter name, or the original name if no mapping exists.
    ///
    /// If no mapping is found, the original name is returned unchanged.
    /// Firebase allows custom parameter names as long as they follow these rules:
    /// - Up to 40 characters
    /// - Must start with an alphabetic character
    /// - Only alphanumeric characters and underscores allowed
    /// - Reserved prefixes (`firebase_`, `google_`, `ga_`) cannot be used
    ///
    /// Parameter values must be one of these types:
    /// - String (max 100 characters for standard GA, 500 for GA 360)
    /// - Int
    /// - Double
    ///
    /// - Parameter paramName: The Tealium parameter name (e.g., "param_currency" or custom "my_param")
    /// - Returns: The Firebase Analytics parameter constant, or the original name for custom parameters
    static func map(_ paramName: String) -> String {
        return mapping[paramName] ?? paramName
    }
}
