# TARURA Road Accident Information System - Web Portal

A professional web portal for the Tanzania Road and Traffic Authority (TARURA) to view, analyze, and manage road accident data collected through the mobile application.

## 🚀 Features

### Dashboard
- **Real-time Statistics**: Live accident counts, trends, and key metrics
- **Visual Analytics**: Interactive charts showing accident patterns by type, region, severity, and weather
- **Geographic Mapping**: Interactive map displaying accident hotspots and locations
- **Recent Incidents**: Latest accident reports with detailed information

### Accident Management
- **Comprehensive Listing**: Sortable and filterable table of all accident records
- **Advanced Filtering**: Filter by region, type, severity, date range, weather, and visibility
- **Detailed Views**: Complete accident information including photos, involved parties, and environmental factors
- **Map Integration**: Geographic visualization of accident locations

### Analytics & Reporting
- **Trend Analysis**: Monthly and yearly accident trends
- **Regional Breakdown**: Detailed statistics by region and district
- **Severity Analysis**: Distribution of accident impacts and casualties
- **Weather Correlation**: Analysis of weather conditions and accident frequency

### Data Export & Reports
- **Multiple Formats**: Export data in CSV, PDF, and Excel formats
- **Custom Reports**: Generate tailored reports based on specific criteria
- **Automated Summaries**: Monthly and quarterly summary reports

## 🛠 Technology Stack

- **Frontend**: React 18 with TypeScript
- **State Management**: React Query (TanStack Query) for server state
- **Styling**: Tailwind CSS for responsive design
- **Charts**: Recharts for data visualization
- **Maps**: React Leaflet for geographic visualization
- **Backend**: Firebase Firestore (shared with mobile app)
- **Icons**: Lucide React for consistent iconography

## 📊 Data Structure

The portal connects to the same Firebase Firestore database as the mobile app, accessing:

### Accidents Collection
```typescript
interface Accident {
  id: string;
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
  location: { latitude: number; longitude: number };
  additionalPoints: Location[];
  photoUrls: string[];
  involvedParties: InvolvedParty[];
  createdAt: Date;
}
```

### Configuration Data
- Accident types (Head-on Collision, Rear-end, etc.)
- Effect types (Fatal, Serious Injury, Minor Injury, Property Damage)
- Weather conditions (Clear, Rainy, Foggy, etc.)
- Visibility conditions (Good, Fair, Poor, Very Poor)
- Physiological issues (Fatigue, Alcohol, Drugs, etc.)
- Environmental factors (Poor Road Condition, Poor Lighting, etc.)
- Tanzania regions (Dar es Salaam, Mwanza, Arusha, etc.)

## 🚀 Getting Started

### Prerequisites
- Node.js 16+ and npm
- Firebase project access (same as mobile app)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd tarura-web-portal
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure Firebase**
   - The Firebase configuration is already set up to connect to the same project as the mobile app
   - Ensure your Firebase project has the web app configured

4. **Start development server**
   ```bash
   npm start
   ```

5. **Open in browser**
   - Navigate to `http://localhost:3000`

### Build for Production
```bash
npm run build
```

## 📱 Responsive Design

The portal is fully responsive and works on:
- Desktop computers (1920px+)
- Laptops (1024px+)
- Tablets (768px+)
- Mobile devices (320px+)

## 🔐 Security & Access

- **Read-only Access**: Portal only reads data, cannot modify accident records
- **Firebase Security Rules**: Ensure proper Firestore security rules are configured
- **HTTPS Only**: Production deployment should use HTTPS

## 📈 Performance Features

- **React Query Caching**: Intelligent data caching and background updates
- **Lazy Loading**: Components and data loaded on demand
- **Optimized Charts**: Efficient rendering of large datasets
- **Image Optimization**: Optimized loading of accident photos

## 🎨 Design System

### Colors
- **Primary**: Blue (#2563eb) - TARURA brand color
- **Success**: Green (#22c55e) - Positive actions
- **Warning**: Yellow (#f59e0b) - Caution states
- **Danger**: Red (#ef4444) - Fatal accidents, errors

### Typography
- **Headings**: Bold, clear hierarchy
- **Body**: Readable, accessible font sizes
- **Data**: Monospace for numbers and codes

## 📊 Key Metrics Displayed

1. **Total Accidents**: All-time accident count
2. **Fatal Accidents**: Number and percentage of fatal incidents
3. **Injury Statistics**: Serious and minor injury counts
4. **Property Damage**: Non-injury accidents
5. **Regional Distribution**: Accidents by region
6. **Monthly Trends**: Time-based patterns
7. **Weather Impact**: Weather-related accident analysis

## 🗺 Geographic Features

- **Interactive Maps**: Zoom, pan, and click for details
- **Accident Markers**: Color-coded by severity
- **Hotspot Analysis**: Identification of high-risk areas
- **Regional Boundaries**: Visual region separation

## 📋 Future Enhancements

- **Real-time Notifications**: Live updates for new accidents
- **Predictive Analytics**: AI-powered accident prediction
- **Mobile App**: Responsive mobile version
- **API Integration**: RESTful API for third-party access
- **Advanced Reporting**: Custom report builder
- **User Management**: Role-based access control

## 🤝 Contributing

This portal is designed specifically for TARURA's needs. For modifications or enhancements, please follow the established patterns and maintain the professional design standards.

## 📞 Support

For technical support or feature requests, please contact the development team.

---

**Built for Tanzania Road and Traffic Authority (TARURA)**  
*Enhancing road safety through data-driven insights*
