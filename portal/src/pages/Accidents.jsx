import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { 
  TrashIcon, 
  EyeIcon, 
  FunnelIcon,
  MagnifyingGlassIcon 
} from '@heroicons/react/24/outline';
import { accidentsAPI } from '../services/api';
import LoadingSpinner from '../components/UI/LoadingSpinner';
import { format } from 'date-fns';
import toast from 'react-hot-toast';

const Accidents = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [filterType, setFilterType] = useState('all');
  const [selectedAccident, setSelectedAccident] = useState(null);
  const queryClient = useQueryClient();

  const { data: accidents, isLoading } = useQuery({
    queryKey: ['accidents'],
    queryFn: accidentsAPI.getAll
  });

  const deleteMutation = useMutation({
    mutationFn: accidentsAPI.delete,
    onSuccess: () => {
      queryClient.invalidateQueries(['accidents']);
      toast.success('Accident deleted successfully');
    },
    onError: (error) => {
      toast.error('Error deleting accident');
    }
  });

  const handleDelete = async (id) => {
    if (window.confirm('Are you sure you want to delete this accident record?')) {
      deleteMutation.mutate(id);
    }
  };

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

  const filteredAccidents = accidents?.filter(accident => {
    const matchesSearch = accident.road_name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         accident.area?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         accident.region?.toLowerCase().includes(searchTerm.toLowerCase());
    
    const matchesFilter = filterType === 'all' || accident.effects === filterType;
    
    return matchesSearch && matchesFilter;
  }) || [];

  if (isLoading) {
    return (
      <div className="flex justify-center items-center h-64">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Accidents</h1>
          <p className="text-gray-600">Manage accident records</p>
        </div>
      </div>

      {/* Filters */}
      <div className="card p-4">
        <div className="flex flex-col sm:flex-row gap-4">
          <div className="flex-1">
            <div className="relative">
              <MagnifyingGlassIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <input
                type="text"
                placeholder="Search accidents..."
                className="input pl-10"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>
          </div>
          <div className="flex items-center space-x-2">
            <FunnelIcon className="h-5 w-5 text-gray-400" />
            <select
              className="input"
              value={filterType}
              onChange={(e) => setFilterType(e.target.value)}
            >
              <option value="all">All Types</option>
              <option value="Fatal">Fatal</option>
              <option value="Serious Injury">Serious Injury</option>
              <option value="Minor Injury">Minor Injury</option>
              <option value="Property Damage Only">Property Damage Only</option>
            </select>
          </div>
        </div>
      </div>

      {/* Accidents Table */}
      <div className="card overflow-hidden">
        <div className="overflow-x-auto">
          <table className="table">
            <thead className="table-header">
              <tr>
                <th className="table-header-cell">Date</th>
                <th className="table-header-cell">Location</th>
                <th className="table-header-cell">Type</th>
                <th className="table-header-cell">Effects</th>
                <th className="table-header-cell">Weather</th>
                <th className="table-header-cell">Actions</th>
              </tr>
            </thead>
            <tbody className="table-body">
              {filteredAccidents.length > 0 ? (
                filteredAccidents.map((accident) => (
                  <tr key={accident.id}>
                    <td className="table-cell">
                      {format(accident.date, 'MMM dd, yyyy')}
                    </td>
                    <td className="table-cell">
                      <div>
                        <div className="font-medium">{accident.road_name}</div>
                        <div className="text-gray-500 text-sm">
                          {accident.area}, {accident.region}
                        </div>
                      </div>
                    </td>
                    <td className="table-cell">{accident.type}</td>
                    <td className="table-cell">
                      <span className={`
                        px-2 py-1 text-xs font-medium rounded-full
                        ${getSeverityColor(accident.effects)}
                      `}>
                        {accident.effects}
                      </span>
                    </td>
                    <td className="table-cell">{accident.weather}</td>
                    <td className="table-cell">
                      <div className="flex space-x-2">
                        <button
                          onClick={() => setSelectedAccident(accident)}
                          className="p-1 text-blue-600 hover:text-blue-800"
                          title="View Details"
                        >
                          <EyeIcon className="h-4 w-4" />
                        </button>
                        <button
                          onClick={() => handleDelete(accident.id)}
                          className="p-1 text-red-600 hover:text-red-800"
                          title="Delete"
                          disabled={deleteMutation.isLoading}
                        >
                          <TrashIcon className="h-4 w-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan="6" className="table-cell text-center text-gray-500 py-8">
                    No accidents found
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Accident Details Modal */}
      {selectedAccident && (
        <div className="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 max-w-2xl w-full mx-4 max-h-96 overflow-y-auto">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-semibold">Accident Details</h3>
              <button
                onClick={() => setSelectedAccident(null)}
                className="text-gray-400 hover:text-gray-600"
              >
                ×
              </button>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <h4 className="font-medium text-gray-900 mb-2">Location Information</h4>
                <p><strong>Road:</strong> {selectedAccident.road_name}</p>
                <p><strong>Area:</strong> {selectedAccident.area}</p>
                <p><strong>District:</strong> {selectedAccident.district}</p>
                <p><strong>Region:</strong> {selectedAccident.region}</p>
                <p><strong>Ward:</strong> {selectedAccident.ward}</p>
              </div>
              
              <div>
                <h4 className="font-medium text-gray-900 mb-2">Accident Details</h4>
                <p><strong>Date:</strong> {format(selectedAccident.date, 'MMM dd, yyyy HH:mm')}</p>
                <p><strong>Type:</strong> {selectedAccident.type}</p>
                <p><strong>Effects:</strong> {selectedAccident.effects}</p>
                <p><strong>Weather:</strong> {selectedAccident.weather}</p>
                <p><strong>Visibility:</strong> {selectedAccident.visibility}</p>
              </div>
            </div>
            
            {selectedAccident.involved_parties?.length > 0 && (
              <div className="mt-4">
                <h4 className="font-medium text-gray-900 mb-2">Involved Parties</h4>
                <div className="space-y-2">
                  {selectedAccident.involved_parties.map((party, index) => (
                    <div key={index} className="bg-gray-50 p-2 rounded">
                      <p><strong>Type:</strong> {party.type}</p>
                      <p><strong>Details:</strong> {party.details}</p>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
};

export default Accidents;
