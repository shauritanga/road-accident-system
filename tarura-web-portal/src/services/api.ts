import {
  collection,
  query,
  orderBy,
  limit,
  where,
  getDocs,
  doc,
  getDoc,
  Timestamp,
  GeoPoint,
} from 'firebase/firestore';
import { db } from './firebase';
import { Accident, User, AccidentFilters, ConfigOptions, AccidentStats } from '../types';

// Convert Firestore document to Accident object
const convertFirestoreToAccident = (doc: any): Accident => {
  const data = doc.data();
  const geoPoint = data.location as GeoPoint;
  
  const additionalPoints = (data.additional_points || []).map((point: GeoPoint) => ({
    latitude: point.latitude,
    longitude: point.longitude,
  }));

  const involvedParties = (data.involved_parties || []).map((party: any) => ({
    type: party.type || '',
    details: party.details || '',
  }));

  return {
    id: doc.id,
    roadName: data.road_name || '',
    area: data.area || '',
    district: data.district || '',
    region: data.region || '',
    ward: data.ward || '',
    date: data.date?.toDate() || new Date(),
    type: data.type || '',
    effects: data.effects || '',
    visibility: data.visibility || '',
    weather: data.weather || '',
    physiologicalIssues: data.physiological_issues || '',
    environmentalFactors: data.environmental_factors || '',
    location: {
      latitude: geoPoint.latitude,
      longitude: geoPoint.longitude,
    },
    additionalPoints,
    photoUrls: data.photo_urls || [],
    involvedParties,
    createdAt: data.created_at?.toDate() || new Date(),
  };
};

// API Functions
export const api = {
  // Fetch all accidents with optional filters
  async getAccidents(filters?: AccidentFilters): Promise<Accident[]> {
    let q = query(collection(db, 'accidents'), orderBy('created_at', 'desc'));

    // Apply filters
    if (filters?.region) {
      q = query(q, where('region', '==', filters.region));
    }
    if (filters?.type) {
      q = query(q, where('type', '==', filters.type));
    }
    if (filters?.effects) {
      q = query(q, where('effects', '==', filters.effects));
    }
    if (filters?.startDate) {
      q = query(q, where('date', '>=', Timestamp.fromDate(filters.startDate)));
    }
    if (filters?.endDate) {
      q = query(q, where('date', '<=', Timestamp.fromDate(filters.endDate)));
    }

    const snapshot = await getDocs(q);
    return snapshot.docs.map(convertFirestoreToAccident);
  },

  // Fetch recent accidents
  async getRecentAccidents(limitCount: number = 10): Promise<Accident[]> {
    const q = query(
      collection(db, 'accidents'),
      orderBy('created_at', 'desc'),
      limit(limitCount)
    );
    const snapshot = await getDocs(q);
    return snapshot.docs.map(convertFirestoreToAccident);
  },

  // Fetch accident by ID
  async getAccidentById(id: string): Promise<Accident | null> {
    const docRef = doc(db, 'accidents', id);
    const docSnap = await getDoc(docRef);
    
    if (docSnap.exists()) {
      return convertFirestoreToAccident(docSnap);
    }
    return null;
  },

  // Fetch all users
  async getUsers(): Promise<User[]> {
    const q = query(collection(db, 'users'));
    const snapshot = await getDocs(q);
    
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    })) as User[];
  },

  // Fetch configuration options
  async getConfigOptions(): Promise<ConfigOptions> {
    const configDocs = [
      'accident_types',
      'effect_types', 
      'weather_conditions',
      'visibility_conditions',
      'physiological_issues',
      'environmental_factors',
      'regions'
    ];

    const configs: any = {};
    
    for (const configDoc of configDocs) {
      try {
        const docRef = doc(db, 'config', configDoc);
        const docSnap = await getDoc(docRef);
        
        if (docSnap.exists()) {
          configs[configDoc] = docSnap.data().options || [];
        } else {
          configs[configDoc] = [];
        }
      } catch (error) {
        console.error(`Error fetching ${configDoc}:`, error);
        configs[configDoc] = [];
      }
    }

    return {
      accidentTypes: configs.accident_types,
      effectTypes: configs.effect_types,
      weatherConditions: configs.weather_conditions,
      visibilityConditions: configs.visibility_conditions,
      physiologicalIssues: configs.physiological_issues,
      environmentalFactors: configs.environmental_factors,
      regions: configs.regions,
    };
  },

  // Calculate accident statistics
  async getAccidentStats(): Promise<AccidentStats> {
    const accidents = await this.getAccidents();
    
    const stats: AccidentStats = {
      total: accidents.length,
      byType: {},
      byRegion: {},
      byEffects: {},
      byWeather: {},
      byMonth: {},
      recentTrend: 0,
    };

    // Calculate counts by different categories
    accidents.forEach(accident => {
      // By type
      stats.byType[accident.type] = (stats.byType[accident.type] || 0) + 1;
      
      // By region
      stats.byRegion[accident.region] = (stats.byRegion[accident.region] || 0) + 1;
      
      // By effects
      stats.byEffects[accident.effects] = (stats.byEffects[accident.effects] || 0) + 1;
      
      // By weather
      stats.byWeather[accident.weather] = (stats.byWeather[accident.weather] || 0) + 1;
      
      // By month
      const monthKey = accident.date.toISOString().substring(0, 7); // YYYY-MM
      stats.byMonth[monthKey] = (stats.byMonth[monthKey] || 0) + 1;
    });

    // Calculate recent trend (last 30 days vs previous 30 days)
    const now = new Date();
    const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
    const sixtyDaysAgo = new Date(now.getTime() - 60 * 24 * 60 * 60 * 1000);

    const recentAccidents = accidents.filter(a => a.date >= thirtyDaysAgo);
    const previousAccidents = accidents.filter(a => a.date >= sixtyDaysAgo && a.date < thirtyDaysAgo);

    if (previousAccidents.length > 0) {
      stats.recentTrend = ((recentAccidents.length - previousAccidents.length) / previousAccidents.length) * 100;
    }

    return stats;
  },
};
