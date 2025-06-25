import React from 'react';
import { useAccidentStats } from '../hooks/useAccidents';
import { LoadingSpinner } from './LoadingSpinner';
import { ErrorMessage } from './ErrorMessage';
import { AccidentChart } from './AccidentChart';

export const Analytics: React.FC = () => {
  const { data: stats, isLoading, error } = useAccidentStats();

  if (isLoading) {
    return <LoadingSpinner message="Loading analytics..." />;
  }

  if (error) {
    return <ErrorMessage message="Failed to load analytics data" />;
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="py-6">
            <h1 className="text-3xl font-bold text-gray-900">
              Advanced Analytics
            </h1>
            <p className="mt-1 text-sm text-gray-500">
              Deep insights into accident patterns and trends
            </p>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
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
                data={Object.entries(stats.byRegion).map(([name, value]) => ({
                  name,
                  value,
                }))}
                type="bar"
              />
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
              />
            </>
          )}
        </div>
      </div>
    </div>
  );
};
