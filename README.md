## Cargo Listing Module (`CargoListing.cairo`)

### Overview
`CargoListing.cairo` is a fundamental module in the Starknet-Powered Cargo-Pooling Platform. It manages cargo listings, enabling operations like adding, updating, removing, and transferring cargo. Additional features include cargo filtering based on size and weight preferences, and an ability to count the total number of cargo listings.

### Key Components

#### Structs
- **Cargo**: Represents a cargo item with properties such as `id`, `weight`, `size`, `destination`, `origin`, `owner`, and `status`.
- **Preference**: Captures driver preferences, including `size`, `weight`, and `proximity`.
- **Location**: Stores geographical location with `latitude` and `longitude` fields.

#### Enum
- **CargoStatus**: Enumerates possible states of cargo like `Available`, `Matched`, `InTransit`, `Unavailable`, and `Delivered`.

#### Functions
- **`add_cargo`**: Adds a new cargo listing. Parameters include `weight`, `size`, `destination`, and `origin`. The cargo is added with the status `Available` and assigned an ID.
- **`update_cargo`**: Updates an existing cargo listing by `listing_id`. Allows modification of `weight`, `size`, `destination`, `origin`, and `status`. Includes ownership check to ensure only the cargo owner can update it.
- **`remove_cargo`**: Marks a cargo as `Unavailable` rather than deleting it. Ensures that cargo history is maintained. Ownership check is included.
- **`transfer_cargo_ownership`**: Transfers ownership of a cargo listing to the caller of the function. Useful in scenarios like cargo delivery acceptance.
- **`get_cargo_list`**: Returns an array of all cargo listings. Demonstrates basic retrieval of cargo items.
- **`filter_cargo_by_size`**: Filters cargo listings based on size preference. Returns an array of cargo that meets the specified size criteria.
- **`filter_cargo_by_weight`**: Similar to size filtering, but focuses on the weight of cargo listings.
- **`get_cargo_count`**: Provides the total count of cargos listed.

### Usage Examples
- **Adding Cargo**: `add_cargo(1000, 2, {lat, long}, {lat, long})` - Adds cargo with weight 1000, size 2, and specified destination and origin.
- **Updating Cargo**: `update_cargo(1, 1200, 3, {newLat, newLong}, {newLat, newLong}, CargoStatus::InTransit)` - Updates cargo with `listing_id` 1.
- **Filtering by Size**: `filter_cargo_by_size({2, 1000, 10})` - Retrieves cargos with size <= 2.

### Error Handling
Custom error messages are defined in the `Errors` module for handling unauthorized access and invalid operations. For instance, attempting to update cargo without being the owner results in an `UNAUTHORIZED` error.

---

This detailed README section provides a comprehensive guide to the `CargoListing.cairo` module. It includes explanations of key components, functionality, usage examples, and error handling mechanisms. 

---

## Matching Algorithm Module (`MatchingAlgorithm.cairo`)

### Overview
The `MatchingAlgorithm.cairo` module is essential for the cargo-to-driver matching process in the Starknet-Powered Cargo-Pooling Platform. It implements logic to filter cargos based on driver preferences, such as size and weight, ensuring optimal matches.

### Key Components

#### Interface: `ICargoMatching<TContractState>`
Defines methods for cargo matching and filtering:
- `filter_cargo_by_size`: Filters cargo based on size preference.
- `filter_cargo_by_weight`: Filters cargo based on weight preference after size filtering.
- `fetch_cargo_list`: Fetches a list of cargos from the cargo listing contract.

#### Structs and Enums
- **Cargo**: Represents individual cargo items, including details like weight, size, and destination.
- **Driver**: Holds driver details, including preferences and location.
- **Preference**: Captures driver preferences in terms of cargo size, weight, and proximity.
- **Location**: Stores geographical coordinates.
- **CargoStatus**: Enumerates the possible states of cargo.

### Functionality

1. **Filtering by Size (`filter_cargo_by_size`)**: 
   - Retrieves a list of cargos and filters them based on the size preference specified by the driver. 
   - Utilizes the `ICargoListingDispatcher` interface to interact with the cargo listing contract.

2. **Filtering by Weight (`filter_cargo_by_weight`)**: 
   - Takes the output from `filter_cargo_by_size` and applies an additional filter based on the weight preference.
   - Ensures a more refined and suitable match for drivers.

3. **Fetching Cargo List (`fetch_cargo_list`)**: 
   - Provides functionality to fetch the complete list of cargos from the cargo listing contract for further processing.

