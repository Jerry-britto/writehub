
import React from "react";
import DashboardLayout from "@/components/dashboard/DashboardLayout";
import StatCard from "@/components/dashboard/StatCard";
import BarChartComponent from "@/components/dashboard/BarChartComponent";
import PieChartComponent from "@/components/dashboard/PieChartComponent";
import LineChartComponent from "@/components/dashboard/LineChartComponent";
import { BookOpen, Users, Award, CheckCircle } from "lucide-react";

const Dashboard = () => {
  // Sample data for charts
  const barChartData = [
    { name: "0", primary: 80, secondary: 65 },
    { name: "1", primary: 50, secondary: 60 },
    { name: "2", primary: 30, secondary: 40 },
    { name: "3", primary: 60, secondary: 65 },
    { name: "4", primary: 90, secondary: 85 },
    { name: "5", primary: 20, secondary: 45 },
    { name: "6", primary: 55, secondary: 70 },
    { name: "7", primary: 60, secondary: 70 },
    { name: "8", primary: 30, secondary: 65 },
    { name: "9", primary: 65, secondary: 70 },
  ];

  const pieChartData = [
    { name: "Chrome", value: 52.57, color: "#4285F4" },
    { name: "Firefox", value: 31.17, color: "#4CAF50" },
    { name: "Safari", value: 4.29, color: "#FFC107" },
    { name: "Edge", value: 2.91, color: "#2277D3" },
    { name: "Opera", value: 2.47, color: "#E91E63" },
    { name: "Other", value: 2.36, color: "#9C27B0" },
    { name: "Samsung Internet", value: 4.23, color: "#3F51B5" },
  ];

  const lineChartData = [
    { name: "0", primary: 80, secondary: 40 },
    { name: "1", primary: 30, secondary: 60 },
    { name: "2", primary: 5, secondary: 40 },
    { name: "3", primary: 60, secondary: 20 },
    { name: "4", primary: 10, secondary: 45 },
    { name: "5", primary: 95, secondary: 65 },
    { name: "6", primary: 0, secondary: 70 },
    { name: "7", primary: 50, secondary: 40 },
    { name: "8", primary: 90, secondary: 70 },
    { name: "9", primary: 50, secondary: 40 },
  ];

  return (
    <DashboardLayout>
      <div className="p-4 md:p-8">
        <h1 className="text-2xl md:text-3xl font-bold mb-6 md:mb-8 hidden md:block">Greetings Admin</h1>

        {/* Stats Row */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 md:gap-6 mb-6 md:mb-8">
          <StatCard 
            title="Total Exams" 
            value="247" 
            icon={<BookOpen className="h-5 w-5 md:h-6 md:w-6" />} 
          />
          <StatCard 
            title="Total Users" 
            value="1,528" 
            icon={<Users className="h-5 w-5 md:h-6 md:w-6" />} 
          />
          <StatCard 
            title="Rewards Given" 
            value="648" 
            icon={<Award className="h-5 w-5 md:h-6 md:w-6" />} 
          />
          <StatCard 
            title="Completion Rate" 
            value="86%" 
            icon={<CheckCircle className="h-5 w-5 md:h-6 md:w-6" />} 
          />
        </div>

        {/* Charts */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 md:gap-6 mb-6 md:mb-8">
          <BarChartComponent data={barChartData} />
          <PieChartComponent data={pieChartData} />
        </div>

        <div className="mb-6 md:mb-8">
          <LineChartComponent data={lineChartData} />
        </div>
      </div>
    </DashboardLayout>
  );
};

export default Dashboard;
