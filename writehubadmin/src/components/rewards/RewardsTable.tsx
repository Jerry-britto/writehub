
import React from "react";
import { 
  Table, 
  TableBody, 
  TableCell, 
  TableHead, 
  TableHeader, 
  TableRow 
} from "@/components/ui/table";
import { Award, Loader2, Trophy } from "lucide-react";

interface RewardData {
  id: string | number;
  name: string;
  scribeName: string;
  awardedAt: string;
}

interface RewardsTableProps {
  rewards: RewardData[];
  isLoading: boolean;
}

export const getRewardIcon = (rewardName: string) => {
  const rewardType = rewardName?.toLowerCase() || "";
  if (rewardType.includes("gold")) return <Trophy className="h-5 w-5 text-yellow-500" />;
  if (rewardType.includes("silver")) return <Trophy className="h-5 w-5 text-gray-400" />;
  if (rewardType.includes("bronze")) return <Trophy className="h-5 w-5 text-amber-700" />;
  if (rewardType.includes("platinum")) return <Trophy className="h-5 w-5 text-blue-400" />;
  if (rewardType.includes("diamond")) return <Trophy className="h-5 w-5 text-purple-400" />;
  return <Award className="h-5 w-5" />;
};

const RewardsTable: React.FC<RewardsTableProps> = ({ rewards, isLoading }) => {
  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>Reward</TableHead>
          <TableHead>Recipient</TableHead>
          <TableHead>Awarded At</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {rewards.map((reward) => (
          <TableRow key={reward.id}>
            <TableCell>
              <div className="flex items-center space-x-3">
                <div className="p-2 bg-blue-100 rounded-full text-blue-600">
                  {getRewardIcon(reward.name)}
                </div>
                <span className="font-medium">{reward.name}</span>
              </div>
            </TableCell>
            <TableCell>{reward.scribeName}</TableCell>
            <TableCell>{reward.awardedAt}</TableCell>
          </TableRow>
        ))}
        {rewards.length === 0 && !isLoading && (
          <TableRow>
            <TableCell colSpan={3} className="text-center py-8">
              No rewards data available
            </TableCell>
          </TableRow>
        )}
      </TableBody>
    </Table>
  );
};

export default RewardsTable;
