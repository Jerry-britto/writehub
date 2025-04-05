
import React, { useEffect, useState } from "react";
import DashboardLayout from "@/components/dashboard/DashboardLayout";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Loader2 } from "lucide-react";
import { fetchRewards, fetchTopUsers } from "@/services/rewardsService";
import RewardsTable from "@/components/rewards/RewardsTable";
import LeaderboardTable from "@/components/rewards/LeaderboardTable";
import UserProfileModal from "@/components/rewards/UserProfileModal";

const Rewards = () => {
  const [leaderboard, setLeaderboard] = useState([]);
  const [rewards, setRewards] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [selectedUser, setSelectedUser] = useState(null);
  const [isProfileModalOpen, setIsProfileModalOpen] = useState(false);

  useEffect(() => {
    const loadData = async () => {
      try {
        setIsLoading(true);
        const topUsers = await fetchTopUsers();
        const rewardsData = await fetchRewards();
        
        setLeaderboard(topUsers);
        setRewards(rewardsData);
      } catch (error) {
        console.error("Error loading data:", error);
      } finally {
        setIsLoading(false);
      }
    };
    
    loadData();
  }, []);

  const openProfileModal = (user) => {
    setSelectedUser(user);
    setIsProfileModalOpen(true);
  };

  return (
    <DashboardLayout>
      <div className="p-8">
        <div className="mb-6">
          <h1 className="text-3xl font-bold">Rewards</h1>
        </div>

        <Tabs defaultValue="rewards">
          <TabsList className="mb-6">
            <TabsTrigger value="rewards">Rewards</TabsTrigger>
            <TabsTrigger value="leaderboard">Leaderboard</TabsTrigger>
          </TabsList>
          
          <TabsContent value="rewards">
            <Card>
              <CardHeader>
                <CardTitle>Available Rewards</CardTitle>
                <CardDescription>Manage system rewards and achievements</CardDescription>
              </CardHeader>
              <CardContent>
                {isLoading ? (
                  <div className="flex justify-center items-center p-8">
                    <Loader2 className="h-8 w-8 animate-spin text-primary" />
                    <span className="ml-2">Loading rewards...</span>
                  </div>
                ) : (
                  <RewardsTable rewards={rewards} isLoading={isLoading} />
                )}
              </CardContent>
            </Card>
          </TabsContent>
          
          <TabsContent value="leaderboard">
            <Card>
              <CardHeader>
                <CardTitle>Top Performers</CardTitle>
                <CardDescription>Users with the most points and rewards</CardDescription>
              </CardHeader>
              <CardContent>
                <LeaderboardTable 
                  leaderboard={leaderboard}
                  isLoading={isLoading}
                  onUserClick={openProfileModal}
                />
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>

      <UserProfileModal 
        isOpen={isProfileModalOpen}
        onOpenChange={setIsProfileModalOpen}
        user={selectedUser}
      />
    </DashboardLayout>
  );
};

export default Rewards;
