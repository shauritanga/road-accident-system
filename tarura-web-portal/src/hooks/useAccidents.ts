import { useQuery, useQueryClient } from '@tanstack/react-query';
import { api } from '../services/api';
import { Accident, AccidentFilters, AccidentStats, ConfigOptions, User } from '../types';

// Query keys
export const QUERY_KEYS = {
  accidents: 'accidents',
  recentAccidents: 'recentAccidents',
  accidentById: 'accidentById',
  accidentStats: 'accidentStats',
  users: 'users',
  config: 'config',
} as const;

// Accidents hooks
export const useAccidents = (filters?: AccidentFilters) => {
  return useQuery({
    queryKey: [QUERY_KEYS.accidents, filters],
    queryFn: () => api.getAccidents(filters),
    staleTime: 5 * 60 * 1000, // 5 minutes
    gcTime: 10 * 60 * 1000, // 10 minutes
  });
};

export const useRecentAccidents = (limit: number = 10) => {
  return useQuery({
    queryKey: [QUERY_KEYS.recentAccidents, limit],
    queryFn: () => api.getRecentAccidents(limit),
    staleTime: 2 * 60 * 1000, // 2 minutes
    refetchInterval: 5 * 60 * 1000, // Refetch every 5 minutes
  });
};

export const useAccidentById = (id: string) => {
  return useQuery({
    queryKey: [QUERY_KEYS.accidentById, id],
    queryFn: () => api.getAccidentById(id),
    enabled: !!id,
    staleTime: 10 * 60 * 1000, // 10 minutes
  });
};

export const useAccidentStats = () => {
  return useQuery({
    queryKey: [QUERY_KEYS.accidentStats],
    queryFn: () => api.getAccidentStats(),
    staleTime: 5 * 60 * 1000, // 5 minutes
    refetchInterval: 10 * 60 * 1000, // Refetch every 10 minutes
  });
};

// Users hooks
export const useUsers = () => {
  return useQuery({
    queryKey: [QUERY_KEYS.users],
    queryFn: () => api.getUsers(),
    staleTime: 10 * 60 * 1000, // 10 minutes
  });
};

// Configuration hooks
export const useConfig = () => {
  return useQuery({
    queryKey: [QUERY_KEYS.config],
    queryFn: () => api.getConfigOptions(),
    staleTime: 30 * 60 * 1000, // 30 minutes - config doesn't change often
    gcTime: 60 * 60 * 1000, // 1 hour
  });
};

// Custom hook for invalidating queries
export const useInvalidateQueries = () => {
  const queryClient = useQueryClient();

  const invalidateAccidents = () => {
    queryClient.invalidateQueries({ queryKey: [QUERY_KEYS.accidents] });
    queryClient.invalidateQueries({ queryKey: [QUERY_KEYS.recentAccidents] });
    queryClient.invalidateQueries({ queryKey: [QUERY_KEYS.accidentStats] });
  };

  const invalidateUsers = () => {
    queryClient.invalidateQueries({ queryKey: [QUERY_KEYS.users] });
  };

  const invalidateConfig = () => {
    queryClient.invalidateQueries({ queryKey: [QUERY_KEYS.config] });
  };

  return {
    invalidateAccidents,
    invalidateUsers,
    invalidateConfig,
  };
};
