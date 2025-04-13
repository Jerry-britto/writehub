import 'package:client/components/Cards/notification_card.dart';
import 'package:client/services/auth/auth.dart';
import 'package:client/services/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:intl/intl.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key, this.userId});
  final int? userId;

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final SupabaseClient supabase = Supabase.instance.client;
  Map<String, List<Map<String, dynamic>>> groupedNotifications = {};
  bool isLoading = true; // Track loading state

  Future<void> getNotifications() async {
    setState(() {
      isLoading = true; // Show loader before fetching data
    });

    try {
      firebase_auth.User? user = await Auth().getCurrentUser();
      if (user == null) {
        debugPrint("No logged-in user found.");
        setState(() {
          isLoading = false;
        });
        return;
      }

      var details = await Profile().getDetails(user.email!);
      final notifications = await supabase
          .from("notification")
          .select()
          .eq("user_id", details['user_id']);

      // Group notifications by date
      Map<String, List<Map<String, dynamic>>> groupedData = {};
      for (var notification in notifications) {
        String date = DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime.parse(notification['created_at']));
        if (!groupedData.containsKey(date)) {
          groupedData[date] = [];
        }
        groupedData[date]!.add(notification);
      }
      // Sort notifications within each day by created_at time (newest first)
      for (var date in groupedData.keys) {
        groupedData[date]!.sort(
          (a, b) => DateTime.parse(
            b['created_at'],
          ).compareTo(DateTime.parse(a['created_at'])),
        );
      }
      // Sort grouped notifications by date in descending order
      List<String> sortedDates =
          groupedData.keys.toList()
            ..sort((a, b) => DateTime.parse(b).compareTo(DateTime.parse(a)));

      // Reconstruct sorted map
      Map<String, List<Map<String, dynamic>>> sortedGroupedData = {
        for (var date in sortedDates) date: groupedData[date]!,
      };

      setState(() {
        groupedNotifications = sortedGroupedData;
      });

      // debugPrint("Sorted Grouped Notifications: $groupedNotifications");
    } catch (e) {
      debugPrint("Could not retrieve notifications due to $e");
    } finally {
      setState(() {
        isLoading = false; // Hide loader after fetching data
      });
    }
  }

  void handleDismiss(String date, Map<String, dynamic> notification) async {
    setState(() {
      groupedNotifications[date]?.remove(notification);
      if (groupedNotifications[date]?.isEmpty ?? false) {
        groupedNotifications.remove(date);
      }
    });

    await supabase
        .from("notification")
        .delete()
        .eq("notification_id", notification['notification_id'])
        .then((_) {
          debugPrint(
            "Notification ${notification['notification_id']} deleted from Supabase",
          );
        })
        .catchError((e) {
          debugPrint("Failed to delete notification: $e");
        });
  }

  @override
  void initState() {
    super.initState();
    getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        debugPrint("Reloading notifications");
        await getNotifications();
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
            isLoading
                ? const Center(
                  child: CircularProgressIndicator(),
                ) // Show loader
                : groupedNotifications.isEmpty
                ? const Center(
                  child: Text(
                    "No Notifications",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                )
                : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        groupedNotifications.entries.map((entry) {
                          String date = entry.key;
                          List<Map<String, dynamic>> notifications =
                              entry.value;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Text(
                                  DateFormat(
                                    'EEEE, MMM d, yyyy',
                                  ).format(DateTime.parse(date)),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ...notifications.map(
                                (notification) => Dismissible(
                                  key: Key(
                                    notification["notification_id"].toString(),
                                  ),
                                  onDismissed:
                                      (direction) =>
                                          handleDismiss(date, notification),
                                  //   onDismissed: (direction) {
                                  //   debugPrint(
                                  //     "Notification ${notification['id']} dismissed to the ${direction == DismissDirection.endToStart ? 'left' : 'right'}",
                                  //   );
                                  // },
                                  child: NotificationCard(
                                    title: notification['title'],
                                    description: notification["message"],
                                    time: DateFormat.jm().format(
                                      DateTime.parse(
                                        notification['created_at'],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ),
      ),
    );
  }
}
