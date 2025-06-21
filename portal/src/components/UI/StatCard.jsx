import React from 'react';

const StatCard = ({ 
  title, 
  value, 
  icon: Icon, 
  color = 'blue', 
  trend = null,
  className = '' 
}) => {
  const colorClasses = {
    blue: 'bg-blue-500 text-blue-600',
    red: 'bg-red-500 text-red-600',
    green: 'bg-green-500 text-green-600',
    yellow: 'bg-yellow-500 text-yellow-600',
    purple: 'bg-purple-500 text-purple-600',
    indigo: 'bg-indigo-500 text-indigo-600'
  };

  const bgColorClasses = {
    blue: 'bg-blue-50',
    red: 'bg-red-50',
    green: 'bg-green-50',
    yellow: 'bg-yellow-50',
    purple: 'bg-purple-50',
    indigo: 'bg-indigo-50'
  };

  return (
    <div className={`card p-6 ${className}`}>
      <div className="flex items-center">
        <div className={`
          flex-shrink-0 p-3 rounded-lg ${bgColorClasses[color]}
        `}>
          <Icon className={`h-6 w-6 ${colorClasses[color].split(' ')[1]}`} />
        </div>
        
        <div className="ml-4 flex-1">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">{title}</p>
              <p className="text-2xl font-bold text-gray-900">{value}</p>
            </div>
            
            {trend && (
              <div className={`
                flex items-center text-sm font-medium
                ${trend.type === 'increase' ? 'text-green-600' : 'text-red-600'}
              `}>
                <span>{trend.value}</span>
                {trend.type === 'increase' ? (
                  <svg className="ml-1 h-4 w-4" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M5.293 9.707a1 1 0 010-1.414l4-4a1 1 0 011.414 0l4 4a1 1 0 01-1.414 1.414L11 7.414V15a1 1 0 11-2 0V7.414L6.707 9.707a1 1 0 01-1.414 0z" clipRule="evenodd" />
                  </svg>
                ) : (
                  <svg className="ml-1 h-4 w-4" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M14.707 10.293a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 111.414-1.414L9 12.586V5a1 1 0 012 0v7.586l2.293-2.293a1 1 0 011.414 0z" clipRule="evenodd" />
                  </svg>
                )}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default StatCard;
