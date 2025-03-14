import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class NotificationSendService {
  Future<String> getServerToken() async {
    final scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging",
    ];
    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "project_id": "writehub-a7b40",
        "private_key_id": "78972f3b8509ffbbadd0ad667d56c8310bb4524c",
        "private_key":
            "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC1hiUEjObts4Kq\n0lkDFsCfPg+nvIk0AfpmePZZWYxqf2ZCkKTHhBgPCy/aIxFTZEWBdgeGLd7b/GO4\n/zBDHjWheaEPLsepYbRGx6oKRDnE8/8wuZvtAuYyoqFLZrCPCQQE/a/emYOu5RKj\ndQw/84Ve86Sf65M3FPH6H1nBnSu9tLStVqXiiddtXwfqnN8bHMYlCEU4WQqnqxFU\nz2wx/Infwg8LFybcMXCEQAt0iT6fJmBqln3Y9WmXWum+Nw0PaF5Tz0/hilnRUJB+\n2lP0+2Dmf8sREU6Q9ET1IMZewHEO3vZEKf091PFU1VoroDD147jPQgs000ehqLdn\nOKaAIi4VAgMBAAECggEATLtKtJS3HS2vg3PtSn/4ppe+WGI7ATAA4AYr5HMVBwOZ\nf3PTI79zyBArhyMhtMWDGAmDfrWvKgCTSuUcSpLfisV2TouwvKnfYbgO6c4TOW0G\np1seTV7XXfofAleDNMNT3qQ6DneIEYsliND2f6X577xAD5WuIi+JZfiQoWZF0id0\nw9R+zV2oM/HEeDQOoyM0oEavRC6Ymn5rYF2UxuvbGQIh+oQqrvSJG5NjI4FJLQfh\nkae2x9YXrqwIcJ6HPG9mDHRxHDdczrxQi3Sv0HsVXHB7/GmYyKVpfiGf1jZZE5q0\nfBjVdJLzgZEauRjup4em1+0mF1MkVI0e/fK1skfkdQKBgQDtzuC20sNfh9irtxYy\nFz7zub10o16ZpS82gqn5tssSkg1ki591iLIPkTsyKstp6d1aoG0f/s2c0Qu41Fca\n/OQyW8WvenJG3jR5eZJ7a97xhsH7rMslT/aua4HXDagu51EwQpFlCVpOs0l9EmT2\nQDqdjCrvfUgpuvtbFCR7gPGVqwKBgQDDaQZ0jn28xcOkTt/L2/5aHe8acgyOOCLZ\nDHKGJoEFQ1zxRuvZQT6sayLy7rcIVYDGyiiyflbb4FysJzKR0dfAQjNJ2LmHx/jh\nLRjyJlYXIMaJ8C9OgGit5Lwby2x8gHi2ckkeL0grjF6urgWbWK9u2+NjDVof9vI6\nVgBsacALPwKBgCYK1j/o74A0xyCRJWfV+CgdKoWiLNv/ZNIfjPl5mHrcCnBvNY8j\n0vhSj1mzJt9GnjaFO2/G3zWa63kh3t1eX1L/A1zTBbz4hwR3wkskMoIIwLd2KPlL\nFXdJk3fHo4P9VSuXOpMjL+MvIy5y5tvN4pKZfbTaIdUrKFKlokBvnDYJAoGALxe2\neIyGfOHkPkrL4GNKLwmbv/HQWM3qiAhZ6T6KRWxwj60Z1afFpOPE7mrdLWL9v+qk\nWC/eWur9Knff1giOSEUr+xYB0Fk+/3VQ17qpcLVzY3bAz9heYdoIA2LI6FBFxyJP\nwLiAWg5gGxTRQRjkXoEbkZl8KMvooGpte7MYlx0CgYEAilknH9MhFEMwZQpgMLmx\nD4mTk99FUaO2n3uDwbwpv14uuwJWmG3lzzYVXu+bl+4/AWe7PyWZSvmyXBXtW7D0\noDfuuLR9NlCAjz22JM3fYmo8QO2yFg8rpeLCeuSBUvm22USN2eUiQtdar0jZIznh\n+Im5LX40kXgonTz6yDiggek=\n-----END PRIVATE KEY-----\n",
        "client_email":
            "firebase-adminsdk-ftsoe@writehub-a7b40.iam.gserviceaccount.com",
        "client_id": "112400510947879888305",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
            "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url":
            "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-ftsoe%40writehub-a7b40.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com",
      }),
      scopes,
    );
    final accessToken = client.credentials.accessToken.data;
    return accessToken;
  }

  final fcmInstance = FirebaseMessaging.instance;

  Future<void> sendNotification(String message, String title,[fcmToken]) async {
    try {
      final serverToken = await getServerToken();
      final deviceToken = fcmToken?? await fcmInstance.getToken();

      Map<String, dynamic> payload = {
        "message": {
          "token": deviceToken,
          "notification": {"body": message, "title": title},
        },
      };

      final response = await http.post(
        Uri.parse(
          "https://fcm.googleapis.com/v1/projects/writehub-a7b40/messages:send",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $serverToken",
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        debugPrint(response.statusCode.toString());
        debugPrint("Notification sent");
      } else {
        debugPrint(response.statusCode.toString());
        debugPrint("could not sent notification");
      }
    } catch (e) {
      debugPrint("could not send notification due to $e");
    }
  }
}
