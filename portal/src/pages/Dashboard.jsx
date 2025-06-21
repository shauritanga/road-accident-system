import React from 'react';
import { useQuery } from '@tanstack/react-query';
import {
  ExclamationTriangleIcon,
  UsersIcon,
  ChartBarIcon,
  ClockIcon
} from '@heroicons/react/24/outline';
import { statisticsAPI, accidentsAPI } from '../services/api';
import StatCard from '../components/UI/StatCard';
import LoadingSpinner from '../components/UI/LoadingSpinner';
import { format } from 'date-fns';

const Dashboard = () => {
  const { data: overview, isLoading: overviewLoading } = useQuery({
    queryKey: ['overview'],
    queryFn: statisticsAPI.getOverview
  });

  const { data: recentAccidents, isLoading: accidentsLoading } = useQuery({
    queryKey: ['recent-accidents'],
    queryFn: () => accidentsAPI.getRecent(5)
  });

  if (overviewLoading) {
    return (
      <div className="flex justify-center items-center h-64">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  const getSeverityColor = (effects) => {
    switch (effects) {
      case 'Fatal':
        return 'text-red-600 bg-red-100';
      case 'Serious Injury':
        return 'text-orange-600 bg-orange-100';
      case 'Minor Injury':
        return 'text-yellow-600 bg-yellow-100';
      default:
        return 'text-blue-600 bg-blue-100';
    }
  };

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-gray-600">Overview of road accident information system</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          title="Total Accidents"
          value={overview?.totalAccidents || 0}
          icon={ExclamationTriangleIcon}
          color="blue"
        />
        <StatCard
          title="This Month"
          value={overview?.thisMonthAccidents || 0}
          icon={ChartBarIcon}
          color="green"
          trend={{
            type: overview?.thisMonthAccidents > overview?.lastMonthAccidents ? 'increase' : 'decrease',
            value: `${Math.abs((overview?.thisMonthAccidents || 0) - (overview?.lastMonthAccidents || 0))}`
          }}
        />
        <StatCard
          title="Fatal Accidents"
          value={overview?.fatalAccidents || 0}
          icon={ExclamationTriangleIcon}
          color="red"
        />
        <StatCard
          title="Total Users"
          value={overview?.totalUsers || 0}
          icon={UsersIcon}
          color="purple"
        />
      </div>

      {/* Recent Accidents */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="card p-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-gray-900">Recent Accidents</h3>
            <ClockIcon className="h-5 w-5 text-gray-400" />
          </div>
          
          {accidentsLoading ? (
            <LoadingSpinner />
          ) : (
            <div className="space-y-4">
              {recentAccidents?.length > 0 ? (
                recentAccidents.map((accident) => (
                  <div key={accident.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                    <div className="flex-1">
                      <div className="flex items-center space-x-2">
                        <span className="font-medium text-gray-900">
                          {accident.road_name}
                        </span>
                        <span className={`
                          px-2 py-1 text-xs font-medium rounded-full
                          ${getSeverityColor(accident.effects)}
                        `}>
                          {accident.effects}
                        </span>
                      </div>
                      <p className="text-sm text-gray-600">
                        {accident.area}, {accident.region}
                      </p>
                      <p className="text-xs text-gray-500">
                        {format(accident.created_at, 'MMM dd, yyyy HH:mm')}
                      </p>
                    </div>
                  </div>
                ))
              ) : (
                <p className="text-gray-500 text-center py-4">No recent accidents</p>
              )}
            </div>
          )}
        </div>

        {/* Quick Stats */}
        <div className="card p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Quick Statistics</h3>
          <div className="space-y-4">
            <div className="flex justify-between items-center">
              <span className="text-gray-600">Fatal Accidents</span>
              <span className="font-semibold text-red-600">
                {overview?.fatalAccidents || 0}
              </span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-gray-600">Injury Accidents</span>
              <span className="font-semibold text-orange-600">
                {overview?.injuryAccidents || 0}
              </span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-gray-600">This Month</span>
              <span className="font-semibold text-blue-600">
                {overview?.thisMonthAccidents || 0}
              </span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-gray-600">Last Month</span>
              <span className="font-semibold text-gray-600">
                {overview?.lastMonthAccidents || 0}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
