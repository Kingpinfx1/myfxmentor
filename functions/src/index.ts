import {onCall, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import * as admin from "firebase-admin";
import Anthropic from "@anthropic-ai/sdk";

admin.initializeApp();

const anthropicApiKey = defineSecret("ANTHROPIC_API_KEY");

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

    return {success: true};
  }
);
