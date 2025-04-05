
import React from "react";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts";

type BarChartData = {
  name: string;
  primary: number;
  secondary: number;
};

const BarChartComponent = ({ data }: { data: BarChartData[] }) => {
  return (
    <div className="chart-container bg-dashboard-pink">
      <h3 className="text-lg font-semibold mb-4">Monthly Statistics</h3>
      <div className="h-[300px]">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart
            data={data}
            margin={{
              top: 5,
              right: 30,
              left: 20,
              bottom: 5,
            }}
          >
            <CartesianGrid strokeDasharray="3 3" vertical={false} />
            <XAxis dataKey="name" />
            <YAxis domain={[0, 100]} />
            <Tooltip />
            <Bar dataKey="primary" fill="#8b5cf6" radius={[4, 4, 0, 0]} />
            <Bar dataKey="secondary" fill="#84cc16" radius={[4, 4, 0, 0]} />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
};

export default BarChartComponent;
