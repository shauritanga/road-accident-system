import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';
import { getAuth } from 'firebase/auth';
import { getStorage } from 'firebase/storage';

const firebaseConfig = {
  apiKey: process.env.REACT_APP_FIREBASE_API_KEY || "AIzaSyCI7j8rCNHjLY8g-EDZTY1aZp56P4BJOEI",
  authDomain: process.env.REACT_APP_FIREBASE_AUTH_DOMAIN || "road-accident-system-dit.firebaseapp.com",
  projectId: process.env.REACT_APP_FIREBASE_PROJECT_ID || "road-accident-system-dit",
  storageBucket: process.env.REACT_APP_FIREBASE_STORAGE_BUCKET || "road-accident-system-dit.firebasestorage.app",
  messagingSenderId: process.env.REACT_APP_FIREBASE_MESSAGING_SENDER_ID || "1060591687534",
  appId: process.env.REACT_APP_FIREBASE_APP_ID || "1:1060591687534:web:569b8e99432f41efdad37f"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firebase services
export const db = getFirestore(app);
export const auth = getAuth(app);
export const storage = getStorage(app);

export default app;
