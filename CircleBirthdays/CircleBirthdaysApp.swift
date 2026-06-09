//
//  CircleBirthdaysApp.swift
//  CircleBirthdays
//
//  Created by Ambika Nema on 04/05/26.
//

import SwiftUI
import UIKit

@main
struct CircleBirthdaysApp: App {
    @UIApplicationDelegateAdaptor(PushNotificationAppDelegate.self) private var pushNotificationDelegate

    init() {
        FirebaseBootstrap.configureIfPossible()
        configureTransparentContainers()
    }

    private func configureTransparentContainers() {
        let transparentNavigationBar = UINavigationBarAppearance()
        transparentNavigationBar.configureWithTransparentBackground()

        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().backgroundColor = .clear
        UINavigationBar.appearance().standardAppearance = transparentNavigationBar
        UINavigationBar.appearance().scrollEdgeAppearance = transparentNavigationBar
        UITableView.appearance().backgroundColor = .clear
        UICollectionView.appearance().backgroundColor = .clear
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
