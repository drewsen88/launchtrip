//
//  SortBy.swift
//  Launchtrip
//
//  Created by Drew Sen on 2019-08-19.
//  Copyright © 2019 Drew Sen. All rights reserved.
//

import Foundation

enum SortBy: Int {
    case Price = 0
    case UnitPrice
    case Popularity
    case Brand

    init?(index: Int) {
        switch index {
        case 0: self = .Price
        case 1: self = .UnitPrice
        case 2: self = .Popularity
        case 3: self = .Brand
        default:
            return nil
        }
    }
    
    var description: String? {
        get {
            switch self {
            case .Price: return "Price"
            case .UnitPrice: return "Unit Price"
            case .Popularity: return "Popularity"
            case .Brand: return "Brand"
            }
        }
    }
}
