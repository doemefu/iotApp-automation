# IoT Application Architecture

## **1. Presentation Layer**
This layer contains the user-facing components.

- **Frontend**:
    - Accessible at [furchert.ch](https://furchert.ch).
    - Provides user interfaces for device management, data visualization, and user administration.

---

## **2. Application Layer**
This layer handles business logic and interactions between services.

- **Auth Service (auth-service)**:
    - Manages user authentication and authorization.
    - Generates and validates JWT tokens for secure communication.

- **User Management Service (user-management-service)**:
    - Manages user profiles, roles, and permissions.
    - Implements Role-Based Access Control (RBAC).
    - Logs user activities.

- **Device Management Service (device-management-service)**:
    - Handles device registration and status monitoring.
    - Validates device tokens and processes inbound data via MQTT.

- **Data Processing Service (data-processing-service)**:
    - Processes and analyzes incoming data from devices.
    - Provides APIs for querying and visualizing processed data.

---

## **3. Communication Layer**
This layer facilitates communication between devices and services.

- **MQTT Broker (mqtt-broker)**:
    - Routes messages between IoT devices and the `device-management-service`.
    - Ensures reliable and efficient message delivery using the MQTT protocol.

- **API Gateway**:
    - Routes external API requests to the appropriate microservice.
    - Enforces security policies such as rate limiting and JWT validation.

- **Service Discovery**:
    - Facilitates dynamic discovery of microservices.
    - Example tools: Consul, Eureka.

---

## **4. Data Layer**
This layer manages data storage and retrieval.

- **MySQL (or PostgreSQL)**:
    - Stores user profiles, roles, and permissions.
    - Used by the `auth-service` and `user-management-service`.

- **InfluxDB**:
    - Stores time-series data from IoT devices.
    - Used by the `data-processing-service`.

---

## **5. Infrastructure Layer**
This layer provides the platform for deploying and running services.

- **K3s (Lightweight Kubernetes)**:
    - Orchestrates microservices and ensures scalability.
    - Manages Docker containers for each microservice.

- **Ansible Automation**:
    - Automates deployment and configuration of services on Raspberry Pi.

- **Monitoring and Logging** (Suggested Additions):
    - **Prometheus + Grafana**: Monitor service health, resource usage, and device metrics.
    - **ELK Stack (Elasticsearch, Logstash, Kibana)**: Centralized logging for all services.

---

## **Optional Additions**
These components could enhance functionality:

- **Telemetry Monitoring Service**:
    - Language: Go.
    - Collects and analyzes telemetry data from devices for performance insights.

- **Low-Level Device Driver Module**:
    - Language: C.
    - Interacts directly with hardware sensors and actuators.
    - Provides APIs for higher-level services.

---