//
//  CircleBirthdaysApp.swift
//  CircleBirthdays
//
//  Created by Ambika Nema on 04/05/26.
//

import SwiftUI

@main
struct CircleBirthdaysApp: App {
    @UIApplicationDelegateAdaptor(PushNotificationAppDelegate.self) private var pushNotificationDelegate

    init() {
        FirebaseBootstrap.configureIfPossible()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
