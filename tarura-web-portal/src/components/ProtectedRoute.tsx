import React from "react";
import { useAuth } from "../contexts/AuthContext";
import { Login } from "./Login";
import { LoadingSpinner } from "./LoadingSpinner";
import { AlertTriangle, Shield } from "lucide-react";

interface ProtectedRouteProps {
  children: React.ReactNode;
  requiredRoles?: string | string[];
  fallback?: React.ReactNode;
}

export const ProtectedRoute: React.FC<ProtectedRouteProps> = ({
  children,
  requiredRoles,
  fallback,
}) => {
  const { currentUser, userData, loading, hasRole } = useAuth();

  // Show loading spinner while checking authentication
  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  // Show login if not authenticated
  if (!currentUser || !userData) {
    return <Login />;
  }

  // Check role-based access if required roles are specified
  if (requiredRoles && !hasRole(requiredRoles)) {
    return (
      fallback || (
        <AccessDenied userRole={userData.role} requiredRoles={requiredRoles} />
      )
    );
  }

  return <>{children}</>;
};

interface AccessDeniedProps {
  userRole: string;
  requiredRoles: string | string[];
}

const AccessDenied: React.FC<AccessDeniedProps> = ({
  userRole,
  requiredRoles,
}) => {
  const { signOut } = useAuth();

  const handleSignOut = async () => {
    try {
      await signOut();
    } catch (error) {
      console.error("Error signing out:", error);
    }
  };

  const requiredRolesText = Array.isArray(requiredRoles)
    ? requiredRoles.join(", ")
    : requiredRoles;

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
      <div className="max-w-md w-full text-center">
        <div className="bg-white rounded-lg shadow-lg p-8">
          <div className="mx-auto w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mb-6">
            <AlertTriangle className="w-8 h-8 text-red-600" />
          </div>

          <h1 className="text-2xl font-bold text-gray-900 mb-4">
            Access Denied
          </h1>

          <p className="text-gray-600 mb-6">
            You don't have permission to access this page. This page requires{" "}
            <span className="font-semibold">{requiredRolesText}</span> access
            level.
          </p>

          <div className="bg-gray-50 rounded-md p-4 mb-6">
            <div className="flex items-center justify-center">
              <Shield className="w-5 h-5 text-gray-400 mr-2" />
              <span className="text-sm text-gray-600">
                Your current role:{" "}
                <span className="font-semibold capitalize">{userRole}</span>
              </span>
            </div>
          </div>

          <button
            onClick={handleSignOut}
            className="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors"
          >
            Sign Out
          </button>
        </div>

        <p className="mt-6 text-sm text-gray-500">
          Contact your administrator if you believe this is an error.
        </p>
      </div>
    </div>
  );
};

// Convenience components for specific role requirements
export const AdminRoute: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => <ProtectedRoute requiredRoles="admin">{children}</ProtectedRoute>;

export const UserRoute: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => (
  <ProtectedRoute requiredRoles={["admin", "user", "tarura"]}>
    {children}
  </ProtectedRoute>
);

export const TaruraRoute: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => (
  <ProtectedRoute requiredRoles={["admin", "tarura"]}>
    {children}
  </ProtectedRoute>
);
