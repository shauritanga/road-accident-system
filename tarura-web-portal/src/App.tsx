import React from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ReactQueryDevtools } from "@tanstack/react-query-devtools";
import {
  BrowserRouter as Router,
  Routes,
  Route,
  Navigate,
} from "react-router-dom";
import { AuthProvider } from "./contexts/AuthContext";
import {
  ProtectedRoute,
  UserRoute,
  AdminRoute,
} from "./components/ProtectedRoute";
import { Dashboard } from "./components/Dashboard";
import { AccidentsList } from "./components/AccidentsList";
import { AccidentDetails } from "./components/AccidentDetails";
import { Analytics } from "./components/Analytics";
import { Reports } from "./components/Reports";
import { Navigation } from "./components/Navigation";
import "./App.css";

// Create a client
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 2,
      staleTime: 5 * 60 * 1000, // 5 minutes
      gcTime: 10 * 60 * 1000, // 10 minutes
    },
  },
});

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <Router>
          <ProtectedRoute>
            <div className="App">
              <Navigation />
              <main>
                <Routes>
                  <Route
                    path="/"
                    element={<Navigate to="/dashboard" replace />}
                  />
                  <Route
                    path="/dashboard"
                    element={
                      <UserRoute>
                        <Dashboard />
                      </UserRoute>
                    }
                  />
                  <Route
                    path="/accidents"
                    element={
                      <UserRoute>
                        <AccidentsList />
                      </UserRoute>
                    }
                  />
                  <Route
                    path="/accidents/:id"
                    element={
                      <UserRoute>
                        <AccidentDetails />
                      </UserRoute>
                    }
                  />
                  <Route
                    path="/analytics"
                    element={
                      <UserRoute>
                        <Analytics />
                      </UserRoute>
                    }
                  />
                  <Route
                    path="/reports"
                    element={
                      <AdminRoute>
                        <Reports />
                      </AdminRoute>
                    }
                  />
                </Routes>
              </main>
            </div>
          </ProtectedRoute>
        </Router>
        <ReactQueryDevtools initialIsOpen={false} />
      </AuthProvider>
    </QueryClientProvider>
  );
}

export default App;
