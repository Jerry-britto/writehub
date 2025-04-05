
import React from "react";

type StatCardProps = {
  title: string;
  value: string | number;
  icon?: React.ReactNode;
  color?: string;
};

const StatCard = ({ title, value, icon, color = "white" }: StatCardProps) => {
  return (
    <div className={`stats-card bg-${color}`}>
      <div className="flex justify-between items-center">
        {icon && <div className="text-gray-500">{icon}</div>}
        <div className={icon ? "text-right" : ""}>
          <p className="text-xs sm:text-sm text-gray-500 font-medium">{title}</p>
          <h3 className="text-xl sm:text-2xl font-bold">{value}</h3>
        </div>
      </div>
    </div>
  );
};

export default StatCard;