### Usage Examples
- **Filtering by Size**: To filter cargos based on size preference, call `filter_cargo_by_size` with the driver's preference and the contract address of the cargo listing.
- **Filtering by Weight**: After size filtering, use `filter_cargo_by_weight` to further refine the list based on weight preference.

### Notes
- The current implementation emphasizes the importance of multi-level filtering (size followed by weight) to achieve efficient cargo-to-driver matching.
- The code utilizes interfaces to interact with other contracts, showcasing a modular and scalable approach.

---

This README section offers a clear and detailed overview of the `MatchingAlgorithm.cairo` module, explaining its role, functionality, and usage in the context of oour cargo-pooling platform. This should provide users and developers with a solid understanding of how this module contributes to the overall system. 

---

## Shipment Tracking Module (`ShipmentTracking.cairo`)

### Overview
The `ShipmentTracking.cairo` module is an integral part of the Starknet-Powered Cargo-Pooling Platform, focusing on monitoring and updating the status of cargo shipments. This module provides functionalities to update the status of cargos, notify users about status changes, and confirm the delivery of cargos.

### Key Features

#### Status Update and Notification
- **`update_cargo_status`**: This function updates the status of a cargo identified by `cargo_id`. It includes checks to ensure that the caller is the owner of the cargo. After updating the status, it calls `notifyUsers` to inform relevant parties about the status change.
- **`notifyUsers`**: Notifies users regarding the change in cargo status. It constructs a notification message detailing the change and updates the notification system of the platform.

#### Delivery Confirmation
- **`confirmDelivery`**: Confirms the delivery of a cargo. This function is called when cargo reaches its destination. It updates the cargo's status to `Delivered`, processes the payment for the shipment, and sends a notification about the delivery confirmation.

### Code Functionality

1. **Tracking and Updating Cargo Status**:
   - Retrieves the cargo details based on `cargo_id`.
   - Verifies the ownership of the cargo before allowing status updates.
   - Capable of tracking the shipment throughout different stages like `InTransit` or `Delivered`.

2. **User Notification Mechanism**:
   - Sends automated notifications to users (both sender and recipient) whenever there's a change in cargo status.
   - Helps in keeping all parties informed about the shipment progress.

3. **Finalizing Deliveries**:
   - Facilitates the process of confirming deliveries.
   - Integrates with `TransactionAndPayment` module for processing payments upon delivery completion.

### Usage Examples
- **Updating Cargo Status**: To update the status of a cargo, call `update_cargo_status` with the cargo ID and the new status.
- **Confirming Delivery**: Once the cargo reaches its destination, `confirmDelivery` is used to mark the cargo as delivered and process the associated payment.

### Error Handling
- The module includes error handling to ensure that only authorized users (cargo owners) can update cargo statuses.
- Notifications and delivery confirmations are contingent upon successful identification of cargo and user details.

---

This section of the README offers a comprehensive understanding of the `ShipmentTracking.cairo` module, its role in cargo tracking, status updates, and delivery confirmations within our platform. It emphasizes the module's contribution to ensuring transparency and efficiency in the shipment process. 

Thank you for sharing the contents of the `TransactionAndPayment.cairo` module. Based on this code, I will provide a detailed breakdown for a section in the README file to explain its functionality and importance within our Starknet-Powered Cargo-Pooling Platform.

---

## Transaction and Payment Module (`TransactionAndPayment.cairo`)

### Overview
The `TransactionAndPayment.cairo` module handles the financial transactions and payment processes in the cargo-pooling platform. It includes functionalities for checking balances, initiating transactions, processing payments, and notifying users of transaction activities.

### Key Features

#### Balance Check and Transaction Initiation
- **`check_balance`**: Checks the balance of a given address. This is a preliminary step in the transaction process to ensure sufficient funds.
- **`initiate_transaction`**: Initiates a transaction by first verifying the sender's balance and then proceeding with the fund transfer.

#### Payment Processing
- **`process_payment`**: Processes payments for cargo shipments. It verifies if the cargo has been shipped (status `InTransit`) and calculates the payment amount based on cargo size, weight, and destination.
- **`calculate_payment_amount`**: Calculates the amount to be paid for a shipment. The calculation logic is based on the cargo's size, weight, and distance to the destination.

#### User Notification
- **`notify_users`**: Similar to the notification function in the `ShipmentTracking` module, it notifies users about the payment transactions they have been involved in.

### Code Functionality

1. **Transaction Management**: 
   - Ensures that all transactions are initiated only after verifying sufficient funds.
   - Handles the transfer of funds between addresses securely and efficiently.

2. **Payment Calculation for Shipments**: 
   - Dynamically calculates the payment amount for each shipment based on multiple factors, adding flexibility and fairness to the payment process.

