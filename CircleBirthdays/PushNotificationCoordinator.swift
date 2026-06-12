import Foundation
import UserNotifications
import os

#if canImport(UIKit)
import UIKit
#endif

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

#if canImport(FirebaseMessaging)
import FirebaseMessaging
#endif

extension Notification.Name {
    static let circleBirthdaysPushTokenDidChange = Notification.Name("CircleBirthdaysPushTokenDidChange")
}

private let pushLogger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "CircleBirthdays",
    category: "PushNotifications"
)

final class PushNotificationCoordinator: NSObject {
    static let shared = PushNotificationCoordinator()

    private(set) var deviceToken: String?
    private(set) var fcmToken: String?

    func configure(application: UIApplication) {
        #if canImport(FirebaseMessaging)
        Messaging.messaging().delegate = self
        pushLogger.info("FirebaseMessaging delegate configured.")
        #else
        pushLogger.error("FirebaseMessaging is not available in this build.")
        #endif

        Task { @MainActor in
            do {
                let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                pushLogger.info("Notification authorization result: \(granted, privacy: .public)")
            } catch {
                pushLogger.error("Notification authorization request failed: \(error.localizedDescription, privacy: .public)")
            }

            pushLogger.info("Registering app for remote notifications.")
            application.registerForRemoteNotifications()
            await refreshFCMToken()
        }
    }

    func didRegisterForRemoteNotifications(with deviceToken: Data) {
        let token = deviceToken.hexString
        self.deviceToken = token
        pushLogger.info("APNs device token received: \(token, privacy: .private)")

        #if canImport(FirebaseMessaging)
        Messaging.messaging().apnsToken = deviceToken
        pushLogger.info("APNs token assigned to FirebaseMessaging.")
        Task {
            await refreshFCMToken()
        }
        #endif
    }

    func didFailToRegisterForRemoteNotifications(with error: Error) {
        pushLogger.error("Push registration failed: \(error.localizedDescription, privacy: .public)")
        print("Push registration failed: \(error.localizedDescription)")
    }

    func scheduleForegroundPresentation(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .badge, .sound])
    }

    func syncPushToken(for member: Member, using repository: MemberRepository) async {
        guard let token = fcmToken ?? deviceToken else {
            pushLogger.error("No APNs or FCM token available to sync for member \(member.id, privacy: .private).")
            return
        }

        guard member.fcmToken != token else {
            pushLogger.info("Push token already synced for member \(member.id, privacy: .private).")
            return
        }

        do {
            try await repository.updatePushToken(
                userID: member.id,
                token: token,
                toPending: member.status.isPendingStatus
            )
            pushLogger.info("Push token synced for member \(member.id, privacy: .private).")
        } catch {
            pushLogger.error("Unable to sync push token: \(error.localizedDescription, privacy: .public)")
            print("Unable to sync push token: \(error.localizedDescription)")
        }
    }

    func queueNotification(
        title: String,
        body: String,
        recipientIDs: [String],
        category: String,
        referenceID: String? = nil
    ) async {
        #if canImport(FirebaseFirestore)
        guard FirebaseBootstrap.isConfigured else { return }

        var payload: [String: Any] = [
            "title": title,
            "body": body,
            "recipientIds": recipientIDs,
            "category": category,
            "status": "QUEUED",
            "createdAt": Timestamp(date: .now)
        ]

        if let referenceID {
            payload["referenceID"] = referenceID
        }

        do {
            try await Firestore.firestore()
                .collection("notifications")
                .document()
                .setData(payload)
        } catch {
            print("Unable to queue notification: \(error.localizedDescription)")
        }
        #endif
    }

    func scheduleLocalNotification(title: String, body: String) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Unable to schedule local notification: \(error.localizedDescription)")
        }
    }

    func updateFCMToken(_ token: String?) {
        guard let token, !token.isEmpty, fcmToken != token else { return }
        fcmToken = token
        pushLogger.info("FCM token updated: \(token, privacy: .private)")
        NotificationCenter.default.post(name: .circleBirthdaysPushTokenDidChange, object: token)
    }

    private func refreshFCMToken() async {
        #if canImport(FirebaseMessaging)
        guard FirebaseBootstrap.isConfigured else {
            pushLogger.error("Skipping FCM token fetch because Firebase is not configured.")
            return
        }
        do {
            pushLogger.info("Fetching FCM token.")
            let token = try await Messaging.messaging().token()
            updateFCMToken(token)
        } catch {
            pushLogger.error("Unable to fetch FCM token: \(error.localizedDescription, privacy: .public)")
            print("Unable to fetch FCM token: \(error.localizedDescription)")
        }
        #endif
    }
}

#if canImport(FirebaseMessaging)
extension PushNotificationCoordinator: MessagingDelegate {
    nonisolated func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Task { @MainActor in
            PushNotificationCoordinator.shared.updateFCMToken(fcmToken)
        }
    }
}
#endif

final class PushNotificationAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        PushNotificationCoordinator.shared.configure(application: application)
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        PushNotificationCoordinator.shared.didRegisterForRemoteNotifications(with: deviceToken)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        PushNotificationCoordinator.shared.didFailToRegisterForRemoteNotifications(with: error)
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        Task { @MainActor in
            PushNotificationCoordinator.shared.scheduleForegroundPresentation(
                center,
                willPresent: notification,
                withCompletionHandler: completionHandler
            )
        }
    }
}

private extension Data {
    var hexString: String {
        map { String(format: "%02x", $0) }.joined()
    }
}
