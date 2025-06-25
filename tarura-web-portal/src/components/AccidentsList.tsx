import React, { useState } from "react";
import { useAccidents, useConfig } from "../hooks/useAccidents";
import { AccidentFilters } from "../types";
import { LoadingSpinner } from "./LoadingSpinner";
import { ErrorMessage } from "./ErrorMessage";
import { AccidentFilters as AccidentFiltersComponent } from "./AccidentFilters";
import { AccidentTable } from "./AccidentTable";
import { AccidentMap } from "./AccidentMap";
import { Download, Map, List } from "lucide-react";

export const AccidentsList: React.FC = () => {
  const [filters, setFilters] = useState<AccidentFilters>({});
  const [viewMode, setViewMode] = useState<"table" | "map">("table");

  const { data: accidents, isLoading, error, refetch } = useAccidents(filters);
  const { data: config } = useConfig();

  const handleFiltersChange = (newFilters: AccidentFilters) => {
    setFilters(newFilters);
  };

  const handleExport = () => {
    // TODO: Implement export functionality
    console.log("Export accidents with filters:", filters);
  };

  if (isLoading) {
    return <LoadingSpinner message="Loading accidents data..." />;
  }

  if (error) {
    return (
      <ErrorMessage message="Failed to load accidents data" onRetry={refetch} />
    );
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
                  Accident Records
                </h1>
                <p className="mt-1 text-sm text-gray-500">
                  Comprehensive view of all reported accidents
                </p>
              </div>
              <div className="flex items-center space-x-4">
                {/* View Mode Toggle */}
                <div className="flex rounded-lg border border-gray-300 bg-white">
                  <button
                    onClick={() => setViewMode("table")}
                    className={`px-4 py-2 text-sm font-medium rounded-l-lg transition-colors ${
                      viewMode === "table"
                        ? "bg-blue-600 text-white"
                        : "text-gray-700 hover:bg-gray-50"
                    }`}
                  >
                    <List className="h-4 w-4 mr-2 inline" />
                    Table
                  </button>
                  <button
                    onClick={() => setViewMode("map")}
                    className={`px-4 py-2 text-sm font-medium rounded-r-lg transition-colors ${
                      viewMode === "map"
                        ? "bg-blue-600 text-white"
                        : "text-gray-700 hover:bg-gray-50"
                    }`}
                  >
                    <Map className="h-4 w-4 mr-2 inline" />
                    Map
                  </button>
                </div>

                {/* Export Button */}
                <button
                  onClick={handleExport}
                  className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                >
                  <Download className="h-4 w-4 mr-2" />
                  Export
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="space-y-6">
          {/* Filters */}
          {config && (
            <AccidentFiltersComponent
              config={config}
              filters={filters}
              onFiltersChange={handleFiltersChange}
            />
          )}

          {/* Results Count */}
          <div className="bg-white rounded-lg shadow-sm border p-4">
            <p className="text-sm text-gray-600">
              Showing{" "}
              <span className="font-medium">{accidents?.length || 0}</span>{" "}
              accidents
              {Object.keys(filters).length > 0 && " matching your filters"}
            </p>
          </div>

          {/* Content based on view mode */}
          {viewMode === "table" ? (
            <AccidentTable accidents={accidents || []} />
          ) : (
            <div className="bg-white rounded-lg shadow-sm border">
              <div className="p-6 border-b">
                <h3 className="text-lg font-semibold text-gray-900">
                  Accident Locations
                </h3>
                <p className="text-sm text-gray-500">
                  Geographic distribution of accidents
                </p>
              </div>
              <div className="p-6">
                <AccidentMap accidents={accidents || []} height="600px" />
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
