//
//  URLConstants.swift
//  Launchtrip
//
//  Created by Drew Sen on 2019-08-25.
//  Copyright © 2019 Drew Sen. All rights reserved.
//

import Foundation


//URLConstants.swift

struct APPURL {
    
    private struct Domains {
        static let Dev = "https://events-api.previewlaunchtrip.com"
        static let UAT = "https://events-api.previewlaunchtrip.com"
        static let Local = "https://events-api.previewlaunchtrip.com"
        static let QA = "https://events-api.previewlaunchtrip.com"
    }
    
    private  struct Routes {
        static let Api = "/events"
    }
    
    private  static let Domain = Domains.Dev
    private  static let Route = Routes.Api
    private  static let BaseURL = Domain + Route
    
    static var EventEndpoint: String {
        return BaseURL
    }
    static var FacebookLogin: String {
        return BaseURL  + "/auth/facebook"
    }
}
