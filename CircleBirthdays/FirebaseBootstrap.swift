import Foundation

#if canImport(FirebaseCore)
import FirebaseCore
#endif

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

enum FirebaseBootstrap {
    static func configureIfPossible() {
        #if canImport(FirebaseCore)
        guard FirebaseApp.app() == nil else {
            return
        }

        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            return
        }

        FirebaseApp.configure()

        #if canImport(FirebaseFirestore)
        let firestore = Firestore.firestore()
        var settings = firestore.settings
        settings.cacheSettings = PersistentCacheSettings()
        firestore.settings = settings
        #endif
        #endif
    }

    static var isConfigured: Bool {
        #if canImport(FirebaseCore)
        return FirebaseApp.app() != nil
        #else
        return false
        #endif
    }

    static var statusText: String {
        #if canImport(FirebaseCore)
        if isConfigured {
            return "Using Firestore data"
        }

        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") == nil {
            return "Add GoogleService-Info.plist to enable Firestore"
        }

        return "Firebase SDK available, but app is not configured"
        #else
        return "Install FirebaseCore, FirebaseFirestore, and FirebaseStorage via SwiftPM"
        #endif
    }
}
