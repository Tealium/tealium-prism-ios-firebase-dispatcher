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
struct FirebaseItemParameter {
    
    /// Maps param_items_* keys to Firebase Analytics item parameter constants.
    /// Example: `param_items_item_id` → `"item_id"`
    static let mapping: [String: String] = [
        // Core
        "param_items_item_id": AnalyticsParameterItemID,
        "param_items_item_name": AnalyticsParameterItemName,
        "param_items_item_brand": AnalyticsParameterItemBrand,
        "param_items_item_category": AnalyticsParameterItemCategory,
        "param_items_item_category2": AnalyticsParameterItemCategory2,
        "param_items_item_category3": AnalyticsParameterItemCategory3,
        "param_items_item_category4": AnalyticsParameterItemCategory4,
        "param_items_item_category5": AnalyticsParameterItemCategory5,
        "param_items_item_variant": AnalyticsParameterItemVariant,
        
        // Lists
        "param_items_item_list_id": AnalyticsParameterItemListID,
        "param_items_item_list_name": AnalyticsParameterItemListName,
        "param_items_index": AnalyticsParameterIndex,
        
        // Pricing
        "param_items_price": AnalyticsParameterPrice,
        "param_items_quantity": AnalyticsParameterQuantity,
        "param_items_discount": AnalyticsParameterDiscount,
        
        // E-commerce (item-scope only)
        "param_items_affiliation": AnalyticsParameterAffiliation,
        "param_items_coupon": AnalyticsParameterCoupon,
        "param_items_location_id": AnalyticsParameterLocationID,
        
        // Promotions
        "param_items_promotion_id": AnalyticsParameterPromotionID,
        "param_items_promotion_name": AnalyticsParameterPromotionName,
        "param_items_creative_name": AnalyticsParameterCreativeName,
        "param_items_creative_slot": AnalyticsParameterCreativeSlot
    ]
    
    /// Returns the mapped Firebase item parameter name, or the original name if no mapping exists.
    ///
    /// - Parameter paramName: The item parameter name (e.g., "param_items_item_id" or "custom_color")
    /// - Returns: The Firebase Analytics item parameter constant, or original name for custom parameters
    static func map(_ paramName: String) -> String {
        return mapping[paramName] ?? paramName
    }
}


