# IoT Application Automation

## Overview
This repository contains the automation scripts and deployment configurations for the IoT Application, which is designed to manage IoT devices, process data, and provide user management and authentication services. The application is structured into several microservices, each responsible for a specific part of the functionality.

## Initial Situation
The initial project was a monolithic backend for an IoT application written in Java with Spring Boot. To improve modularity, scalability, and maintainability, the project has been refactored into a microservices architecture. This comes as a further development/evolution from the [`iotApp`](https://github.com/doemefu/iotApp), [`frontIotApp`](https://github.com/doemefu/frontIotApp), and `orchestrationIotApp` repositories and is still under development.

## Microservices Architecture

### Modules

1. **Auth Service (auth-service)**
   - **Language:** Java with Spring Boot
   - **Description:** Handles user authentication, token generation, and validation using OAuth 2.0 and JWT.
   - **Responsibilities:**
     - User login and logout
     - Token generation and validation
     - Password management (reset, change)
   - **Communication:** Provides JWT tokens to authenticated users. Other services validate these tokens with the Auth Service.

2. **User Management Service (user-management-service)**
   - **Language:** Java with Spring Boot
   - **Description:** Manages user profiles, roles, and permissions.
   - **Responsibilities:**
     - CRUD operations for user profiles
     - Role-based access control (RBAC)
     - User activity logs
   - **Communication:** Receives requests from the frontend with JWT tokens for authentication. Validates tokens with the Auth Service.

3. **Device Management Service (device-management-service)**
   - **Language:** Python with FastAPI
   - **Description:** Handles registration and management of IoT devices, processes inbound data, and monitors device status.
   - **Responsibilities:**
     - Registering and managing IoT devices
     - Handling inbound data from IoT devices via MQTT
     - Device status monitoring
   - **Communication:** Receives data from IoT devices, validates device tokens, and communicates with the Data Service for data forwarding.

4. **Data Processing Service (data-processing-service)**
   - **Language:** Python with FastAPI
   - **Description:** Processes incoming data from IoT devices and serves the processed data to the frontend.
   - **Responsibilities:**
     - Processing and analyzing incoming data
     - Storing processed data in a time-series database (InfluxDB)
     - Providing data to the frontend and other services
   - **Communication:** Receives data from the Device Service, processes it, and provides APIs for accessing processed data.

5. **MQTT Broker**
   - **Language:** C
   - **Description:** Handles registration and management of IoT devices, processes inbound data, and monitors device status.
   - **Responsibilities:**
       - Managing data Traffic between IoT devices

### Communication Between Modules
- **REST APIs:** Used for communication between the frontend and services, and between services.
- **JWT (JSON Web Token):** Used for secure authentication between services and users.
- **MQTT:** Used for communication between IoT devices and the Device Service.
- **Service Discovery:** Consul or Eureka for dynamic discovery of services.
- **API Gateway:** Kong or AWS API Gateway to route and secure API requests.

### Databases
- **MySQL (PostgreSQL):** Used for storing user data, profiles, and roles.
- **InfluxDB:** Used for storing time-series sensor data collected from IoT devices.

### Deployment on Raspberry Pi
- **Automation:** Ansible scripts are used to automate the deployment process.
- **Docker:** All microservices run as Docker containers.
- **K3s:** Lightweight Kubernetes distribution used to orchestrate Docker containers.

### Possible Addons

1. **Telemetry Monitoring Module (Go)**
   - **Language:** Go
   - **Description:** Collects, processes, and stores telemetry data from IoT devices. Provides real-time insights into device performance and metrics.
   - **Responsibilities:**
     - Data ingestion, processing, and storage
     - Providing APIs for querying telemetry data
   - **Communication:** Uses Go routines for concurrent data processing and InfluxDB for storage.

2. **Low-Level Device Driver Module (C)**
   - **Language:** C
   - **Description:** Interacts with low-level hardware components of IoT devices, implementing device drivers for sensors and actuators.
   - **Responsibilities:**
     - Interfacing with hardware sensors and actuators
     - Implementing protocols for sensor data acquisition
     - Providing APIs for higher-level modules to interact with hardware
   - **Communication:** Direct interaction with hardware components, providing a C API for other modules.

## How to Use
1. **Clone the Repository:**
   ```bash
   git clone https://github.com/doemefu/iotApp-automation.git
   cd iotApp-automation
   ```

2. **Set Up Ansible:**
   Follow the instructions in the `ansible/README.md` to configure and run the Ansible scripts for deploying the microservices on a Raspberry Pi.

3. **Deploy Services:**
   Use the provided Docker Compose or K3s configurations to deploy the microservices.

4. **Monitor and Manage:**
   Use the provided monitoring and management tools to ensure the services are running smoothly.

## Frontend Access
The frontend for this IoT application is accessible at [furchert.ch](https://furchert.ch).

---
