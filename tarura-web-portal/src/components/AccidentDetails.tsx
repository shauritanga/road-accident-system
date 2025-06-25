import React from 'react';
import { useParams } from 'react-router-dom';
import { useAccidentById } from '../hooks/useAccidents';
import { LoadingSpinner } from './LoadingSpinner';
import { ErrorMessage } from './ErrorMessage';

export const AccidentDetails: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const { data: accident, isLoading, error } = useAccidentById(id!);

  if (isLoading) {
    return <LoadingSpinner message="Loading accident details..." />;
  }

  if (error || !accident) {
    return <ErrorMessage message="Failed to load accident details" />;
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="bg-white rounded-lg shadow-sm border p-6">
          <h1 className="text-2xl font-bold text-gray-900 mb-4">
            Accident Details
          </h1>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <h3 className="font-semibold">Location</h3>
              <p>{accident.roadName}, {accident.area}</p>
              <p>{accident.district}, {accident.region}</p>
            </div>
            <div>
              <h3 className="font-semibold">Type</h3>
              <p>{accident.type}</p>
            </div>
            <div>
              <h3 className="font-semibold">Severity</h3>
              <p>{accident.effects}</p>
            </div>
            <div>
              <h3 className="font-semibold">Date</h3>
              <p>{accident.date.toLocaleDateString()}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
