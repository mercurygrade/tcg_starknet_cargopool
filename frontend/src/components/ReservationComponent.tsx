import React, { useState } from 'react';

const ReservationComponent = () => {
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
    // Handle the final submission logic here
  };

  return (
    <div className='w-1/3 flex flex-col items-center'>
      {/* Step 1: Select Location */}
      {currentStep === 1 && (
        <div className='card flex mt-8'>
          {/* ...Existing code for location selection... */}
          <button onClick={handleLocationNext} className='rounded-lg w-full mt-2 py-2 border bg-green-500 text-sm'>Next</button>
        </div>
      )}

      {/* Step 2: Input Size */}
      {currentStep === 2 && (
        <div className='card mt-8 p-4 border border-gray-300 rounded-lg'>
          {/* ...Existing code for size input... */}
          <button onClick={handleSizeNext} className='rounded-lg w-full mt-2 py-2 border bg-green-500 text-sm'>Next</button>
        </div>
      )}

      {/* Step 3: Submit Reservation */}
      {currentStep === 3 && (
        <div className='card mt-8 p-4 border border-gray-300 rounded-lg'>
          <div className='text-md font-semibold mb-2'>Confirm your reservation</div>
          {/* Additional confirmation details can be added here */}
          <button onClick={handleFinalSubmit} className='rounded-lg w-full mt-2 py-2 border bg-green-500 text-sm'>Submit Reservation</button>
          <button onClick={() => setCurrentStep(1)} className='rounded-lg w-full mt-2 py-2 border bg-green-500 text-sm'>Start Over</button>
        </div>
      )}
    </div>
  );
};

export default ReservationComponent;
