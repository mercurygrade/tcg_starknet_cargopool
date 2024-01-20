import React, { useEffect, useRef, useState } from 'react';
import mapboxgl from 'mapbox-gl';

mapboxgl.accessToken = 'pk.eyJ1IjoiYXBpdGNoZGVjayIsImEiOiJjaW51czk2MzkxMmE2dThranhmeDkwZ2hwIn0.1Ms7Dj4HFX-Gaf1waHFFPw';


const geojson = {
  type: 'FeatureCollection',
  features: [
    {
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: [-77.032, 38.913]
      },
      properties: {
        title: 'Mapbox',
        description: 'Washington, D.C.'
      }
    },
    {
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: [-122.414, 37.776]
      },
      properties: {
        title: 'Mapbox',
        description: 'San Francisco, California'
      }
    }
  ]
};

const Map = ({ onLocationSelect }) => {
  const mapContainer = useRef(null);
  const map = useRef(null);
  const [lng, setLng] = useState(-70.9);
  const [lat, setLat] = useState(42.35);
  const [zoom, setZoom] = useState(9);
  useEffect(() => {
    if (map.current) return; // Initialize map only once

    map.current = new mapboxgl.Map({
      container: mapContainer.current,
      style: 'mapbox://styles/mapbox/streets-v12',
      center: [lng, lat],
      zoom: zoom,
     // scrollZoom: false
    });

// Create a new marker.
 new mapboxgl.Marker()
    .setLngLat([30.5, 50.5])
    .addTo(map);

    // Add map controls
    map.current.addControl(new mapboxgl.NavigationControl(), 'top-right');

    // Add click event to set user-selected location
    map.current.on('click', (event) => {
      const { lng, lat } = event.lngLat;
      onLocationSelect({ lng, lat });
    });

    map.current.on('move', () => {
      setLng(map.current.getCenter().lng.toFixed(4));
      setLat(map.current.getCenter().lat.toFixed(4));
      setZoom(map.current.getZoom().toFixed(2));
    });

    map.current.on('load', () => {
      map.current.addLayer('places', {
        type: 'geojson',
        data: stores
      });
      // Optionally, add layers or other customizations here
    });

  }, [lng, lat, zoom]);


  return <div id="map" ref={mapContainer} className="h-screen w-full" />;
};




export default Map;
