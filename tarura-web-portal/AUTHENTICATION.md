# TARURA Web Portal - Authentication Guide

## 🔐 Authentication System Overview

The TARURA Web Portal now includes a comprehensive authentication system with role-based access control. The system integrates with the existing Firebase authentication used by the mobile application.

## 🚀 Features

- **Firebase Authentication Integration**: Uses the same Firebase project as the mobile app
- **Role-Based Access Control**: Supports admin, user, and tarura roles
- **Protected Routes**: All pages require authentication
- **Session Persistence**: Users stay logged in across browser sessions
- **Responsive Design**: Works on desktop and mobile devices
- **No Registration**: Users must be created through the mobile app

## 👥 User Roles & Permissions

### Admin Role
- **Access**: Full access to all features
- **Pages**: Dashboard, Accidents, Analytics, Reports
- **Capabilities**: View all data, generate reports, manage system

### User Role  
- **Access**: Standard user access
- **Pages**: Dashboard, Accidents, Analytics
- **Restrictions**: Cannot access Reports page

### TARURA Role
- **Access**: TARURA official access
- **Pages**: Dashboard, Accidents, Analytics
- **Restrictions**: Cannot access Reports page

## 🔑 Login Process

1. **Access Portal**: Navigate to the web portal URL
2. **Login Screen**: Enter email and password used in mobile app
3. **Authentication**: System verifies credentials with Firebase
4. **Role Check**: System fetches user role from Firestore
5. **Dashboard Access**: Redirected to appropriate dashboard

## 🛡️ Security Features

- **Protected Routes**: All routes require authentication
- **Role Validation**: Pages check user roles before rendering
- **Session Management**: Automatic logout on session expiry
- **Error Handling**: Clear error messages for failed logins
- **Access Denied**: Informative pages for insufficient permissions

## 🔧 Technical Implementation

### Authentication Context
- `AuthContext`: Manages authentication state
- `useAuth`: Hook for accessing auth functions
- Firebase Auth integration for login/logout

### Protected Routes
- `ProtectedRoute`: Base protection component
- `UserRoute`: Allows admin, user, and tarura roles
- `AdminRoute`: Admin-only access
- `TaruraRoute`: Admin and tarura access

### Navigation
- User info display with role badge
- Logout functionality
- Responsive mobile menu

## 📱 User Management

### Creating Users
Users must be created through the mobile application:

1. **Mobile App Registration**: Use the mobile app to register new users
2. **Role Assignment**: Assign appropriate role during registration
3. **Web Portal Access**: Users can then login to web portal with same credentials

### User Roles in Firestore
User documents in Firestore must include:
```json
{
  "name": "Faudhia",
  "email": "admin@tarura.co.tz", 
  "phone": "+255629593331",
  "role": "tarura" // or "user" or "tarura"
}
```

## 🚨 Troubleshooting

### Common Issues

**Login Failed**s
- Verify email and password are correct
- Ensure user exists in mobile app
- Check Firebase console for authentication errors

**Access Denied**
- Verify user role in Firestore
- Ensure role is one of: admin, user, tarura
- Contact administrator for role updates

**Session Issues**
- Clear browser cache and cookies
- Try incognito/private browsing mode
- Check Firebase project configuration

### Error Messages

- **"Failed to sign in"**: Invalid credentials
- **"User data not found"**: User document missing in Firestore
- **"Access Denied"**: Insufficient role permissions

## 🔄 Development Setup

### Environment Variables
Copy `.env.example` to `.env.local` and configure if needed:
```bash
cp .env.example .env.local
```

### Firebase Configuration
The Firebase configuration is currently hardcoded in `src/services/firebase.ts`. 
To use environment variables, update the configuration and uncomment the variables in `.env.local`.

### Testing Authentication
1. Create test users in the mobile app
2. Assign different roles (admin, user, tarura)
3. Test login and access control in web portal

## 📋 Next Steps

- **User Management Interface**: Add admin interface for managing users
- **Password Reset**: Implement password reset functionality  
- **Audit Logging**: Track user actions and access
- **Multi-Factor Authentication**: Add 2FA for enhanced security
- **Session Timeout**: Implement automatic session timeout

## 🆘 Support

For authentication issues:
1. Check browser console for error messages
2. Verify Firebase project configuration
3. Ensure user exists in mobile app with correct role
4. Contact system administrator for assistance
