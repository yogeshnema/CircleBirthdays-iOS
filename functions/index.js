const admin = require("firebase-admin");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { setGlobalOptions } = require("firebase-functions/v2");

admin.initializeApp();
setGlobalOptions({ region: "asia-south1" });

exports.dispatchQueuedNotification = onDocumentCreated("notifications/{notificationId}", async (event) => {
  const snap = event.data;
  if (!snap) {
    return;
  }

  const notification = snap.data() || {};
  if ((notification.status || "QUEUED") !== "QUEUED") {
    return;
  }

  const title = typeof notification.title === "string" && notification.title.trim().length
    ? notification.title.trim()
    : "CircleBirthdays";
  const body = typeof notification.body === "string" ? notification.body.trim() : "";
  const category = typeof notification.category === "string" ? notification.category : "general";
  const referenceId = typeof notification.referenceID === "string" ? notification.referenceID : "";
  const recipientIds = Array.isArray(notification.recipientIds)
    ? notification.recipientIds.filter((value) => typeof value === "string" && value.trim().length > 0)
    : [];

  if (recipientIds.length === 0) {
    await snap.ref.set(
      {
        status: "NO_RECIPIENTS",
        processedAt: admin.firestore.FieldValue.serverTimestamp()
      },
      { merge: true }
    );
    return;
  }

  const result = await sendPushToRecipients({
    recipientIds,
    title,
    body,
    category,
    referenceId
  });

  await snap.ref.set(
    {
      status: result.status,
      processedAt: admin.firestore.FieldValue.serverTimestamp(),
      recipientCount: recipientIds.length,
      deliveredCount: result.deliveredCount,
      failedCount: result.failedCount,
      failedTokens: result.failedTokens
    },
    { merge: true }
  );
});

exports.notifyOnNewDirectMessage = onDocumentCreated("channels/{channelId}/messages/{messageId}", async (event) => {
  const snap = event.data;
  if (!snap) {
    return;
  }

  const message = snap.data() || {};
  const senderId = typeof message.senderId === "string" ? message.senderId.trim() : "";
  const receiverId = typeof message.receiverId === "string" ? message.receiverId.trim() : "";
  const senderName = typeof message.senderName === "string" && message.senderName.trim().length
    ? message.senderName.trim()
    : "A family member";
  const text = typeof message.text === "string" ? message.text.trim() : "";

  if (!senderId || !receiverId || senderId === receiverId) {
    return;
  }

  const result = await sendPushToRecipients({
    recipientIds: [receiverId],
    title: `New message from ${senderName}`,
    body: text || "You received a new message.",
    category: "direct-message",
    referenceId: typeof message.id === "string" ? message.id : snap.id
  });

  await snap.ref.set(
    {
      pushStatus: result.status,
      pushDeliveredCount: result.deliveredCount,
      pushFailedCount: result.failedCount,
      pushFailedTokens: result.failedTokens,
      pushProcessedAt: admin.firestore.FieldValue.serverTimestamp()
    },
    { merge: true }
  );
});

async function loadRecipientTokens(recipientIds) {
  const db = admin.firestore();
  const lookups = [];

  for (const userId of recipientIds) {
    const memberRef = db.collection("members").doc(userId);
    const pendingRef = db.collection("pending_updates").doc(userId);

    let snapshot = await memberRef.get();
    let collection = "members";

    if (!snapshot.exists) {
      snapshot = await pendingRef.get();
      collection = "pending_updates";
    }

    const data = snapshot.exists ? snapshot.data() || {} : {};
    const tokens = uniqueTokens([
      typeof data.fcmToken === "string" ? data.fcmToken : "",
      ...(Array.isArray(data.fcmTokens) ? data.fcmTokens : [])
    ]);

    if (tokens.length === 0) {
      lookups.push({
        userId,
        collection,
        ref: snapshot.exists ? (collection === "members" ? memberRef : pendingRef) : null,
        token: ""
      });
      continue;
    }

    tokens.forEach((token) => {
      lookups.push({
        userId,
        collection,
        ref: snapshot.exists ? (collection === "members" ? memberRef : pendingRef) : null,
        token
      });
    });
  }

  return lookups;
}

async function sendPushToRecipients({ recipientIds, title, body, category, referenceId }) {
  const lookup = await loadRecipientTokens(recipientIds);
  const registrationTokens = uniqueTokens(lookup.map((item) => item.token));

  if (registrationTokens.length === 0) {
    return {
      status: "NO_TOKENS",
      deliveredCount: 0,
      failedCount: 0,
      failedTokens: []
    };
  }

  const response = await admin.messaging().sendEachForMulticast(
    buildPushMessage({
      tokens: registrationTokens,
      title,
      body,
      category,
      referenceId
    })
  );
  const failedTokens = [];

  response.responses.forEach((result, index) => {
    if (!result.success) {
      failedTokens.push(registrationTokens[index]);
    }
  });

  if (failedTokens.length > 0) {
    await disableInvalidTokens(lookup, failedTokens);
  }

  return {
    status: failedTokens.length > 0 ? "PARTIAL" : "SENT",
    deliveredCount: response.successCount,
    failedCount: response.failureCount,
    failedTokens
  };
}

function buildPushMessage({ tokens, title, body, category, referenceId }) {
  const safeTitle = title || "CircleBirthdays";
  const safeBody = body || "";

  return {
    notification: {
      title: safeTitle,
      body: safeBody
    },
    apns: {
      headers: {
        "apns-priority": "10",
        "apns-push-type": "alert"
      },
      payload: {
        aps: {
          alert: {
            title: safeTitle,
            body: safeBody
          },
          sound: "default",
          badge: 1
        }
      }
    },
    android: {
      priority: "high",
      notification: {
        sound: "default",
        channelId: "default"
      }
    },
    data: {
      category: category || "general",
      referenceID: referenceId || "",
      title: safeTitle,
      body: safeBody
    },
    tokens
  };
}

function uniqueTokens(tokens) {
  return Array.from(
    new Set(
      tokens
        .filter((token) => typeof token === "string")
        .map((token) => token.trim())
        .filter((token) => token.length > 0)
    )
  );
}

async function disableInvalidTokens(lookups, failedTokens) {
  const failedSet = new Set(failedTokens);

  await Promise.all(
    lookups
      .filter((lookup) => failedSet.has(lookup.token) && lookup.ref)
      .map(async (lookup) => {
        await lookup.ref.set(
          {
            fcmToken: admin.firestore.FieldValue.delete(),
            fcmTokens: admin.firestore.FieldValue.arrayRemove(lookup.token)
          },
          { merge: true }
        );
      })
  );
}
