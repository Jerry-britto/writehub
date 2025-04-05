
import React from "react";
import { 
  Table, 
  TableBody, 
  TableCell, 
  TableHead, 
  TableHeader, 
  TableRow 
} from "@/components/ui/table";
import { Loader2 } from "lucide-react";

interface UserData {
  id: string | number;
  name: string;
  points: number;
  awards: number;
  userDetails: any;
}

interface LeaderboardTableProps {
  leaderboard: UserData[];
  isLoading: boolean;
  onUserClick: (user: UserData) => void;
}

const LeaderboardTable: React.FC<LeaderboardTableProps> = ({ 
  leaderboard, 
  isLoading, 
  onUserClick 
}) => {
  if (isLoading) {
    return (
      <div className="flex justify-center items-center p-8">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
        <span className="ml-2">Loading leaderboard...</span>
      </div>
    );
  }

  if (leaderboard.length === 0) {
    return (
      <div className="text-center py-8">
        <p className="text-muted-foreground">No leaderboard data available</p>
      </div>
    );
  }

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>Rank</TableHead>
          <TableHead>Name</TableHead>
          <TableHead>Points</TableHead>
          <TableHead>Awards</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {leaderboard.map((user, index) => (
          <TableRow 
            key={user.id} 
            className="cursor-pointer hover:bg-muted" 
            onClick={() => onUserClick(user)}
          >
            <TableCell>
              <div className={`flex items-center justify-center w-8 h-8 rounded-full font-bold ${
                index === 0 ? "bg-yellow-200 text-yellow-800" :
                index === 1 ? "bg-gray-200 text-gray-800" :
                index === 2 ? "bg-amber-200 text-amber-800" : "bg-blue-100 text-blue-800"
              }`}>
                {index + 1}
              </div>
            </TableCell>
            <TableCell>
              <span className="font-medium">{user.name}</span>
            </TableCell>
            <TableCell>{user.points}</TableCell>
            <TableCell>{user.awards}</TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
};

export default LeaderboardTable;
