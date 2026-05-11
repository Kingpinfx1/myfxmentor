import {onCall, HttpsError} from "firebase-functions/v2/https";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {defineSecret} from "firebase-functions/params";
import * as admin from "firebase-admin";
import Anthropic from "@anthropic-ai/sdk";

admin.initializeApp();

const anthropicApiKey = defineSecret("ANTHROPIC_API_KEY");

// ─── AI Coaching Summary ─────────────────────────────────────────────────────

export const generateCoachingSummary = onCall(
  {secrets: [anthropicApiKey]},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Must be signed in.");
    }

    const uid = request.auth.uid;
    const {
      totalTrades,
      winRate,
      disciplineScore,
      winRateByEmotion,
      winRateByPair,
    } = request.data as {
      totalTrades: number;
      winRate: number;
      disciplineScore: number;
      winRateByEmotion: Record<string, number>;
      winRateByPair: Record<string, number>;
    };

    const emotionSummary = Object.entries(winRateByEmotion)
      .map(([emotion, rate]) => `${emotion}: ${rate}% win rate`)
      .join(", ");

    const pairSummary = Object.entries(winRateByPair)
      .map(([pair, rate]) => `${pair}: ${rate}% win rate`)
      .join(", ");

    const prompt =
      "You are a professional forex trading coach. " +
      "Analyse this trader's overall performance and give a 3-4 sentence coaching summary. " +
      "Be specific, honest, and actionable.\n\n" +
      `Total trades: ${totalTrades}\n` +
      `Overall win rate: ${winRate}%\n` +
      `Discipline score: ${disciplineScore}%\n` +
      `Win rate by emotion — ${emotionSummary}\n` +
      `Win rate by pair — ${pairSummary}\n\n` +
      "Focus on: (1) the trader's strongest pattern, " +
      "(2) their biggest weakness, " +
      "(3) one concrete improvement for their next session. " +
      "Keep it under 80 words.";

    const client = new Anthropic({apiKey: anthropicApiKey.value()});

    const message = await client.messages.create({
      model: "claude-haiku-4-5-20251001",
      max_tokens: 300,
      messages: [{role: "user", content: prompt}],
    });

    const summary =
      (message.content[0] as {type: string; text: string}).text.trim();

    await admin
      .firestore()
      .collection("users")
      .doc(uid)
      .update({coachingSummary: summary});

    // Fetch FCM token and send "coaching ready" notification
    const userSnap = await admin.firestore().collection("users").doc(uid).get();
    const fcmToken = userSnap.data()?.fcmToken as string | undefined;

    if (fcmToken) {
      await admin.messaging().send({
        token: fcmToken,
        notification: {
          title: "Your coaching summary is ready ✦",
          body: "Tap to see your personalised trading analysis.",
        },
        data: {route: "insights"},
      }).catch((_err: unknown) => {/* ignore stale token */});

      // Milestone notifications (10, 25, 50, 100, 250 trades)
      const milestones = [10, 25, 50, 100, 250];
      if (milestones.includes(totalTrades)) {
        await admin.messaging().send({
          token: fcmToken,
          notification: {
            title: `${totalTrades} trades logged! 🎯`,
            body: "You're building a serious trading record. Keep it up.",
          },
        }).catch((_err: unknown) => {/* ignore stale token */});
      }
    }

    return {success: true};
  }
);

// ─── Daily Trading Reminder (6pm UTC every day) ──────────────────────────────

export const dailyTradingReminder = onSchedule("0 18 * * *", async () => {
  const users = await admin.firestore().collection("users").get();
  const tokens: string[] = users.docs
    .map((d) => d.data().fcmToken as string)
    .filter(Boolean);

  if (tokens.length === 0) return;

  // FCM multicast limit is 500 tokens per call
  for (let i = 0; i < tokens.length; i += 500) {
    await admin.messaging().sendEachForMulticast({
      tokens: tokens.slice(i, i + 500),
      notification: {
        title: "Don't forget to log your trades 📈",
        body: "Keep your streak alive — log today's session now.",
      },
      data: {route: "log"},
    });
  }
});

// ─── Weekly Performance Recap (6pm UTC every Sunday) ─────────────────────────

export const weeklyPerformanceRecap = onSchedule("0 18 * * 0", async () => {
  const now = new Date();
  const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

  const users = await admin.firestore().collection("users").get();

  for (const userDoc of users.docs) {
    const token = userDoc.data().fcmToken as string | undefined;
    if (!token) continue;

    const tradesSnap = await admin
      .firestore()
      .collection("users")
      .doc(userDoc.id)
      .collection("trades")
      .where("timestamp", ">=", weekAgo)
      .get();

    const count = tradesSnap.size;
    if (count === 0) continue; // don't notify inactive users

    const wins = tradesSnap.docs.filter(
      (d) => (d.data().result as number) > 0
    ).length;
    const winRate = Math.round((wins / count) * 100);

    await admin.messaging().send({
      token,
      notification: {
        title: "Your week in review 📊",
        body: `${count} trades · ${winRate}% win rate this week.`,
      },
      data: {route: "insights"},
    }).catch((_err: unknown) => {/* ignore stale token */});
  }
});
