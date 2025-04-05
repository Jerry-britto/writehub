
import { supabase } from "@/integrations/supabase/client";

export const fetchTopUsers = async () => {
  try {
    // Get top 5 users with highest points
    const { data: pointsData, error: pointsError } = await supabase
      .from("scribes_points")
      .select("*, users:user_id(*)")
      .order("points", { ascending: false })
      .limit(5);

    if (pointsError) {
      console.error("Error fetching top users:", pointsError);
      throw pointsError;
    }

    // For each user, get their awards count
    const userIds = pointsData.map(item => item.user_id);
    
    const { data: awardsData, error: awardsError } = await supabase
      .from("rewards")
      .select("scribe_id")
      .in("scribe_id", userIds);

    if (awardsError) {
      console.error("Error fetching awards count:", awardsError);
      throw awardsError;
    }

    // Create a map of user_id to awards count
    const awardsCountMap = {};
    awardsData.forEach(item => {
      awardsCountMap[item.scribe_id] = (awardsCountMap[item.scribe_id] || 0) + 1;
    });

    // Map the data to the format needed for the leaderboard
    const formattedData = pointsData.map(item => ({
      id: item.user_id,
      name: item.users?.name || "Unknown User",
      points: item.points || 0,
      awards: awardsCountMap[item.user_id] || 0,
      userDetails: item.users
    }));

    return formattedData;
  } catch (error) {
    console.error("Error in fetchTopUsers:", error);
    throw error;
  }
};

export const fetchRewards = async () => {
  try {
    const { data, error } = await supabase
      .from("rewards")
      .select(`
        reward_id, 
        reward_name, 
        created_at,
        users:scribe_id(name)
      `)
      .order("created_at", { ascending: false });

    if (error) {
      console.error("Error fetching rewards:", error);
      throw error;
    }

    return data.map(reward => ({
      id: reward.reward_id,
      name: reward.reward_name || "Unknown Reward",
      scribeName: reward.users?.name || "Unknown User",
      awardedAt: new Date(reward.created_at).toLocaleDateString()
    }));
  } catch (error) {
    console.error("Error in fetchRewards:", error);
    throw error;
  }
};
