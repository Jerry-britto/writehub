
import React from "react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";

interface UserData {
  id: string | number;
  name: string;
  points: number;
  awards: number;
  userDetails: any;
}

interface UserProfileModalProps {
  isOpen: boolean;
  onOpenChange: (open: boolean) => void;
  user: UserData | null;
}

const UserProfileModal: React.FC<UserProfileModalProps> = ({ 
  isOpen, 
  onOpenChange, 
  user 
}) => {
  // Function to get initials from name
  const getInitials = (name: string | undefined) => {
    if (!name) return "UN";
    return name
      .split(" ")
      .map(part => part[0])
      .join("")
      .toUpperCase()
      .slice(0, 2);
  };

  if (!user) return null;

  return (
    <Dialog open={isOpen} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>User Profile</DialogTitle>
          <DialogDescription>
            Detailed information about this user
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-4">
          <div className="flex items-center space-x-4">
            <Avatar className="h-16 w-16">
              <AvatarFallback>{getInitials(user.name)}</AvatarFallback>
              <AvatarImage 
                src={user.userDetails?.profile_photo || `https://api.dicebear.com/7.x/initials/svg?seed=${user.name}`} 
              />
            </Avatar>
            <div>
              <h3 className="text-lg font-semibold">{user.name}</h3>
              <p className="text-sm text-muted-foreground">{user.userDetails?.role || "No role assigned"}</p>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <p className="text-sm font-medium text-muted-foreground">Email</p>
              <p>{user.userDetails?.email || "Not provided"}</p>
            </div>
            <div>
              <p className="text-sm font-medium text-muted-foreground">College</p>
              <p>{user.userDetails?.collegeName || "Not provided"}</p>
            </div>
            <div>
              <p className="text-sm font-medium text-muted-foreground">Points</p>
              <p className="font-semibold text-xl">{user.points}</p>
            </div>
            <div>
              <p className="text-sm font-medium text-muted-foreground">Awards</p>
              <p>{user.awards || 0}</p>
            </div>
            <div>
              <p className="text-sm font-medium text-muted-foreground">Course</p>
              <p>{user.userDetails?.course || "Not provided"}</p>
            </div>
            <div>
              <p className="text-sm font-medium text-muted-foreground">Academic Year</p>
              <p>{user.userDetails?.academic_year || "Not provided"}</p>
            </div>
            <div>
              <p className="text-sm font-medium text-muted-foreground">Member Since</p>
              <p>{user.userDetails?.created_at ? new Date(user.userDetails.created_at).toLocaleDateString() : "Unknown"}</p>
            </div>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
};

export default UserProfileModal;
