import React from 'react';
import { Download, FileText, Calendar } from 'lucide-react';

export const Reports: React.FC = () => {
  const reportTypes = [
    {
      title: 'Monthly Summary Report',
      description: 'Comprehensive monthly accident statistics and trends',
      icon: Calendar,
      format: 'PDF',
    },
    {
      title: 'Regional Analysis Report',
      description: 'Detailed breakdown by regions and districts',
      icon: FileText,
      format: 'Excel',
    },
    {
      title: 'Safety Recommendations',
      description: 'Data-driven safety improvement recommendations',
      icon: FileText,
      format: 'PDF',
    },
  ];

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="py-6">
            <h1 className="text-3xl font-bold text-gray-900">
              Reports & Exports
            </h1>
            <p className="mt-1 text-sm text-gray-500">
              Generate and download comprehensive reports
            </p>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {reportTypes.map((report, index) => {
            const Icon = report.icon;
            return (
              <div key={index} className="bg-white rounded-lg shadow-sm border p-6">
                <div className="flex items-center mb-4">
                  <div className="bg-blue-100 p-3 rounded-lg">
                    <Icon className="h-6 w-6 text-blue-600" />
                  </div>
                  <div className="ml-4">
                    <h3 className="text-lg font-semibold text-gray-900">
                      {report.title}
                    </h3>
                    <span className="text-sm text-gray-500">{report.format}</span>
                  </div>
                </div>
                <p className="text-gray-600 mb-4">{report.description}</p>
                <button className="w-full inline-flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700">
                  <Download className="h-4 w-4 mr-2" />
                  Generate Report
                </button>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};
