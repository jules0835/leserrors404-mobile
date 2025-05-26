//
//  CynappApp.swift
//  Cynapp
//
//  Created by Draskeer on 01/04/2025.
//

import SwiftUI

@main
struct CynappApp: App {
    @StateObject private var cartViewModel = CartViewModel()
    @StateObject var categoryVM = CategoryViewModel()
    
    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(named: "CynaBg") // Vérifie bien le nom de ta couleur
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(cartViewModel)
                .environmentObject(categoryVM)
        }
    }
}

struct AppConstants {
    static let baseURL = "https://b3-cyna-web.vercel.app/"
    static let testToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2Nzk1MTdiODcwNzUwYjc5ZGExMTQwMmIiLCJlbWFpbCI6InRvbUBjeW5hLmNvbSIsImZpcnN0TmFtZSI6IlRvbSIsImxhc3ROYW1lIjoiQWxhcsOnb24iLCJpc0FkbWluIjp0cnVlLCJleHAiOjE3NDQzNjUxNjMsImlhdCI6MTc0NDM1Nzk2M30.0pk_5JxMacEt0tcFduDLd8GvFaBlTFoFSUBQLiuworM"
}


