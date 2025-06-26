import React from "react";
import { Link } from "react-router-dom";
import { Accident } from "../types";
import { MapPin, Calendar, AlertTriangle, Users, Camera } from "lucide-react";
import { formatDistanceToNow } from "date-fns";

interface RecentAccidentsProps {
  accidents: Accident[];
}

export const RecentAccidents: React.FC<RecentAccidentsProps> = ({
  accidents,
}) => {
  const getSeverityColor = (effects: string) => {
    switch (effects.toLowerCase()) {
      case "fatal":
        return "bg-red-100 text-red-800 border-red-200";
      case "serious injury":
        return "bg-orange-100 text-orange-800 border-orange-200";
      case "minor injury":
        return "bg-yellow-100 text-yellow-800 border-yellow-200";
      case "property damage only":
        return "bg-blue-100 text-blue-800 border-blue-200";
      default:
        return "bg-gray-100 text-gray-800 border-gray-200";
    }
  };

  const getSeverityIcon = (effects: string) => {
    switch (effects.toLowerCase()) {
      case "fatal":
        return <AlertTriangle className="h-4 w-4" />;
      case "serious injury":
      case "minor injury":
        return <Users className="h-4 w-4" />;
      default:
        return <AlertTriangle className="h-4 w-4" />;
    }
  };

  return (
    <div className="bg-white rounded-lg shadow-sm border">
      <div className="p-6 border-b">
        <h3 className="text-lg font-semibold text-gray-900">
          Recent Accidents
        </h3>
        <p className="text-sm text-gray-500">
          Latest accident reports from the field
        </p>
      </div>
      <div className="divide-y divide-gray-200">
        {accidents.map((accident) => (
          <Link
            key={accident.id}
            to={`/accidents/${accident.id}`}
            className="block p-6 hover:bg-gray-50 transition-colors"
          >
            <div className="flex items-start justify-between">
              <div className="flex-1 min-w-0">
                {/* Header */}
                <div className="flex items-center space-x-3 mb-3">
                  <span
                    className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border ${getSeverityColor(
                      accident.effects
                    )}`}
                  >
                    {getSeverityIcon(accident.effects)}
                    <span className="ml-1">{accident.effects}</span>
                  </span>
                  <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                    {accident.type}
                  </span>
                </div>

                {/* Location */}
                <div className="flex items-center text-sm text-gray-900 mb-2">
                  <MapPin className="h-4 w-4 text-gray-400 mr-2" />
                  <span className="font-medium">{accident.roadName}</span>
                  <span className="mx-2 text-gray-400">•</span>
                  <span>
                    {accident.area}, {accident.district}
                  </span>
                  <span className="mx-2 text-gray-400">•</span>
                  <span className="text-blue-600 font-medium">
                    {accident.region}
                  </span>
                </div>

                {/* Details */}
                <div className="grid grid-cols-2 gap-4 text-sm text-gray-600 mb-3">
                  <div className="flex items-center">
                    <Calendar className="h-4 w-4 text-gray-400 mr-2" />
                    <span>{accident.date.toLocaleDateString()}</span>
                  </div>
                  <div className="flex items-center">
                    <span className="font-medium mr-2">Weather:</span>
                    <span>{accident.weather}</span>
                  </div>
                  <div className="flex items-center">
                    <span className="font-medium mr-2">Visibility:</span>
                    <span>{accident.visibility}</span>
                  </div>
                  {accident.involvedParties.length > 0 && (
                    <div className="flex items-center">
                      <Users className="h-4 w-4 text-gray-400 mr-2" />
                      <span>
                        {accident.involvedParties.length} parties involved
                      </span>
                    </div>
                  )}
                </div>

                {/* Environmental Factors */}
                {accident.environmentalFactors &&
                  accident.environmentalFactors !== "None" && (
                    <div className="text-sm text-gray-600 mb-2">
                      <span className="font-medium">
                        Environmental factors:
                      </span>{" "}
                      {accident.environmentalFactors}
                    </div>
                  )}

                {/* Physiological Issues */}
                {accident.physiologicalIssues &&
                  accident.physiologicalIssues !== "None" && (
                    <div className="text-sm text-gray-600 mb-2">
                      <span className="font-medium">Physiological issues:</span>{" "}
                      {accident.physiologicalIssues}
                    </div>
                  )}

                {/* Photos */}
                {accident.photoUrls.length > 0 && (
                  <div className="flex items-center text-sm text-gray-600">
                    <Camera className="h-4 w-4 text-gray-400 mr-2" />
                    <span>
                      {accident.photoUrls.length} photo
                      {accident.photoUrls.length > 1 ? "s" : ""} available
                    </span>
                  </div>
                )}
              </div>

              {/* Time ago */}
              <div className="text-right">
                <p className="text-sm text-gray-500">
                  {formatDistanceToNow(accident.createdAt, { addSuffix: true })}
                </p>
                <span className="mt-2 text-sm text-blue-600 font-medium inline-block">
                  View Details →
                </span>
              </div>
            </div>
          </Link>
        ))}
      </div>

      {accidents.length === 0 && (
        <div className="p-12 text-center">
          <AlertTriangle className="h-12 w-12 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">
            No recent accidents
          </h3>
          <p className="text-gray-500">
            No accident reports have been submitted recently.
          </p>
        </div>
      )}
    </div>
  );
};
