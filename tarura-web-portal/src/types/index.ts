// User Types
export interface User {
  id: string;
  name: string;
  email: string;
  phone?: string;
  role: 'admin' | 'user' | 'tarura';
}

// Location Types
export interface Location {
  latitude: number;
  longitude: number;
}

export interface InvolvedParty {
  type: string; // e.g., vehicle, pedestrian
  details: string; // e.g., vehicle plate, driver name
}

// Accident Types
export interface Accident {
  id?: string;
  roadName: string;
  area: string;
  district: string;
  region: string;
  ward: string;
  date: Date;
  type: string;
  effects: string;
  visibility: string;
  weather: string;
  physiologicalIssues: string;
  environmentalFactors: string;
  location: Location;
  additionalPoints: Location[];
  photoUrls: string[];
  involvedParties: InvolvedParty[];
  createdAt: Date;
}

// Configuration Types
export interface ConfigOptions {
  accidentTypes: string[];
  effectTypes: string[];
  weatherConditions: string[];
  visibilityConditions: string[];
  physiologicalIssues: string[];
  environmentalFactors: string[];
  regions: string[];
}

// Statistics Types
export interface AccidentStats {
  total: number;
  byType: Record<string, number>;
  byRegion: Record<string, number>;
  byEffects: Record<string, number>;
  byWeather: Record<string, number>;
  byMonth: Record<string, number>;
  recentTrend: number; // percentage change
}

// Dashboard Types
export interface DashboardData {
  stats: AccidentStats;
  recentAccidents: Accident[];
  hotspots: Location[];
  users: User[];
}

// Filter Types
export interface AccidentFilters {
  region?: string;
  type?: string;
  effects?: string;
  startDate?: Date;
  endDate?: Date;
  weather?: string;
  visibility?: string;
}

// Chart Data Types
export interface ChartData {
  name: string;
  value: number;
  color?: string;
}

export interface TimeSeriesData {
  date: string;
  count: number;
  fatal?: number;
  injury?: number;
  property?: number;
}

// API Response Types
export interface ApiResponse<T> {
  data: T;
  success: boolean;
  message?: string;
}

// Export Types
export interface ExportOptions {
  format: 'csv' | 'pdf' | 'excel';
  filters?: AccidentFilters;
  includePhotos?: boolean;
  dateRange?: {
    start: Date;
    end: Date;
  };
}
