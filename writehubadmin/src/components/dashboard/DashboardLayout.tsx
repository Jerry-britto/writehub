import React from "react";
import {
  Sidebar,
  SidebarContent,
  SidebarHeader,
  SidebarFooter,
  SidebarMenu,
  SidebarMenuItem,
  SidebarMenuButton,
  SidebarTrigger,
  useSidebar,
} from "@/components/ui/sidebar";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { BookOpen, Users, Award, LogOut } from "lucide-react";
import { Link, useLocation } from "react-router-dom";

import { supabase } from "@/integrations/supabase/client";
import { useNavigate } from "react-router-dom";
import { toast } from "sonner";

const DashboardSidebar = () => {
  const location = useLocation();
  const currentPath = location.pathname;
  const navigate = useNavigate();

  const navItems = [
    { to: "/exam-booking", label: "Exam Booking", icon: BookOpen },
    { to: "/users", label: "Users", icon: Users },
    { to: "/rewards", label: "Rewards", icon: Award },
  ];

  const handleLogout = async () => {
    const { error } = await supabase.auth.signOut();

    if (error) {
      toast.error("Error logging out. Please try again.");
    } else {
      toast.success("Logged out successfully!");
      navigate("/login"); // Redirect to login page after logout
    }
  };

  return (
    <Sidebar>
      <SidebarHeader>
        <div className="flex flex-col items-center p-4">
          <Avatar className="h-16 w-16 mb-2 bg-gray-200">
            <AvatarImage src="/placeholder-avatar.png" alt="Admin" />
            <AvatarFallback className="text-xl">AD</AvatarFallback>
          </Avatar>
          <h2 className="text-white text-lg font-semibold">Admin D</h2>
        </div>
      </SidebarHeader>

      <SidebarContent>
        <SidebarMenu>
          {navItems.map((item) => (
            <SidebarMenuItem key={item.to}>
              <SidebarMenuButton
                asChild
                isActive={
                  item.to === "/"
                    ? currentPath === "/"
                    : currentPath.startsWith(item.to)
                }
                tooltip={item.label}
              >
                <Link to={item.to}>
                  <item.icon className="h-5 w-5" />
                  <span>{item.label}</span>
                </Link>
              </SidebarMenuButton>
            </SidebarMenuItem>
          ))}
        </SidebarMenu>
      </SidebarContent>

      <SidebarFooter>
        <div className="p-4">
          <SidebarMenuButton className="w-full justify-center bg-red-600 hover:bg-red-700 text-white" onClick={handleLogout}>
            <LogOut className="h-5 w-5 mr-2" />
            <span>Log out</span>
          </SidebarMenuButton>
        </div>
      </SidebarFooter>
    </Sidebar>
  );
};

const DashboardLayout = ({ children }: { children: React.ReactNode }) => {
  const { isMobile } = useSidebar();

  return (
    <div className="flex h-screen w-full overflow-hidden">
      <DashboardSidebar />
      <div className="flex-1 overflow-y-auto bg-dashboard-lightblue">
        <div className="flex items-center p-4 md:hidden">
          <SidebarTrigger />
          <h1 className="text-xl font-bold ml-2">Admin Dashboard</h1>
        </div>
        {children}
      </div>
    </div>
  );
};

export default DashboardLayout;