3. **Notification System**: 
   - Keeps users informed about transaction activities, enhancing transparency and trust in the platform.

### Usage Examples
- **Checking Balance**: Call `check_balance` with a user address to retrieve the current balance.
- **Processing Payment**: Use `process_payment` for a cargo to handle the entire payment transaction post-shipment.

### Error Handling and Security
- Includes checks for cargo status and user balance to prevent unauthorized or erroneous transactions.
- Asserts and validations are used to maintain the integrity of transactions.

---

This README section provides a thorough understanding of the `TransactionAndPayment.cairo` module, highlighting its critical role in managing financial transactions within our cargo-pooling platform. It outlines the module's functionalities, usage, and importance in maintaining a secure and transparent transaction environment.

---

## User Management Module (`UserManagement.cairo`)

### Overview
The `UserManagement.cairo` module is responsible for handling user-related functionalities in the cargo-pooling platform. This includes registering users, authenticating them, and managing user profiles.

### Key Features

#### User Registration and Authentication
- **`register_user`**: Registers a new user. It uses the caller's address as the user's unique identifier and checks if the user is already registered to prevent duplicate entries.
- **`authenticate_user`**: Authenticates a user by verifying if the caller's address is present in the registered users' list.

#### User Profile Management
- **`get_user_profile`**: Retrieves the profile of a user. This function ensures that only the user whose profile is being requested (or authorized entities) can access it, maintaining privacy and security.

### Structs and Storage
- **Struct User**: Represents a user with a minimal structure, currently storing only the `address`.
- **Storage**: Utilizes a `LegacyMap` to store user data, mapping `ContractAddress` to `User` objects.

### Code Functionality

1. **User Registration**: 
   - Facilitates the addition of new users to the system, enhancing the user base.
   - Ensures that a user cannot be registered more than once.

2. **Authentication**: 
   - Checks if a user is registered, a necessary step for secure access to various platform functionalities.
   - Crucial for maintaining the integrity and security of user operations within the platform.

3. **Profile Management**: 
   - Allows users to retrieve their profile information securely.
   - Protects user data by ensuring only authorized access.

### Usage Examples
- **Registering a User**: To register, a user simply calls `register_user` without needing to pass explicit parameters since it uses the caller's address.
- **Authenticating a User**: For authentication, `authenticate_user` is called, and it checks if the caller is a registered user.

### Security and Privacy
- The module includes checks to ensure that only registered and authenticated users can access certain functionalities.
- Privacy is maintained by restricting access to user profiles, allowing only the owner (or authorized entities) to view their profile.

---

This README section provides an understanding of the `UserManagement.cairo` module, its importance in managing user accounts, authentication, and profile access in our platform.

---

## Errors Module (`Errors.cairo`)

### Overview
The `Errors.cairo` module plays a crucial role in defining standardized error messages across the cargo-pooling platform. This module enhances the readability and maintainability of the code by centralizing error message definitions.

### Key Error Definitions
- **UNAUTHORIZED**: Indicates an unauthorized access attempt, typically used in situations where a user or process attempts to perform an action without proper permissions.
- **NOT_FOUND**: Used when a requested item, such as a user or cargo, is not found in the system.
- **NOT_UNIQUE**: Signals that an item that is required to be unique (such as a user ID) is not.
- **NOT_ZERO**: Used in contexts where a value is expected to be non-zero, typically for validation purposes.
- **NOT_POSITIVE**: Indicates that a value, expected to be positive, is not. This can be important in financial calculations or quantity checks.
- **NOT_NULL**: Asserts that a certain value or parameter should not be null, ensuring the integrity of data and operations.

### Importance in the Application
- **Standardization of Error Handling**: By defining common error messages in a centralized module, the platform ensures consistency in error handling. This makes debugging and maintenance more straightforward.
- **Enhanced Code Readability**: Having a separate module for error messages declutters the main business logic code and improves overall readability.
- **Improved User Experience**: Consistent and clear error messages contribute to a better understanding for users or developers interacting with the system, especially in debugging scenarios.

### Usage in the Platform
These error messages are used throughout various modules of the application, like `UserManagement.cairo`, `CargoListing.cairo`, and `TransactionAndPayment.cairo`, to handle exceptions and errors uniformly.

### Example
In a function where user authentication is required, the `UNAUTHORIZED` error can be used to indicate failure in user verification.

---

This section for the README outlines the significance of the `Errors.cairo` module, emphasizing how standardized error messages contribute to the efficiency and clarity of our platform's codebase. 
