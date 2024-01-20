"use client"

import React, { useState, useEffect } from 'react';
import Map, { Marker, NavigationControl, GeolocateControl } from 'react-map-gl';
import "mapbox-gl/dist/mapbox-gl.css";

type GeoJsonPoint = {
  type: 'Feature';
  geometry: {
    type: 'Point';
    coordinates: [number, number]; // [longitude, latitude]
  };
  properties: {
    id: string;
    name: string;
  };
};

type GeoJsonFeatureCollection = {
  type: 'FeatureCollection';
  features: GeoJsonPoint[];
};
const mockGeoJsonData: GeoJsonFeatureCollection = {
  type: 'FeatureCollection',
  features: [
    {
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: [38.7443, 9.040257] // San Francisco
      },
      properties: {
        id: 'warehouse1',
        name: 'Warehouse 1'
      }
    },
    {
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: [38.7443, 9.062257] // San Francisco
      },
      properties: {
        id: 'warehouse1',
        name: 'Warehouse 1'
      }
    },
    {
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: [38.7643, 9.050257] // Second Location
      },
      properties: {
        id: 'warehouse2',
        name: 'Warehouse 2'
      }
    },
  ]
};



const MapComponent = () => {
  const [viewport, setViewport] = useState({
    latitude: 37.7577,
    longitude: -122.4376,
    zoom: 1,
  });
  const [size, setSize] = useState(50);
  // State for tracking the current step
  const [currentStep, setCurrentStep] = useState(1);

  // Other states (selectedLocation, size, etc.) go here...

  // Handlers for each step
  const handleLocationNext = () => {
    setCurrentStep(2); // Proceed to size selection
  };

  const handleSizeNext = () => {
    setCurrentStep(3); // Proceed to final confirmation
  };

  const handleFinalSubmit = () => {
    setCurrentStep(4);
    setSelectedLocation(null);
  };

  const handleSliderChange = (event: any) => {
    setSize(event.target.value);
  };

  // State for the selected location
  const [selectedLocation, setSelectedLocation] = useState<{
    longitude: number;
    latitude: number;
  } | null>(null);

  const handleMapClick = (event: any) => {

    // Check if event.lngLat is defined and is an object
    if (event.lngLat && typeof event.lngLat === 'object') {

      const { lng, lat } = event.lngLat;
      setSelectedLocation({
        longitude: lng,
        latitude: lat
      });
      console.log(`Longitude: ${lng}, Latitude: ${lat}`);
    }
  };


  // Function to fetch current location
  const fetchCurrentLocation = () => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(position => {
        setSelectedLocation({
          latitude: position.coords.latitude,
          longitude: position.coords.longitude
        });
      }, (error) => {
        console.error("Error Code = " + error.code + " - " + error.message);
      });
    } else {
      console.log("Geolocation is not supported by this browser.");
    }
  };

  useEffect(() => {
    // Fetch current location on component mount
    fetchCurrentLocation();
  }, []);



  return (
    <div className='flex min-h-screen'>
      <div className='w-1/3 bg-gray-100 flex flex-col justify-start items-center'>
      <div className='w-full mt-2 mx-4 px-2 flex items-center'>
          <div className='ml-auto flex items-center'>
            <img src={"profile-icon.png"} alt='Profile' className='h-8 w-8 rounded-full mr-2' />
            <span className='font-semibold'>John Doe</span> {/* Replace with dynamic name */}
          </div>
        </div>
        {currentStep === 1 && (
          <>
            <span className='mx-auto font-semibold mt-8 text-xl'>Select property location</span>
            <button onClick={fetchCurrentLocation} className='mt-4 bg-blue-500 text-white p-2 rounded'>Use Current Location</button>

            <div className='card flex mt-8'>
              <div className='flex flex-col rounded-lg border border-gray-300 p-2'>
                {selectedLocation ? (
                  <>
                    <span className='mt-2 font-bold'>Selected proprty location</span>
                    <span className='mt-3 text-gray-700'>Latitude: {selectedLocation.latitude.toFixed(5)}</span>
                    <span className='mt-3 text-gray-700'>Longitude: {selectedLocation.longitude.toFixed(5)}</span>
                    <button onClick={handleLocationNext} className='rounded-lg w-full mt-2 py-2 border bg-green-500 text-sm'>Next</button>
                  </>
                ) : (
                  <span className='mt-3 text-gray-700'>Click on the map to select a location</span>
                )}
              </div>
            </div>
          </>
        )}

        {currentStep === 2 && (<div className='card mt-8 p-4 border border-gray-300 rounded-lg'>
          <div className='text-lg font-semibold mb-2'>Select Product Size</div>
          <div className='flex items-center'>
            <input
              type="range"
              min="1"
              max="100"
              value={size}
              onChange={handleSliderChange}
              className='w-full text-blue-700 bg-blue-600'
            />
            <div className='text-center'>{size}</div>
            <select className='ml-2'>
              <option value="kg">Kg</option>
              <option value="crate">Crate</option>
            </select>
          </div>
          <button onClick={handleSizeNext} className='rounded-lg w-full mt-2 py-2 border bg-green-500 text-sm'>Next</button>
        </div>)}

        {currentStep === 3 && (
          <div className='card mt-8 p-4 border border-gray-300 rounded-lg'>
            <div className='text-md font-semibold mb-2'>Confirm your reservation</div>
            <div className='flex items-center'>
            </div>
            <button onClick={handleFinalSubmit} className='rounded-lg w-full mt-2 py-2 border bg-green-500 text-sm'>Submit Reservation</button>
            <button onClick={() => setCurrentStep(1)} className='rounded-lg w-full mt-2 py-2 border bg-green-500 text-sm'>Start Over</button>
          </div>)}
          {currentStep === 4 && (
          <div className='card mt-8 p-4 border border-gray-300 rounded-lg'>
            <div className='text-md font-semibold mb-2'>Reservation succesful!</div>
            <div className='flex items-center'>
            </div>
              <button onClick={() => setCurrentStep(1)} className='rounded-lg w-full mt-2 py-2 border bg-green-500 text-sm'>Go to home</button>
          </div>)}
      </div>
      <div className='w-2/3'>
        <Map
          mapLib={import('mapbox-gl')}
          initialViewState={{
            longitude: 38.74776,
            latitude: 9.047,
            zoom: 12,
          }}
          mapStyle="mapbox://styles/mapbox/streets-v11"
          style={{ width: '100%', height: '100%' }}
          mapboxAccessToken={process.env.NEXT_PUBLIC_MAPBOX_ACCESS_TOKEN}
          onClick={handleMapClick}
        >
          {selectedLocation && (
            <Marker
              latitude={selectedLocation.latitude}
              longitude={selectedLocation.longitude}
              draggable={true}
            > 
             <img src={'product-xxl.png'} className='h-8' alt='some alt image info' />
            </Marker>

          )}
          {mockGeoJsonData.features.map((feature) => (
            <Marker
              key={feature.properties.id}
              latitude={feature.geometry.coordinates[1]}
              longitude={feature.geometry.coordinates[0]}
              draggable={true}
            >
              <img src={'storage-marker.png'} className='h-10' alt='some alt image info' />
            </Marker>
          ))}
          <NavigationControl />
          <GeolocateControl />
        </Map>
      </div>
    </div>
  );
};
export default MapComponent