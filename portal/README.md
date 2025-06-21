# Road Accident Information System - Admin Portal

A comprehensive React.js admin portal for managing the Road Accident Information System with real-time data visualization and management capabilities.

## Features

### 🔐 Authentication & Security
- **Admin-only Access**: Secure login with role-based authentication
- **Firebase Authentication**: Integrated with Firebase Auth
- **Protected Routes**: All admin routes are protected and require admin privileges

### 📊 Dashboard & Analytics
- **Real-time Statistics**: Live accident data and user metrics
- **Interactive Charts**: Powered by Recharts for data visualization
- **Trend Analysis**: Monthly accident trends and patterns
- **Regional Insights**: Geographic distribution of accidents

### 🚨 Accident Management
- **View All Accidents**: Comprehensive list with filtering and search
- **Detailed Views**: Complete accident information with involved parties
- **Data Export**: Export accident data for reporting
- **Real-time Updates**: Live data synchronization with Firebase

### 👥 User Management
- **User CRUD Operations**: Create, read, update, delete users
- **Role Management**: Assign roles (Admin, Tarura, Traffic Officer)
- **User Search & Filter**: Find users by name, email, or role

### ⚙️ Configuration Management
- **Dynamic Dropdowns**: Manage all dropdown options used in mobile app
- **Real-time Updates**: Changes reflect immediately in mobile app
- **Bulk Operations**: Add, edit, delete configuration options
- **Categories Include**:
  - Accident Types
  - Effect Types
  - Weather Conditions
  - Visibility Conditions
  - Physiological Issues
  - Environmental Factors
  - Geographic Regions

### 📈 Advanced Analytics
- **Multiple Chart Types**: Line charts, pie charts, bar charts
- **Time-based Analysis**: Monthly trends and patterns
- **Comparative Data**: Fatal vs injury accidents
- **Regional Statistics**: Top regions by accident count
- **Weather Impact Analysis**: Accident correlation with weather

## Technology Stack

### Frontend
- **React 18**: Modern React with hooks and functional components
- **React Router v6**: Client-side routing
- **Tailwind CSS**: Utility-first CSS framework
- **Headless UI**: Accessible UI components
- **Heroicons**: Beautiful SVG icons

### State Management & Data Fetching
- **React Query (TanStack Query)**: Server state management
- **React Hook Form**: Form handling and validation
- **React Hot Toast**: Toast notifications

### Data Visualization
- **Recharts**: Responsive charts and graphs
- **Date-fns**: Date manipulation and formatting

### Backend Integration
- **Firebase Firestore**: Real-time database
- **Firebase Auth**: Authentication service
- **Firebase Storage**: File storage (for future features)

## Project Structure

```
portal/
├── public/
│   ├── index.html
│   └── manifest.json
├── src/
│   ├── components/
│   │   ├── Layout/
│   │   │   ├── Header.jsx
│   │   │   ├── Sidebar.jsx
│   │   │   └── Layout.jsx
│   │   ├── UI/
│   │   │   ├── LoadingSpinner.jsx
│   │   │   └── StatCard.jsx
│   │   └── ProtectedRoute.jsx
│   ├── config/
│   │   └── firebase.js
│   ├── hooks/
│   │   └── useAuth.js
│   ├── pages/
│   │   ├── Login.jsx
│   │   ├── Dashboard.jsx
│   │   ├── Accidents.jsx
│   │   ├── Users.jsx
│   │   ├── Analytics.jsx
│   │   └── Configuration.jsx
│   ├── services/
│   │   └── api.js
│   ├── App.js
│   ├── index.js
│   └── index.css
├── package.json
├── tailwind.config.js
└── README.md
```

## Installation & Setup

### Prerequisites
- Node.js (v16 or higher)
- npm or yarn
- Firebase project with Firestore enabled

### 1. Clone and Install
```bash
cd portal
npm install
```

### 2. Environment Configuration
```bash
cp .env.example .env
```

Edit `.env` with your Firebase configuration:
```env
REACT_APP_FIREBASE_API_KEY=your_api_key
REACT_APP_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
REACT_APP_FIREBASE_PROJECT_ID=your_project_id
REACT_APP_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
REACT_APP_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
REACT_APP_FIREBASE_APP_ID=your_app_id
```

### 3. Firebase Setup
Ensure your Firebase project has:
- **Firestore Database** enabled
- **Authentication** enabled with Email/Password provider
- **Admin user** created with role 'admin' in users collection

### 4. Start Development Server
```bash
npm start
```

The application will open at `http://localhost:3000`

## Usage

### First Time Setup
1. Create an admin user in Firebase Auth
2. Add user document in Firestore `users` collection:
```json
{
  "name": "Admin User",
  "email": "admin@example.com",
  "role": "admin",
  "phone": "+1234567890"
}
```

### Login
- Navigate to `/login`
- Enter admin credentials
- Access is restricted to users with 'admin' role

### Managing Configuration
1. Go to Configuration page
2. Add/edit/delete dropdown options
3. Changes are immediately available in mobile app

### Viewing Analytics
1. Navigate to Analytics page
2. View charts and statistics
3. Use date range filters for specific periods

## API Integration

The portal integrates with Firebase Firestore collections:

### Collections Used
- `accidents` - Accident records from mobile app
- `users` - System users and their roles
- `config` - Configuration options for dropdowns

### Real-time Updates
- All data updates in real-time using Firebase listeners
- React Query manages caching and synchronization
- Optimistic updates for better user experience

## Security Features

### Authentication
- Firebase Auth integration
- Role-based access control
- Protected routes for admin-only access

### Data Security
- Firestore security rules (to be implemented)
- Input validation and sanitization
- Error handling and user feedback

## Performance Optimizations

### React Query
- Intelligent caching
- Background refetching
- Optimistic updates
- Error retry logic

### Code Splitting
- Lazy loading of routes
- Component-level optimization
- Bundle size optimization

## Future Enhancements

### Planned Features
- **Map Integration**: Google Maps for accident locations
- **Advanced Reports**: PDF generation and export
- **Real-time Notifications**: Push notifications for new accidents
- **Audit Logs**: Track admin actions and changes
- **Bulk Operations**: Mass data management tools
- **Advanced Filtering**: Complex search and filter options

### Technical Improvements
- **PWA Support**: Progressive Web App capabilities
- **Offline Support**: Offline data access
- **Performance Monitoring**: Analytics and performance tracking
- **Automated Testing**: Unit and integration tests

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is part of the Road Accident Information System and is proprietary software.

## Support

For technical support or questions, please contact the development team.
