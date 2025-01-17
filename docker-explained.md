
> **Note**:
> 1. Make sure each microservice has a corresponding `Dockerfile` in the specified build context (e.g., `./auth-service`).
> 2. Update environment variables (e.g., passwords, DB names) and configurations as needed.
> 3. The example assumes that the microservices depend on each other in ways we’ve discussed. If a microservice doesn’t require a particular dependency, remove it from the `depends_on` section.

---

## How This Works

1. **PostgreSQL**
    - Runs on container `iotapp_postgres` and stores data in a named volume `postgres_data`.
    - `POSTGRES_USER`, `POSTGRES_PASSWORD`, and `POSTGRES_DB` define your database credentials.

2. **InfluxDB**
    - Runs on container `iotapp_influxdb`, storing data in `influx_data`.
    - Adjust environment variables depending on whether you’re using InfluxDB **1.x** or **2.x**.

3. **Mosquitto (MQTT Broker)**
    - Provides MQTT protocol on port `1883`.
    - Uses named volumes for config, data, and logs.

4. **User Management Service**
    - Built from `./user-management-service` Docker context.
    - Depends on Postgres being up.
    - Exposed on host port `8081` (mapped from container’s `8080`).

5. **Auth Service**
    - Built from `./auth-service` Docker context.
    - Depends on User Management and Postgres.
    - Exposed on host port `8082`.

6. **Device Management Service**
    - Built from `./device-management-service` Docker context.
    - Depends on Mosquitto, Auth, and optionally Postgres.
    - Exposed on host port `8083`.
    - Connects to `mosquitto:1883` for MQTT.

7. **Data Processing Service**
    - Built from `./data-processing-service` Docker context.
    - Depends on InfluxDB and the Device Management Service.
    - Exposed on host port `8084`.
    - Queries InfluxDB at `influxdb:8086`.

8. **Frontend**
    - Built from `./frontend` Docker context.
    - Depends on all backend services.
    - Exposed on host port `3000` (or `80` -> `3000` depending on your Dockerfile).
    - Environment variables point to microservices in the `iot-network`.

---

## Usage

1. **Place this file** (e.g., `docker-compose.yml`) in the root directory of your project.
2. **Check** that each microservice directory has a valid Dockerfile.
3. **Run**:
   ```bash
   docker-compose up --build
   ```
   This builds each service, starts the containers, and attaches logs to your terminal.
4. **Access**:
    - Frontend: <http://localhost:3000> (or whichever port you exposed).
    - Auth Service: <http://localhost:8082>
    - etc.

---

### Tips & Recommendations

- **Service-to-service communication**: Inside the Docker network, services reference each other by container name (e.g., `auth-service:8080`).
- **Volume Persistence**: Data in named volumes (`postgres_data`, `influx_data`, etc.) will persist across container restarts.
- **Configuration**: If you have custom config for Mosquitto, place a `.conf` file in a mapped volume or use a `configs` section.
- **Scaling**: For local dev, this is straightforward. In production, you might prefer a Kubernetes deployment (K3s) as previously discussed.

---

**This setup** should provide a solid **local development environment** with all the moving pieces you’ve described so far. Feel free to modify and tailor to your specific needs (e.g., changing environment variables, ports, volumes, or adding advanced config for your microservices).