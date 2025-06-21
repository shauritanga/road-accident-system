import React, { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { 
  BarChart, 
  Bar, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  LineChart,
  Line
} from 'recharts';
import { accidentsAPI } from '../services/api';
import LoadingSpinner from '../components/UI/LoadingSpinner';
import { format, subMonths, startOfMonth, endOfMonth } from 'date-fns';

const Analytics = () => {
  const [dateRange, setDateRange] = useState('6months');

  const { data: accidents, isLoading } = useQuery({
    queryKey: ['accidents'],
    queryFn: accidentsAPI.getAll
  });

  if (isLoading) {
    return (
      <div className="flex justify-center items-center h-64">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  // Process data for charts
  const processMonthlyData = () => {
    const months = [];
    const now = new Date();
    
    for (let i = 5; i >= 0; i--) {
      const date = subMonths(now, i);
      const monthStart = startOfMonth(date);
      const monthEnd = endOfMonth(date);
      
      const monthAccidents = accidents?.filter(acc => 
        acc.date >= monthStart && acc.date <= monthEnd
      ) || [];
      
      months.push({
        month: format(date, 'MMM yyyy'),
        accidents: monthAccidents.length,
        fatal: monthAccidents.filter(acc => acc.effects === 'Fatal').length,
        injury: monthAccidents.filter(acc => 
          acc.effects === 'Serious Injury' || acc.effects === 'Minor Injury'
        ).length
      });
    }
    
    return months;
  };

  const processTypeData = () => {
    const typeCount = {};
    accidents?.forEach(acc => {
      typeCount[acc.type] = (typeCount[acc.type] || 0) + 1;
    });
    
    return Object.entries(typeCount).map(([type, count]) => ({
      name: type,
      value: count
    }));
  };

  const processRegionData = () => {
    const regionCount = {};
    accidents?.forEach(acc => {
      regionCount[acc.region] = (regionCount[acc.region] || 0) + 1;
    });
    
    return Object.entries(regionCount)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 10)
      .map(([region, count]) => ({
        region,
        accidents: count
      }));
  };

  const processWeatherData = () => {
    const weatherCount = {};
    accidents?.forEach(acc => {
      weatherCount[acc.weather] = (weatherCount[acc.weather] || 0) + 1;
    });
    
    return Object.entries(weatherCount).map(([weather, count]) => ({
      name: weather,
      value: count
    }));
  };

  const monthlyData = processMonthlyData();
  const typeData = processTypeData();
  const regionData = processRegionData();
  const weatherData = processWeatherData();

  const COLORS = ['#3B82F6', '#EF4444', '#10B981', '#F59E0B', '#8B5CF6', '#06B6D4'];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Analytics</h1>
          <p className="text-gray-600">Accident data analysis and insights</p>
        </div>
        <select
          className="input"
          value={dateRange}
          onChange={(e) => setDateRange(e.target.value)}
        >
          <option value="6months">Last 6 Months</option>
          <option value="1year">Last Year</option>
          <option value="all">All Time</option>
        </select>
      </div>

      {/* Monthly Trends */}
      <div className="card p-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Monthly Accident Trends</h3>
        <div className="h-80">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={monthlyData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="month" />
              <YAxis />
              <Tooltip />
              <Line 
                type="monotone" 
                dataKey="accidents" 
                stroke="#3B82F6" 
                strokeWidth={2}
                name="Total Accidents"
              />
              <Line 
                type="monotone" 
                dataKey="fatal" 
                stroke="#EF4444" 
                strokeWidth={2}
                name="Fatal Accidents"
              />
              <Line 
                type="monotone" 
                dataKey="injury" 
                stroke="#F59E0B" 
                strokeWidth={2}
                name="Injury Accidents"
              />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Charts Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Accident Types */}
        <div className="card p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Accident Types Distribution</h3>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={typeData}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {typeData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Weather Conditions */}
        <div className="card p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Weather Conditions</h3>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={weatherData}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {weatherData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>

      {/* Top Regions */}
      <div className="card p-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Top 10 Regions by Accident Count</h3>
        <div className="h-80">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={regionData} layout="horizontal">
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis type="number" />
              <YAxis dataKey="region" type="category" width={100} />
              <Tooltip />
              <Bar dataKey="accidents" fill="#3B82F6" />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Summary Statistics */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="card p-6 text-center">
          <div className="text-3xl font-bold text-blue-600">
            {accidents?.length || 0}
          </div>
          <div className="text-gray-600">Total Accidents</div>
        </div>
        
        <div className="card p-6 text-center">
          <div className="text-3xl font-bold text-red-600">
            {accidents?.filter(acc => acc.effects === 'Fatal').length || 0}
          </div>
          <div className="text-gray-600">Fatal Accidents</div>
        </div>
        
        <div className="card p-6 text-center">
          <div className="text-3xl font-bold text-orange-600">
            {accidents?.filter(acc => 
              acc.effects === 'Serious Injury' || acc.effects === 'Minor Injury'
            ).length || 0}
          </div>
          <div className="text-gray-600">Injury Accidents</div>
        </div>
      </div>
    </div>
  );
};

export default Analytics;
