import React from 'react';
import { AccidentStats } from '../types';
import { TrendingUp, TrendingDown, AlertTriangle, Users, MapPin, Calendar } from 'lucide-react';

interface StatsCardsProps {
  stats: AccidentStats;
}

export const StatsCards: React.FC<StatsCardsProps> = ({ stats }) => {
  const formatTrend = (trend: number) => {
    const isPositive = trend > 0;
    const TrendIcon = isPositive ? TrendingUp : TrendingDown;
    const colorClass = isPositive ? 'text-red-600' : 'text-green-600';
    
    return (
      <div className={`flex items-center ${colorClass}`}>
        <TrendIcon className="h-4 w-4 mr-1" />
        <span className="text-sm font-medium">
          {Math.abs(trend).toFixed(1)}%
        </span>
      </div>
    );
  };

  const fatalAccidents = stats.byEffects['Fatal'] || 0;
  const seriousInjuries = stats.byEffects['Serious Injury'] || 0;
  const minorInjuries = stats.byEffects['Minor Injury'] || 0;
  const propertyDamage = stats.byEffects['Property Damage Only'] || 0;

  const totalRegions = Object.keys(stats.byRegion).length;
  const mostAffectedRegion = Object.entries(stats.byRegion)
    .sort(([, a], [, b]) => b - a)[0];

  const thisMonth = new Date().toISOString().substring(0, 7);
  const thisMonthAccidents = stats.byMonth[thisMonth] || 0;

  const cards = [
    {
      title: 'Total Accidents',
      value: stats.total.toLocaleString(),
      icon: AlertTriangle,
      trend: stats.recentTrend,
      subtitle: 'All time',
      color: 'bg-red-500',
    },
    {
      title: 'Fatal Accidents',
      value: fatalAccidents.toLocaleString(),
      icon: AlertTriangle,
      subtitle: `${((fatalAccidents / stats.total) * 100).toFixed(1)}% of total`,
      color: 'bg-red-700',
    },
    {
      title: 'Serious Injuries',
      value: seriousInjuries.toLocaleString(),
      icon: Users,
      subtitle: `${((seriousInjuries / stats.total) * 100).toFixed(1)}% of total`,
      color: 'bg-orange-500',
    },
    {
      title: 'Minor Injuries',
      value: minorInjuries.toLocaleString(),
      icon: Users,
      subtitle: `${((minorInjuries / stats.total) * 100).toFixed(1)}% of total`,
      color: 'bg-yellow-500',
    },
    {
      title: 'Property Damage',
      value: propertyDamage.toLocaleString(),
      icon: AlertTriangle,
      subtitle: `${((propertyDamage / stats.total) * 100).toFixed(1)}% of total`,
      color: 'bg-blue-500',
    },
    {
      title: 'Affected Regions',
      value: totalRegions.toLocaleString(),
      icon: MapPin,
      subtitle: mostAffectedRegion ? `${mostAffectedRegion[0]} (${mostAffectedRegion[1]})` : 'No data',
      color: 'bg-purple-500',
    },
    {
      title: 'This Month',
      value: thisMonthAccidents.toLocaleString(),
      icon: Calendar,
      subtitle: new Date().toLocaleDateString('en-US', { month: 'long', year: 'numeric' }),
      color: 'bg-green-500',
    },
  ];

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 xl:grid-cols-7 gap-6">
      {cards.map((card, index) => {
        const Icon = card.icon;
        
        return (
          <div
            key={index}
            className="bg-white rounded-lg shadow-sm border hover:shadow-md transition-shadow duration-200"
          >
            <div className="p-6">
              <div className="flex items-center justify-between">
                <div className="flex-1">
                  <p className="text-sm font-medium text-gray-600 mb-1">
                    {card.title}
                  </p>
                  <p className="text-2xl font-bold text-gray-900 mb-1">
                    {card.value}
                  </p>
                  <p className="text-xs text-gray-500">
                    {card.subtitle}
                  </p>
                  {card.trend !== undefined && (
                    <div className="mt-2">
                      {formatTrend(card.trend)}
                    </div>
                  )}
                </div>
                <div className={`${card.color} p-3 rounded-lg`}>
                  <Icon className="h-6 w-6 text-white" />
                </div>
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
};
