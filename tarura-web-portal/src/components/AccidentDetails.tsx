import React from "react";
import { useParams, Link } from "react-router-dom";
import { useAccidentById } from "../hooks/useAccidents";
import { LoadingSpinner } from "./LoadingSpinner";
import { ErrorMessage } from "./ErrorMessage";
import { AccidentMap } from "./AccidentMap";
import {
  ArrowLeft,
  MapPin,
  Calendar,
  AlertTriangle,
  Cloud,
  Eye,
  Users,
  Camera,
  Clock,
  Navigation,
} from "lucide-react";

export const AccidentDetails: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const { data: accident, isLoading, error } = useAccidentById(id!);

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <LoadingSpinner message="Loading accident details..." />
      </div>
    );
  }

  if (error || !accident) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <ErrorMessage message="Failed to load accident details" />
      </div>
    );
  }

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

  const formatDateTime = (date: Date) => {
    return {
      date: date.toLocaleDateString("en-US", {
        weekday: "long",
        year: "numeric",
        month: "long",
        day: "numeric",
      }),
      time: date.toLocaleTimeString("en-US", {
        hour: "2-digit",
        minute: "2-digit",
      }),
    };
  };

  const dateTime = formatDateTime(accident.date);

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Header */}
        <div className="mb-6">
          <Link
            to="/accidents"
            className="inline-flex items-center text-blue-600 hover:text-blue-800 mb-4"
          >
            <ArrowLeft className="w-4 h-4 mr-2" />
            Back to Accidents
          </Link>
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">
                Accident Details
              </h1>
              <p className="text-gray-600 mt-1">Incident ID: {accident.id}</p>
            </div>
            <div
              className={`px-4 py-2 rounded-full border ${getSeverityColor(
                accident.effects
              )}`}
            >
              <div className="flex items-center">
                <AlertTriangle className="w-4 h-4 mr-2" />
                <span className="font-medium">{accident.effects}</span>
              </div>
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-2 space-y-6">
            {/* Location Map */}
            <div className="bg-white rounded-lg shadow-sm border">
              <div className="p-6 border-b">
                <h2 className="text-xl font-semibold text-gray-900 flex items-center">
                  <MapPin className="w-5 h-5 mr-2 text-blue-600" />
                  Accident Location
                </h2>
              </div>
              <div className="p-6">
                <AccidentMap accidents={[accident]} height="400px" />
                <div className="mt-4 p-4 bg-gray-50 rounded-lg">
                  <div className="flex items-center text-sm text-gray-600">
                    <Navigation className="w-4 h-4 mr-2" />
                    <span>
                      Coordinates: {accident.location.latitude.toFixed(6)},{" "}
                      {accident.location.longitude.toFixed(6)}
                    </span>
                  </div>
                </div>
              </div>
            </div>

            {/* Accident Details */}
            <div className="bg-white rounded-lg shadow-sm border">
              <div className="p-6 border-b">
                <h2 className="text-xl font-semibold text-gray-900">
                  Incident Information
                </h2>
              </div>
              <div className="p-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="space-y-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Accident Type
                      </label>
                      <div className="flex items-center">
                        <AlertTriangle className="w-4 h-4 mr-2 text-orange-500" />
                        <span className="text-gray-900">{accident.type}</span>
                      </div>
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Weather Conditions
                      </label>
                      <div className="flex items-center">
                        <Cloud className="w-4 h-4 mr-2 text-blue-500" />
                        <span className="text-gray-900">
                          {accident.weather}
                        </span>
                      </div>
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Visibility
                      </label>
                      <div className="flex items-center">
                        <Eye className="w-4 h-4 mr-2 text-purple-500" />
                        <span className="text-gray-900">
                          {accident.visibility}
                        </span>
                      </div>
                    </div>
                  </div>

                  <div className="space-y-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Physiological Issues
                      </label>
                      <p className="text-gray-900">
                        {accident.physiologicalIssues || "None reported"}
                      </p>
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Environmental Factors
                      </label>
                      <p className="text-gray-900">
                        {accident.environmentalFactors || "None reported"}
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Involved Parties */}
            {accident.involvedParties &&
              accident.involvedParties.length > 0 && (
                <div className="bg-white rounded-lg shadow-sm border">
                  <div className="p-6 border-b">
                    <h2 className="text-xl font-semibold text-gray-900 flex items-center">
                      <Users className="w-5 h-5 mr-2 text-green-600" />
                      Involved Parties
                    </h2>
                  </div>
                  <div className="p-6">
                    <div className="space-y-4">
                      {accident.involvedParties.map((party, index) => (
                        <div
                          key={index}
                          className="border border-gray-200 rounded-lg p-4"
                        >
                          <div className="flex items-center mb-2">
                            <span className="bg-blue-100 text-blue-800 text-xs font-medium px-2.5 py-0.5 rounded">
                              {party.type}
                            </span>
                          </div>
                          <p className="text-gray-900">{party.details}</p>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              )}

            {/* Photos */}
            {accident.photoUrls && accident.photoUrls.length > 0 && (
              <div className="bg-white rounded-lg shadow-sm border">
                <div className="p-6 border-b">
                  <h2 className="text-xl font-semibold text-gray-900 flex items-center">
                    <Camera className="w-5 h-5 mr-2 text-indigo-600" />
                    Accident Photos
                  </h2>
                </div>
                <div className="p-6">
                  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    {accident.photoUrls.map((url, index) => (
                      <div key={index} className="relative group">
                        <img
                          src={url}
                          alt={`Evidence ${index + 1}`}
                          className="w-full h-48 object-cover rounded-lg shadow-sm group-hover:shadow-md transition-shadow"
                        />
                        <div className="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-20 transition-opacity rounded-lg"></div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            )}
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Quick Summary */}
            <div className="bg-white rounded-lg shadow-sm border">
              <div className="p-6 border-b">
                <h2 className="text-xl font-semibold text-gray-900">
                  Quick Summary
                </h2>
              </div>
              <div className="p-6 space-y-4">
                <div className="flex items-center">
                  <Calendar className="w-5 h-5 mr-3 text-gray-400" />
                  <div>
                    <p className="text-sm font-medium text-gray-900">
                      {dateTime.date}
                    </p>
                    <p className="text-sm text-gray-500">{dateTime.time}</p>
                  </div>
                </div>

                <div className="flex items-center">
                  <Clock className="w-5 h-5 mr-3 text-gray-400" />
                  <div>
                    <p className="text-sm font-medium text-gray-900">
                      Reported
                    </p>
                    <p className="text-sm text-gray-500">
                      {accident.createdAt.toLocaleDateString()}
                    </p>
                  </div>
                </div>

                <div className="flex items-start">
                  <MapPin className="w-5 h-5 mr-3 text-gray-400 mt-0.5" />
                  <div>
                    <p className="text-sm font-medium text-gray-900">
                      Location
                    </p>
                    <p className="text-sm text-gray-500">{accident.roadName}</p>
                    <p className="text-sm text-gray-500">
                      {accident.area}, {accident.ward}
                    </p>
                    <p className="text-sm text-gray-500">
                      {accident.district}, {accident.region}
                    </p>
                  </div>
                </div>
              </div>
            </div>

            {/* Additional Points */}
            {accident.additionalPoints &&
              accident.additionalPoints.length > 0 && (
                <div className="bg-white rounded-lg shadow-sm border">
                  <div className="p-6 border-b">
                    <h2 className="text-xl font-semibold text-gray-900">
                      Additional Points
                    </h2>
                  </div>
                  <div className="p-6">
                    <div className="space-y-3">
                      {accident.additionalPoints.map((point, index) => (
                        <div key={index} className="flex items-center text-sm">
                          <MapPin className="w-4 h-4 mr-2 text-blue-500" />
                          <span className="text-gray-600">
                            {point.latitude.toFixed(6)},{" "}
                            {point.longitude.toFixed(6)}
                          </span>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              )}

            {/* Statistics */}
            <div className="bg-white rounded-lg shadow-sm border">
              <div className="p-6 border-b">
                <h2 className="text-xl font-semibold text-gray-900">
                  Statistics
                </h2>
              </div>
              <div className="p-6 space-y-4">
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">
                    Involved Parties
                  </span>
                  <span className="text-sm font-medium text-gray-900">
                    {accident.involvedParties?.length || 0}
                  </span>
                </div>

                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Photos</span>
                  <span className="text-sm font-medium text-gray-900">
                    {accident.photoUrls?.length || 0}
                  </span>
                </div>

                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">
                    Additional Points
                  </span>
                  <span className="text-sm font-medium text-gray-900">
                    {accident.additionalPoints?.length || 0}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
