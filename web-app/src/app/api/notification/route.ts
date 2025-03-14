import admin from "@/lib/firebase-admin";
import { supabase } from "@/lib/supabase-client";
import { NextRequest, NextResponse } from "next/server";

interface NotificationRequestBody {
  userId: number;
  title: string;
  body: string;
}

export async function POST(req: NextRequest) {
  try {
    const { userId, title, body }: NotificationRequestBody = await req.json();
    console.log(`Request body data: ${userId},${title},${body}`);
    const parsedUserId = Number(userId);
    if (isNaN(parsedUserId)) {
      return NextResponse.json(
        { error: "Invalid userId format" },
        { status: 400 }
      );
    }

    if (!parsedUserId || !title || !body) {
      return NextResponse.json(
        { error: "Missing required fields" },
        { status: 400 }
      );
    }

    const { data, error } = await supabase
      .from("users")
      .select("fcm_token")
      .eq("user_id", parsedUserId)
      .single();

      console.log(`Response: ${data?.fcm_token}`);

    if (error || !data?.fcm_token) {
      console.error("Supabase error:", error);
      return NextResponse.json(
        { error: "FCM token not found" },
        { status: 400 }
      );
    }

    const message = {
      token: data.fcm_token,
      notification: { title, body },
    };

    await admin.messaging().send(message);

    await supabase.from("notification").insert(
      {
        "user_id":parsedUserId,
        "title":message.notification.title,
        "message":message.notification.body
      }
    );

    return NextResponse.json({ message: "Notification sent" }, { status: 200 });
  } catch (err) {
    console.error("Error sending notification:", err);
    return NextResponse.json(
      { error: (err as Error).message },
      { status: 500 }
    );
  }
}
