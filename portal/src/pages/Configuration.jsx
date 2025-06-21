import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { 
  PlusIcon, 
  TrashIcon, 
  PencilIcon,
  CheckIcon,
  XMarkIcon
} from '@heroicons/react/24/outline';
import { configAPI } from '../services/api';
import LoadingSpinner from '../components/UI/LoadingSpinner';
import toast from 'react-hot-toast';

const Configuration = () => {
  const [editingConfig, setEditingConfig] = useState(null);
  const [editingItem, setEditingItem] = useState(null);
  const [newItem, setNewItem] = useState('');
  const queryClient = useQueryClient();

  const { data: config, isLoading } = useQuery({
    queryKey: ['config'],
    queryFn: configAPI.getAll
  });

  const updateMutation = useMutation({
    mutationFn: ({ configType, data }) => configAPI.update(configType, data),
    onSuccess: () => {
      queryClient.invalidateQueries(['config']);
      toast.success('Configuration updated successfully');
      setEditingConfig(null);
      setEditingItem(null);
      setNewItem('');
    },
    onError: (error) => {
      toast.error('Error updating configuration');
    }
  });

  const configTypes = [
    { key: 'accident_types', label: 'Accident Types', description: 'Types of accidents that can be reported' },
    { key: 'effect_types', label: 'Effect Types', description: 'Severity levels of accident effects' },
    { key: 'weather_conditions', label: 'Weather Conditions', description: 'Weather conditions during accidents' },
    { key: 'visibility_conditions', label: 'Visibility Conditions', description: 'Visibility levels during accidents' },
    { key: 'physiological_issues', label: 'Physiological Issues', description: 'Driver physiological factors' },
    { key: 'environmental_factors', label: 'Environmental Factors', description: 'Environmental contributing factors' },
    { key: 'regions', label: 'Regions', description: 'Geographic regions in Tanzania' }
  ];

  const handleAddItem = (configType) => {
    if (!newItem.trim()) return;
    
    const currentOptions = config[configType]?.options || [];
    const updatedOptions = [...currentOptions, newItem.trim()];
    
    updateMutation.mutate({
      configType,
      data: { options: updatedOptions }
    });
  };

  const handleEditItem = (configType, index, newValue) => {
    const currentOptions = config[configType]?.options || [];
    const updatedOptions = [...currentOptions];
    updatedOptions[index] = newValue.trim();
    
    updateMutation.mutate({
      configType,
      data: { options: updatedOptions }
    });
  };

  const handleDeleteItem = (configType, index) => {
    if (window.confirm('Are you sure you want to delete this item?')) {
      const currentOptions = config[configType]?.options || [];
      const updatedOptions = currentOptions.filter((_, i) => i !== index);
      
      updateMutation.mutate({
        configType,
        data: { options: updatedOptions }
      });
    }
  };

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
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Configuration</h1>
        <p className="text-gray-600">Manage system configuration options</p>
      </div>

      {/* Configuration Sections */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {configTypes.map((configType) => {
          const options = config?.[configType.key]?.options || [];
          
          return (
            <div key={configType.key} className="card p-6">
              <div className="flex justify-between items-start mb-4">
                <div>
                  <h3 className="text-lg font-semibold text-gray-900">
                    {configType.label}
                  </h3>
                  <p className="text-sm text-gray-600">
                    {configType.description}
                  </p>
                </div>
              </div>

              {/* Options List */}
              <div className="space-y-2 mb-4">
                {options.map((option, index) => (
                  <div key={index} className="flex items-center justify-between p-2 bg-gray-50 rounded-lg">
                    {editingItem === `${configType.key}-${index}` ? (
                      <div className="flex-1 flex items-center space-x-2">
                        <input
                          type="text"
                          defaultValue={option}
                          className="input flex-1"
                          onKeyPress={(e) => {
                            if (e.key === 'Enter') {
                              handleEditItem(configType.key, index, e.target.value);
                            }
                          }}
                          autoFocus
                        />
                        <button
                          onClick={(e) => {
                            const input = e.target.parentElement.querySelector('input');
                            handleEditItem(configType.key, index, input.value);
                          }}
                          className="p-1 text-green-600 hover:text-green-800"
                        >
                          <CheckIcon className="h-4 w-4" />
                        </button>
                        <button
                          onClick={() => setEditingItem(null)}
                          className="p-1 text-red-600 hover:text-red-800"
                        >
                          <XMarkIcon className="h-4 w-4" />
                        </button>
                      </div>
                    ) : (
                      <>
                        <span className="flex-1 text-sm">{option}</span>
                        <div className="flex space-x-1">
                          <button
                            onClick={() => setEditingItem(`${configType.key}-${index}`)}
                            className="p-1 text-blue-600 hover:text-blue-800"
                            title="Edit"
                          >
                            <PencilIcon className="h-4 w-4" />
                          </button>
                          <button
                            onClick={() => handleDeleteItem(configType.key, index)}
                            className="p-1 text-red-600 hover:text-red-800"
                            title="Delete"
                          >
                            <TrashIcon className="h-4 w-4" />
                          </button>
                        </div>
                      </>
                    )}
                  </div>
                ))}
              </div>

              {/* Add New Item */}
              <div className="flex space-x-2">
                <input
                  type="text"
                  placeholder={`Add new ${configType.label.toLowerCase()}`}
                  className="input flex-1"
                  value={editingConfig === configType.key ? newItem : ''}
                  onChange={(e) => {
                    setEditingConfig(configType.key);
                    setNewItem(e.target.value);
                  }}
                  onKeyPress={(e) => {
                    if (e.key === 'Enter') {
                      handleAddItem(configType.key);
                    }
                  }}
                />
                <button
                  onClick={() => handleAddItem(configType.key)}
                  disabled={updateMutation.isLoading}
                  className="btn btn-primary flex items-center"
                >
                  <PlusIcon className="h-4 w-4" />
                </button>
              </div>
            </div>
          );
        })}
      </div>

      {/* Save Notice */}
      <div className="card p-4 bg-blue-50 border-blue-200">
        <div className="flex items-center">
          <div className="flex-shrink-0">
            <svg className="h-5 w-5 text-blue-400" viewBox="0 0 20 20" fill="currentColor">
              <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clipRule="evenodd" />
            </svg>
          </div>
          <div className="ml-3">
            <p className="text-sm text-blue-700">
              Changes to configuration options will be immediately available to mobile app users.
              Make sure to test thoroughly before making changes to production data.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Configuration;
