//
//  FirebaseItemParameter.swift
//  TealiumPrismFirebase
//
//  Created by Sebastian Krajna on 12/11/2025.
//  Copyright © 2025 Tealium. All rights reserved.
//

import Foundation
import FirebaseAnalytics

// MARK: - Firebase Item Parameter Mappings

/// Maps Tealium item parameter names to Firebase Analytics predefined item parameter constants.
///
/// Custom parameters are supported if not found in the mapping.
/// Up to 27 custom parameters can be included per item (10 for standard GA, 25 for GA 360).
///
/// Reference:
/// - https://developers.google.com/analytics/devguides/collection/ga4/reference/events#item-parameters
/// - https://developers.google.com/analytics/devguides/collection/ga4/item-scoped-ecommerce
struct FirebaseItemParameterMapper {
    
    /// Maps param_items_* keys to Firebase Analytics item parameter constants.
    /// Example: `param_items_item_id` → `"item_id"`
    static let mapping: [String: String] = {
        typealias K = FirebaseConstants.ItemParamKey
        return [
            // Core
            K.itemId: AnalyticsParameterItemID,
            K.itemName: AnalyticsParameterItemName,
            K.itemBrand: AnalyticsParameterItemBrand,
            K.itemCategory: AnalyticsParameterItemCategory,
            K.itemCategory2: AnalyticsParameterItemCategory2,
            K.itemCategory3: AnalyticsParameterItemCategory3,
            K.itemCategory4: AnalyticsParameterItemCategory4,
            K.itemCategory5: AnalyticsParameterItemCategory5,
            K.itemVariant: AnalyticsParameterItemVariant,

            // Lists
            K.itemListId: AnalyticsParameterItemListID,
            K.itemListName: AnalyticsParameterItemListName,
            K.index: AnalyticsParameterIndex,

            // Pricing
            K.price: AnalyticsParameterPrice,
            K.quantity: AnalyticsParameterQuantity,
            K.discount: AnalyticsParameterDiscount,

            // E-commerce (item-scope only)
            K.affiliation: AnalyticsParameterAffiliation,
            K.coupon: AnalyticsParameterCoupon,
            K.locationId: AnalyticsParameterLocationID,

            // Promotions
            K.promotionId: AnalyticsParameterPromotionID,
            K.promotionName: AnalyticsParameterPromotionName,
            K.creativeName: AnalyticsParameterCreativeName,
            K.creativeSlot: AnalyticsParameterCreativeSlot
        ]
    }()
    
    /// Returns the mapped Firebase item parameter name, or the original name if no mapping exists.
    ///
    /// - Parameter paramName: The item parameter name (e.g., "param_items_item_id" or "custom_color")
    /// - Returns: The Firebase Analytics item parameter constant, or original name for custom parameters
    static func map(_ paramName: String) -> String {
        return mapping[paramName.lowercased()] ?? paramName
    }
}


