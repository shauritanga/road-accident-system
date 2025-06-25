import React from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import { Icon, LatLngBounds } from 'leaflet';
import { Accident } from '../types';
import 'leaflet/dist/leaflet.css';

// Fix for default markers in React Leaflet
import markerIcon2x from 'leaflet/dist/images/marker-icon-2x.png';
import markerIcon from 'leaflet/dist/images/marker-icon.png';
import markerShadow from 'leaflet/dist/images/marker-shadow.png';

delete (Icon.Default.prototype as any)._getIconUrl;
Icon.Default.mergeOptions({
  iconUrl: markerIcon,
  iconRetinaUrl: markerIcon2x,
  shadowUrl: markerShadow,
});

interface AccidentMapProps {
  accidents: Accident[];
  height?: string;
}

// Custom icons for different accident severities
const createCustomIcon = (severity: string) => {
  const color = getSeverityColor(severity);
  return new Icon({
    iconUrl: `data:image/svg+xml;base64,${btoa(`
      <svg width="25" height="41" viewBox="0 0 25 41" xmlns="http://www.w3.org/2000/svg">
        <path d="M12.5 0C5.6 0 0 5.6 0 12.5c0 12.5 12.5 28.5 12.5 28.5s12.5-16 12.5-28.5C25 5.6 19.4 0 12.5 0z" fill="${color}"/>
        <circle cx="12.5" cy="12.5" r="7" fill="white"/>
        <text x="12.5" y="17" text-anchor="middle" font-size="10" font-weight="bold" fill="${color}">!</text>
      </svg>
    `)}`,
    iconSize: [25, 41],
    iconAnchor: [12, 41],
    popupAnchor: [1, -34],
  });
};

const getSeverityColor = (effects: string): string => {
  switch (effects.toLowerCase()) {
    case 'fatal':
      return '#dc2626'; // red-600
    case 'serious injury':
      return '#ea580c'; // orange-600
    case 'minor injury':
      return '#ca8a04'; // yellow-600
    case 'property damage only':
      return '#2563eb'; // blue-600
    default:
      return '#6b7280'; // gray-500
  }
};

// Component to fit map bounds to show all markers
const FitBounds: React.FC<{ accidents: Accident[] }> = ({ accidents }) => {
  const map = useMap();

  React.useEffect(() => {
    if (accidents.length > 0) {
      const bounds = new LatLngBounds(
        accidents.map(accident => [accident.location.latitude, accident.location.longitude])
      );
      map.fitBounds(bounds, { padding: [20, 20] });
    }
  }, [accidents, map]);

  return null;
};

export const AccidentMap: React.FC<AccidentMapProps> = ({ 
  accidents, 
  height = '400px' 
}) => {
  // Default center (Tanzania)
  const defaultCenter: [number, number] = [-6.369028, 34.888822];
  const defaultZoom = 6;

  return (
    <div style={{ height, width: '100%' }}>
      <MapContainer
        center={defaultCenter}
        zoom={defaultZoom}
        style={{ height: '100%', width: '100%' }}
        className="rounded-lg"
      >
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        />
        
        {accidents.length > 0 && <FitBounds accidents={accidents} />}
        
        {accidents.map((accident) => (
          <Marker
            key={accident.id}
            position={[accident.location.latitude, accident.location.longitude]}
            icon={createCustomIcon(accident.effects)}
          >
            <Popup>
              <div className="p-2 min-w-[250px]">
                <div className="mb-2">
                  <h3 className="font-semibold text-gray-900">{accident.type}</h3>
                  <p className="text-sm text-gray-600">{accident.roadName}</p>
                </div>
                
                <div className="space-y-1 text-sm">
                  <div className="flex justify-between">
                    <span className="text-gray-600">Location:</span>
                    <span className="font-medium">{accident.area}, {accident.district}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-600">Region:</span>
                    <span className="font-medium text-blue-600">{accident.region}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-600">Date:</span>
                    <span className="font-medium">{accident.date.toLocaleDateString()}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-600">Severity:</span>
                    <span 
                      className={`font-medium px-2 py-1 rounded text-xs ${
                        accident.effects.toLowerCase() === 'fatal' 
                          ? 'bg-red-100 text-red-800'
                          : accident.effects.toLowerCase().includes('injury')
                          ? 'bg-orange-100 text-orange-800'
                          : 'bg-blue-100 text-blue-800'
                      }`}
                    >
                      {accident.effects}
                    </span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-600">Weather:</span>
                    <span className="font-medium">{accident.weather}</span>
                  </div>
                  {accident.involvedParties.length > 0 && (
                    <div className="flex justify-between">
                      <span className="text-gray-600">Parties:</span>
                      <span className="font-medium">{accident.involvedParties.length}</span>
                    </div>
                  )}
                </div>
                
                {accident.photoUrls.length > 0 && (
                  <div className="mt-2 pt-2 border-t">
                    <p className="text-xs text-gray-600">
                      📷 {accident.photoUrls.length} photo{accident.photoUrls.length > 1 ? 's' : ''} available
                    </p>
                  </div>
                )}
              </div>
            </Popup>
          </Marker>
        ))}
      </MapContainer>
    </div>
  );
};
