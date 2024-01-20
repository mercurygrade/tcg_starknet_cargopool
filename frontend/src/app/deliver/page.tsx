"use client"

import React, { useState, useEffect , useMemo} from 'react';
import Map, { Marker, NavigationControl, GeolocateControl, Source, Layer } from 'react-map-gl';
import "mapbox-gl/dist/mapbox-gl.css";

// Assuming this type represents a delivery order
type DeliveryOrder = {
  id: string;
  pickupLocation: { latitude: number; longitude: number; };
  deliveryLocation: { latitude: number; longitude: number; };
  size: number; // Size of the cargo
  // Additional properties like address, customer details, etc.
};


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
        coordinates: [38.7443, 9.040257]
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
        coordinates: [38.7443, 9.062257]
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

const DriverDashboard = () => {
  const [orders, setOrders] = useState<DeliveryOrder[]>([]);
  const [currentOrder, setCurrentOrder] = useState<DeliveryOrder | null>(null);
  const [phase, setPhase] = useState('pickup'); // 'pickup' or 'delivery'
  const [route, setRoute] = useState<any>(null); // State to store the route data
  const myLocation = useMemo(() => [38.74776, 9.047], []); // Replace with driver's current location
  const [viewDetail, setViewDetail] = useState(false);


  // Function to fetch route from Mapbox Directions API
  const fetchRoute = async (start: [number, number], end: [number, number]) => {
    const url = `https://api.mapbox.com/directions/v5/mapbox/driving/${start.join(",")};${end.join(",")}?alternatives=false&geometries=geojson&overview=full&steps=false&access_token=${process.env.NEXT_PUBLIC_MAPBOX_ACCESS_TOKEN}`;

    try {
      const response = await fetch(url);
      const data = await response.json();
      setRoute(data.routes[0].geometry); // Assuming first route is the desired one
    } catch (error) {
      console.error("Error fetching route", error);
    }
  };
  // Mock data for orders - replace with real data fetching logic
  useEffect(() => {
    const mockOrders: DeliveryOrder[] = [
      {
        id: 'order1',
        pickupLocation: { latitude: 9.06843, longitude: 38.760257 },
        deliveryLocation: { latitude: 9.062257, longitude: 38.7443 },
        size: 50,
      },
      {
        id: 'order2',
        pickupLocation: { latitude: 9.063257, longitude: 38.75437 },
        deliveryLocation: { latitude: 9.062257, longitude: 38.7443 },
        size: 50,
      },
      // ...add more mock orders
    ];
    setOrders(mockOrders);
  }, []);

  useEffect(() => {
    if (currentOrder) {
      let start: [number, number], end: [number, number];
      if (phase === 'pickup') {
        start = [myLocation[0], myLocation[1]];
        end = [currentOrder.pickupLocation.longitude, currentOrder.pickupLocation.latitude];
      } else if (phase === 'delivery') {
        start = [currentOrder.pickupLocation.longitude, currentOrder.pickupLocation.latitude];
        end = [currentOrder.deliveryLocation.longitude, currentOrder.deliveryLocation.latitude];
      }
      if (start && end) {
        fetchRoute(start, end);
      }
    }
  }, [currentOrder, myLocation, phase]);

  
  const handlePickupComplete = () => {
    if (currentOrder) {
      setRoute(null); // Reset route state
      setPhase('delivery');
    }
  };
  
  const handleDeliveryComplete = () => {
    if (currentOrder) {
      setRoute(null); // Reset route state
      setCurrentOrder(null);
      setPhase('pickup');
    }
  };
  


  const handleOrderSelect = (order: DeliveryOrder) => {
    setViewDetail((state) => !state);
    setCurrentOrder(order);
    setPhase('pickup');
  };
  const handleBackClick = () => {
    if (viewDetail === 'pickupDetails' || viewDetail === 'deliveryDetails') {
      setViewDetail('orders'); // Go back to orders view
    }
    // Add more conditions if there are more views
  };



  return (
    <div className='flex min-h-screen'>
      <div className='w-1/3 bg-gray-100 flex flex-col justify-start py-4 items-center'>
      <div className='w-full mx-4 px-2 flex items-center'>
          {/* <img src={"backArrowIcon.png"} alt='Back' className='h-6 w-6 mr-2 cursor-pointer' onClick={handleBackClick} /> */}
          <div className='ml-auto flex items-center'>
            <img src={"profile-icon.png"} alt='Profile' className='h-8 w-8 rounded-full mr-2' />
            <span className='font-semibold'>John Doe</span> {/* Replace with dynamic name */}
          </div>
        </div> 
        <div className='w-full mx-4 mt-2 px-2 flex border-2 rounded-lg p-2 font-semibold text-sm'>My deliveries</div>
        {!viewDetail && orders.map(order => (
          <div key={order.id} className='w-3/4 mt-4 p-4 border border-gray-300 rounded-lg'>
            <div className='text-md mb-2'>Order ID: {order.id}</div>
            <img className='h-16 mx-auto' src='package-icon.png' alt='package icon' />
            <p className='text-sm'>size: 20kg</p>
            <button onClick={() => handleOrderSelect(order)} className='rounded-lg w-full mt-2 py-2 border bg-green-400 text-white text-sm'>
              View Details
            </button>
          </div>
        ))}

        {currentOrder && phase === 'pickup' && (
          <div className='card mt-8 p-4 border border-gray-300 rounded-lg'>
            <div className='text-md font-semibold mb-2'>Pick Up Details</div>
            <img className='h-16 mx-auto' src='package-icon.png' alt='package icon' />
            <p className='text-sm'>size: 20kg</p>
            <p className='text-sm'>Pick up at Lat: {currentOrder.pickupLocation.latitude.toFixed(5)}, Long: {currentOrder.pickupLocation.longitude.toFixed(5)}</p>
            <button onClick={handlePickupComplete} className='rounded-lg w-full mt-2 py-2 border bg-green-500 text-white text-sm'>Confirm Pick Up</button>
          </div>
        )}

        {currentOrder && phase === 'delivery' && (
          <div className='card mt-8 p-4 border border-gray-300 rounded-lg'>
            <div className='text-md font-semibold mb-2'>Delivery Details</div>
            <img className='h-16 mx-auto' src='package-icon.png' alt='package icon' />
            <p className='text-sm'>size: 20kg</p>
            <p className='text-sm'>Deliver to Lat: {currentOrder.deliveryLocation.latitude.toFixed(5)}, Lon: {currentOrder.deliveryLocation.longitude.toFixed(5)}</p>
            <button onClick={handleDeliveryComplete} className='rounded-lg w-full mt-2 py-2 border bg-green-500 text-white text-sm'>Complete Delivery</button>
          </div>
        )}
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
        >
          {
            route && (
              <Source id="route" type="geojson" data={route}>
                <Layer
                  id="routeLayer"
                  type="line"
                  source="route"
                  layout={{
                    "line-join": "round",
                    "line-cap": "round"
                  }}
                  paint={{
                    "line-color": "#3887be",
                    "line-width": 6
                  }}
                />
              </Source>
            )}
          {
            // driver location
            <Marker
              latitude={myLocation[1]}
              longitude={myLocation[0]}
              color='Red'
            />
          }
          {currentOrder && (
            <>
              <Marker
                latitude={currentOrder.pickupLocation.latitude}
                longitude={currentOrder.pickupLocation.longitude}

              >
                <img className='h-8' src='product-xxl.png' alt='package icon' />
              </Marker>
            </>
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

export default DriverDashboard;