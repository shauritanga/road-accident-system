import React from 'react';
import { useAccidentStats, useRecentAccidents } from '../hooks/useAccidents';
import { StatsCards } from './StatsCards';
import { AccidentChart } from './AccidentChart';
import { RecentAccidents } from './RecentAccidents';
import { AccidentMap } from './AccidentMap';
import { LoadingSpinner } from './LoadingSpinner';
import { ErrorMessage } from './ErrorMessage';

export const Dashboard: React.FC = () => {
  const { data: stats, isLoading: statsLoading, error: statsError } = useAccidentStats();
  const { data: recentAccidents, isLoading: accidentsLoading, error: accidentsError } = useRecentAccidents(5);

  if (statsLoading || accidentsLoading) {
    return <LoadingSpinner />;
  }

  if (statsError || accidentsError) {
    return <ErrorMessage message="Failed to load dashboard data" />;
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="py-6">
            <div className="flex items-center justify-between">
              <div>
                <h1 className="text-3xl font-bold text-gray-900">
                  TARURA Dashboard
                </h1>
                <p className="mt-1 text-sm text-gray-500">
                  Tanzania Road and Traffic Authority - Road Accident Information System
                </p>
              </div>
              <div className="flex items-center space-x-4">
                <div className="text-right">
                  <p className="text-sm font-medium text-gray-900">
                    Last Updated
                  </p>
                  <p className="text-sm text-gray-500">
                    {new Date().toLocaleString()}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="space-y-8">
          {/* Stats Cards */}
          {stats && <StatsCards stats={stats} />}

          {/* Charts and Map Row */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
            {/* Accident Charts */}
            <div className="space-y-6">
              {stats && (
                <>
                  <AccidentChart
                    title="Accidents by Type"
                    data={Object.entries(stats.byType).map(([name, value]) => ({
                      name,
                      value,
                    }))}
                    type="pie"
                  />
                  <AccidentChart
                    title="Accidents by Region"
                    data={Object.entries(stats.byRegion)
                      .sort(([, a], [, b]) => b - a)
                      .slice(0, 10)
                      .map(([name, value]) => ({
                        name,
                        value,
                      }))}
                    type="bar"
                  />
                </>
              )}
            </div>

            {/* Map */}
            <div className="bg-white rounded-lg shadow-sm border">
              <div className="p-6 border-b">
                <h3 className="text-lg font-semibold text-gray-900">
                  Accident Hotspots
                </h3>
                <p className="text-sm text-gray-500">
                  Geographic distribution of recent accidents
                </p>
              </div>
              <div className="p-6">
                {recentAccidents && <AccidentMap accidents={recentAccidents} />}
              </div>
            </div>
          </div>

          {/* Recent Accidents and Additional Charts */}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            {/* Recent Accidents */}
            <div className="lg:col-span-2">
              {recentAccidents && <RecentAccidents accidents={recentAccidents} />}
            </div>

            {/* Additional Stats */}
            <div className="space-y-6">
              {stats && (
                <>
                  <AccidentChart
                    title="Accidents by Severity"
                    data={Object.entries(stats.byEffects).map(([name, value]) => ({
                      name,
                      value,
                    }))}
                    type="doughnut"
                  />
                  <AccidentChart
                    title="Weather Conditions"
                    data={Object.entries(stats.byWeather).map(([name, value]) => ({
                      name,
                      value,
                    }))}
                    type="bar"
                    height={200}
                  />
                </>
              )}
            </div>
          </div>

          {/* Monthly Trend */}
          {stats && (
            <div className="bg-white rounded-lg shadow-sm border">
              <div className="p-6 border-b">
                <h3 className="text-lg font-semibold text-gray-900">
                  Monthly Trend
                </h3>
                <p className="text-sm text-gray-500">
                  Accident frequency over the past 12 months
                </p>
              </div>
              <div className="p-6">
                <AccidentChart
                  title=""
                  data={Object.entries(stats.byMonth)
                    .sort(([a], [b]) => a.localeCompare(b))
                    .slice(-12)
                    .map(([name, value]) => ({
                      name: new Date(name + '-01').toLocaleDateString('en-US', {
                        month: 'short',
                        year: 'numeric',
                      }),
                      value,
                    }))}
                  type="line"
                  height={300}
                />
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
