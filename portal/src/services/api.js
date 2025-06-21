import { 
  collection, 
  doc, 
  getDocs, 
  getDoc, 
  addDoc, 
  updateDoc, 
  deleteDoc, 
  query, 
  orderBy, 
  limit, 
  where,
  Timestamp 
} from 'firebase/firestore';
import { db } from '../config/firebase';

// Accidents API
export const accidentsAPI = {
  getAll: async () => {
    const q = query(collection(db, 'accidents'), orderBy('created_at', 'desc'));
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
      date: doc.data().date?.toDate(),
      created_at: doc.data().created_at?.toDate()
    }));
  },

  getById: async (id) => {
    const docRef = doc(db, 'accidents', id);
    const docSnap = await getDoc(docRef);
    if (docSnap.exists()) {
      return {
        id: docSnap.id,
        ...docSnap.data(),
        date: docSnap.data().date?.toDate(),
        created_at: docSnap.data().created_at?.toDate()
      };
    }
    throw new Error('Accident not found');
  },

  getRecent: async (limitCount = 10) => {
    const q = query(
      collection(db, 'accidents'), 
      orderBy('created_at', 'desc'), 
      limit(limitCount)
    );
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
      date: doc.data().date?.toDate(),
      created_at: doc.data().created_at?.toDate()
    }));
  },

  getByDateRange: async (startDate, endDate) => {
    const q = query(
      collection(db, 'accidents'),
      where('date', '>=', Timestamp.fromDate(startDate)),
      where('date', '<=', Timestamp.fromDate(endDate)),
      orderBy('date', 'desc')
    );
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
      date: doc.data().date?.toDate(),
      created_at: doc.data().created_at?.toDate()
    }));
  },

  delete: async (id) => {
    await deleteDoc(doc(db, 'accidents', id));
  }
};

// Users API
export const usersAPI = {
  getAll: async () => {
    const q = query(collection(db, 'users'), orderBy('name'));
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
  },

  getById: async (id) => {
    const docRef = doc(db, 'users', id);
    const docSnap = await getDoc(docRef);
    if (docSnap.exists()) {
      return {
        id: docSnap.id,
        ...docSnap.data()
      };
    }
    throw new Error('User not found');
  },

  create: async (userData) => {
    const docRef = await addDoc(collection(db, 'users'), userData);
    return docRef.id;
  },

  update: async (id, userData) => {
    await updateDoc(doc(db, 'users', id), userData);
  },

  delete: async (id) => {
    await deleteDoc(doc(db, 'users', id));
  }
};

// Configuration API
export const configAPI = {
  getAll: async () => {
    const snapshot = await getDocs(collection(db, 'config'));
    const config = {};
    snapshot.docs.forEach(doc => {
      config[doc.id] = doc.data();
    });
    return config;
  },

  get: async (configType) => {
    const docRef = doc(db, 'config', configType);
    const docSnap = await getDoc(docRef);
    if (docSnap.exists()) {
      return docSnap.data();
    }
    return null;
  },

  update: async (configType, data) => {
    await updateDoc(doc(db, 'config', configType), {
      ...data,
      updated_at: Timestamp.now()
    });
  }
};

// Statistics API
export const statisticsAPI = {
  getOverview: async () => {
    const accidents = await accidentsAPI.getAll();
    const users = await usersAPI.getAll();
    
    const now = new Date();
    const thisMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const lastMonth = new Date(now.getFullYear(), now.getMonth() - 1, 1);
    
    const thisMonthAccidents = accidents.filter(acc => acc.date >= thisMonth);
    const lastMonthAccidents = accidents.filter(acc => 
      acc.date >= lastMonth && acc.date < thisMonth
    );
    
    return {
      totalAccidents: accidents.length,
      totalUsers: users.length,
      thisMonthAccidents: thisMonthAccidents.length,
      lastMonthAccidents: lastMonthAccidents.length,
      fatalAccidents: accidents.filter(acc => acc.effects === 'Fatal').length,
      injuryAccidents: accidents.filter(acc => 
        acc.effects === 'Serious Injury' || acc.effects === 'Minor Injury'
      ).length,
      recentAccidents: accidents.slice(0, 5)
    };
  }
};
