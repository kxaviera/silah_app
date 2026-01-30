import admin from 'firebase-admin';
import { FCMToken } from '../models/FCMToken.model';
import mongoose from 'mongoose';

let fcmInitialized = false;

/**
 * Initialize Firebase Admin SDK.
 * Uses GOOGLE_APPLICATION_CREDENTIALS (path to JSON) or
 * FIREBASE_PROJECT_ID + FIREBASE_CLIENT_EMAIL + FIREBASE_PRIVATE_KEY.
 */
function initializeFCM(): boolean {
  if (fcmInitialized) return true;
  if (admin.apps.length > 0) {
    fcmInitialized = true;
    return true;
  }

  try {
    if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
      admin.initializeApp({
        credential: admin.credential.applicationDefault(),
      });
      fcmInitialized = true;
      console.log('FCM: Initialized with GOOGLE_APPLICATION_CREDENTIALS');
      return true;
    }

    const projectId = process.env.FIREBASE_PROJECT_ID;
    const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
    const privateKey = process.env.FIREBASE_PRIVATE_KEY;

    if (projectId && clientEmail && privateKey) {
      admin.initializeApp({
        credential: admin.credential.cert({
          projectId,
          clientEmail,
          privateKey: privateKey.replace(/\\n/g, '\n'),
        }),
      });
      fcmInitialized = true;
      console.log('FCM: Initialized with FIREBASE_* env vars');
      return true;
    }
  } catch (e) {
    console.warn('FCM: Initialization failed:', (e as Error).message);
  }
  return false;
}

export interface SendPushOptions {
  title: string;
  body: string;
  data?: Record<string, string>;
}

/**
 * Send FCM push notification to all devices registered for a user.
 * Safe to call even if FCM is not configured (no-op).
 */
export async function sendPushToUser(
  userId: string | mongoose.Types.ObjectId,
  options: SendPushOptions
): Promise<void> {
  if (!initializeFCM()) return;

  const uid = typeof userId === 'string' ? userId : userId.toString();
  const tokens = await FCMToken.find({ userId: uid }).select('token').lean();
  const fcmTokens = tokens.map((t) => t.token).filter(Boolean);

  if (fcmTokens.length === 0) return;

  const message: admin.messaging.MulticastMessage = {
    tokens: fcmTokens,
    notification: {
      title: options.title,
      body: options.body,
    },
    data: options.data || {},
    android: {
      priority: 'high',
      notification: {
        channelId: 'default',
        priority: 'high' as const,
      },
    },
    apns: {
      payload: {
        aps: {
          sound: 'default',
          badge: 1,
          'content-available': 1,
        },
      },
      fcmOptions: {
        imageUrl: undefined,
      },
    },
  };

  try {
    const result = await admin.messaging().sendEachForMulticast(message);
    if (result.failureCount > 0) {
      const invalidTokens: string[] = [];
      result.responses.forEach((resp, idx) => {
        if (!resp.success && resp.error?.code === 'messaging/invalid-registration-token') {
          invalidTokens.push(fcmTokens[idx]);
        }
      });
      if (invalidTokens.length > 0) {
        await FCMToken.deleteMany({ token: { $in: invalidTokens } });
      }
    }
  } catch (e) {
    console.warn('FCM: Send failed for user', uid, (e as Error).message);
  }
}
