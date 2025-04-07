import 'package:client/components/Cards/reward_card.dart';
import 'package:client/services/auth/auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> rewards = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getRewards();
  }

  Future<void> getRewards() async {
    try {
      final firebase_auth.User? user = await Auth().getCurrentUser();

      if (user == null) {
        debugPrint("No user logged in.");
        return;
      }

      final userInfo = await supabase
          .from("users")
          .select("user_id")
          .eq("email", user.email.toString())
          .maybeSingle();

      if (userInfo == null) {
        debugPrint("No user info found for email ${user.email}");
        return;
      }

      final userRewards = await supabase
          .from("rewards")
          .select("reward_name, created_at")
          .eq("scribe_id", userInfo["user_id"])
          .order("created_at", ascending: false);

      setState(() {
        rewards = List<Map<String, dynamic>>.from(userRewards);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching rewards: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  IconData getRewardIcon(String name) {
    switch (name.toLowerCase()) {
      case "bronze":
        return Icons.emoji_events;
      case "silver":
        return Icons.emoji_events;
      case "gold":
        return Icons.workspace_premium;
      case "platinum":
        return Icons.star_rate;
      case "diamond":
        return Icons.diamond;
      default:
        return Icons.card_giftcard;
    }
  }

  Color getRewardColor(String name) {
    switch (name.toLowerCase()) {
      case "bronze":
        return Colors.brown;
      case "silver":
        return Colors.grey;
      case "gold":
        return Colors.amber;
      case "platinum":
        return Colors.blueGrey;
      case "diamond":
        return Colors.lightBlueAccent;
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async{
        debugPrint("reloading rewards");
        await getRewards();
      },
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : rewards.isEmpty
                ? const Center(child: Text("No rewards yet."))
                : ListView.builder(
                    itemCount: rewards.length,
                    itemBuilder: (context, index) {
                      final reward = rewards[index];
                      final rewardName = reward["reward_name"];
                      final obtainedAt = DateTime.parse(reward["created_at"]);
                      return RewardCard(
                        rewardName: "$rewardName Badge",
                        obtainedAt: obtainedAt,
                        iconData: getRewardIcon(rewardName),
                        iconColor: getRewardColor(rewardName),
                      );
                    },
                  ),
      ),
    );
  }
}
