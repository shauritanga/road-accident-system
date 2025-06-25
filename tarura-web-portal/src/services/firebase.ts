import { initializeApp } from 'firebase/app';
import { getFirestore, connectFirestoreEmulator } from 'firebase/firestore';
import { getAuth, connectAuthEmulator } from 'firebase/auth';
import { getStorage, connectStorageEmulator } from 'firebase/storage';

// Firebase configuration from the mobile app
const firebaseConfig = {
  apiKey: 'AIzaSyCI7j8rCNHjLY8g-EDZTY1aZp56P4BJOEI',
  appId: '1:1060591687534:web:569b8e99432f41efdad37f',
  messagingSenderId: '1060591687534',
  projectId: 'road-accident-system-dit',
  authDomain: 'road-accident-system-dit.firebaseapp.com',
  storageBucket: 'road-accident-system-dit.firebasestorage.app',
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firebase services
export const db = getFirestore(app);
export const auth = getAuth(app);
export const storage = getStorage(app);

// Connect to emulators in development
if (process.env.NODE_ENV === 'development') {
  // Uncomment these lines if you want to use Firebase emulators
  // connectFirestoreEmulator(db, 'localhost', 8080);
  // connectAuthEmulator(auth, 'http://localhost:9099');
  // connectStorageEmulator(storage, 'localhost', 9199);
}

export default app;
