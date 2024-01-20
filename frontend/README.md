# CargoPool Frontend

This is a [Next.js](https://nextjs.org/) project bootstrapped with [`create-starknet`](https://github.com/apibara/starknet-react/tree/main/packages/create-starknet), designed to offer a dynamic and user-friendly interface for the innovative CargoPool platform.

## Getting Started

First, run the development server:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
# or
bun dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

Start editing the application by modifying `app/page.tsx`. The page auto-updates as you edit the file. This project uses [`next/font`](https://nextjs.org/docs/basic-features/font-optimization) to automatically optimize and load Inter, a custom Google Font.

## Dashboard Component Overview

The `dashboard` component is a pivotal part of the CargoPool frontend. It features an interactive map for real-time tracking and cargo management, leveraging `react-map-gl`. Users can select cargo locations, specify sizes, and manage reservations through an intuitive interface. This component showcases the use of state management with React hooks and demonstrates the application's commitment to providing a seamless user experience.

---

## Deliver Component Overview

### Introduction
The `deliver` component is an integral part of the CargoPool frontend, focusing on the efficient management and visualization of delivery orders. It features a robust integration with an interactive map, enabling drivers to seamlessly handle their pickup and delivery tasks.

### Features
- **Interactive Map Integration**: Utilizing Mapbox through `react-map-gl`, the component offers real-time tracking and route visualization for deliveries.
- **Order Management**: Displays delivery orders with comprehensive details, including pickup and delivery locations, and the size of the cargo.
- **Dynamic Route Calculation**: Capable of fetching and displaying optimized routes from the driver's current location to the respective pickup and delivery points.
- **Phase Management**: Effectively manages different phases of a delivery journey, from pickup initiation to final delivery completion.

### Implementation Highlights
- **Use of React Hooks**: The component employs React hooks such as `useState` and `useEffect` for efficient state management and handling side effects, ensuring a responsive and interactive user experience.
- **GeoJSON for Map Data**: Implements GeoJSON format to represent warehouse locations and delivery points on the interactive map.
- **Responsive and Intuitive UI**: Designed with responsiveness in mind, the component offers a seamless and intuitive interface across various devices, enhancing usability for drivers.

### Usage
This component is specifically used by drivers within the CargoPool platform. It serves as a vital tool for managing their delivery assignments, from receiving new orders to confirming the completion of deliveries, all through an interactive map-based interface.

---

## List-Cargo Component Overview

### Introduction
The `list-cargo` component is a key feature of the CargoPool frontend, enabling users to list and manage their cargo effectively. This component integrates with an interactive map, allowing precise specification of cargo locations and sizes.

### Features
- **Interactive Map Integration**: Uses Mapbox through `react-map-gl` for selecting cargo locations, making the cargo listing process both accurate and user-friendly.
- **Cargo Size Specification**: Provides a range slider for users to specify the size of their cargo, ensuring detailed and accurate cargo listings.
- **Step-by-Step User Interface**: Guides users through a multi-step process, from location selection to size specification, for clarity and ease of use.

### Implementation Highlights
- **Geolocation Functionality**: Implements geolocation to determine and set the user's current position, offering a quick and convenient option for location selection.
- **React State Management**: Utilizes React hooks like `useState` and `useEffect` for managing states such as viewport settings, cargo size, and selected location, ensuring dynamic interactivity.
- **Map Click Handlers**: Manages user interactions with the map, such as setting cargo locations and visualizing them with markers.

### Usage
This component is primarily designed for users wishing to list their cargo on the CargoPool platform. It serves as an intuitive interface for entering essential cargo details, which is crucial for optimizing the cargo pooling process and enhancing logistics efficiency.

---

## Learn More About Next.js

For more information about Next.js, refer to the following resources:
- [Next.js Documentation](https://nextjs.org/docs) - Features and API.
- [Learn Next.js](https://nextjs.org/learn) - Interactive tutorial.

Explore [the Next.js GitHub repository](https://github.com/vercel/next.js/) for more insights. Your feedback and contributions are appreciated!

## Deploy on Vercel

Deploy your Next.js app effortlessly using the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme), from the creators of Next.js. For detailed instructions, visit our [Next.js deployment documentation](https://nextjs.org/docs/deployment).

---

This README offers a comprehensive guide to the frontend of the CargoPool project, detailing setup instructions, and key features of the dashboard, deliver, and list-cargo components, along with resources for further learning and deployment strategies.
