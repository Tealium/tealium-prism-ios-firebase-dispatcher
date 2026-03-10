//
//  FirebaseParameterMapper.swift
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
/// Custom parameters are supported if not found in the mapping.
///
/// Firebase SDK Reference:
/// - https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Constants
struct FirebaseParameterMapper {
    
    /// Maps param_* keys to Firebase Analytics parameter constants.
    /// Example: `param_currency` → `"currency"`
    static let mapping: [String: String] = {
        typealias K = FirebaseConstants.EventParamKey
        return [
            K.achievementId: AnalyticsParameterAchievementID,
            K.adFormat: AnalyticsParameterAdFormat,
            K.adNetworkClickId: AnalyticsParameterAdNetworkClickID,
            K.adPlatform: AnalyticsParameterAdPlatform,
            K.adSource: AnalyticsParameterAdSource,
            K.adUnitName: AnalyticsParameterAdUnitName,
            K.affiliation: AnalyticsParameterAffiliation,
            K.campaign: AnalyticsParameterCampaign,
            K.campaignId: AnalyticsParameterCampaignID,
            K.character: AnalyticsParameterCharacter,
            K.content: AnalyticsParameterContent,
            K.contentType: AnalyticsParameterContentType,
            K.coupon: AnalyticsParameterCoupon,
            K.cp1: AnalyticsParameterCP1,
            K.creativeFormat: AnalyticsParameterCreativeFormat,
            K.creativeName: AnalyticsParameterCreativeName,
            K.creativeSlot: AnalyticsParameterCreativeSlot,
            K.currency: AnalyticsParameterCurrency,
            K.destination: AnalyticsParameterDestination,
            K.discount: AnalyticsParameterDiscount,
            K.endDate: AnalyticsParameterEndDate,
            K.extendSession: AnalyticsParameterExtendSession,
            K.flightNumber: AnalyticsParameterFlightNumber,
            K.groupId: AnalyticsParameterGroupID,
            K.index: AnalyticsParameterIndex,
            K.itemBrand: AnalyticsParameterItemBrand,
            K.itemCategory: AnalyticsParameterItemCategory,
            K.itemCategory2: AnalyticsParameterItemCategory2,
            K.itemCategory3: AnalyticsParameterItemCategory3,
            K.itemCategory4: AnalyticsParameterItemCategory4,
            K.itemCategory5: AnalyticsParameterItemCategory5,
            K.itemId: AnalyticsParameterItemID,
            K.itemListId: AnalyticsParameterItemListID,
            K.itemListName: AnalyticsParameterItemListName,
            K.itemName: AnalyticsParameterItemName,
            K.itemVariant: AnalyticsParameterItemVariant,
            K.items: AnalyticsParameterItems,
            K.level: AnalyticsParameterLevel,
            K.levelName: AnalyticsParameterLevelName,
            K.location: AnalyticsParameterLocation,
            K.locationId: AnalyticsParameterLocationID,
            K.marketingTactic: AnalyticsParameterMarketingTactic,
            K.medium: AnalyticsParameterMedium,
            K.method: AnalyticsParameterMethod,
            K.numberOfNights: AnalyticsParameterNumberOfNights,
            K.numberOfPassengers: AnalyticsParameterNumberOfPassengers,
            K.numberOfRooms: AnalyticsParameterNumberOfRooms,
            K.origin: AnalyticsParameterOrigin,
            K.paymentType: AnalyticsParameterPaymentType,
            K.price: AnalyticsParameterPrice,
            K.promotionId: AnalyticsParameterPromotionID,
            K.promotionName: AnalyticsParameterPromotionName,
            K.quantity: AnalyticsParameterQuantity,
            K.score: AnalyticsParameterScore,
            K.screenClass: AnalyticsParameterScreenClass,
            K.screenName: AnalyticsParameterScreenName,
            K.searchTerm: AnalyticsParameterSearchTerm,
            K.shipping: AnalyticsParameterShipping,
            K.shippingTier: AnalyticsParameterShippingTier,
            K.source: AnalyticsParameterSource,
            K.sourcePlatform: AnalyticsParameterSourcePlatform,
            K.startDate: AnalyticsParameterStartDate,
            K.success: AnalyticsParameterSuccess,
            K.tax: AnalyticsParameterTax,
            K.term: AnalyticsParameterTerm,
            K.transactionId: AnalyticsParameterTransactionID,
            K.travelClass: AnalyticsParameterTravelClass,
            K.userAllowAdPersonalizationSignals: AnalyticsUserPropertyAllowAdPersonalizationSignals,
            K.userSignupMethod: AnalyticsUserPropertySignUpMethod,
            K.value: AnalyticsParameterValue,
            K.virtualCurrencyName: AnalyticsParameterVirtualCurrencyName
        ]
    }()
    
    /// Returns the mapped Firebase parameter name, or the original name if no mapping exists.
    ///
    /// - Parameter paramName: The Tealium parameter name (e.g., "param_currency" or custom "my_param")
    /// - Returns: The Firebase Analytics parameter constant, or the original name for custom parameters
    static func map(_ paramName: String) -> String {
        return mapping[paramName.lowercased()] ?? paramName
    }
}
