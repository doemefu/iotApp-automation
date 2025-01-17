# Device Management Service

## Overview
The Device Management Service handles **IoT device registration, status monitoring, inbound data ingestion, and outbound commands** via **MQTT**.

---

## Responsibilities
1. **Device Registration & Authentication**
    - Maintain a registry of IoT devices (unique IDs, status, metadata).
    - Provide an authentication mechanism for devices.
    - **Best-Practice Suggestion**: Use a device-specific token or certificate; can be managed here or via the Auth Service for a unified approach.
2. **Inbound Data Handling**
    - Subscribe to MQTT topics for incoming sensor data or device events.
    - Update device statuses.
    - Forward or store sensor data (e.g., in InfluxDB or queue for the Data Processing Service).
3. **Command & Control**
    - Send commands to devices over MQTT topics (triggered by frontend actions or automation rules).
4. **Device Offline Alerts**
    - Detect devices that fail to send “heartbeat” or data within a configured interval.
    - Trigger alerts or notifications.

---

## Proposed Architecture

### Textual Description
1. **MQTT Broker**: Using **Mosquitto** to handle publish/subscribe.
2. **Device Registry**: A table storing device info (device ID, status, last-seen timestamp).
3. **Inbound Data Flow**: MQTT -> Device Management -> (optional) Data Processing or database.
4. **Outbound Commands**: Frontend -> Device Management -> MQTT -> Device.

```plantuml
@startuml

rectangle "Device Management Service" as DMS {
    interface "REST /devices" as DEVICES
    interface "MQTT Topic /devices/{id}/data" as DEV_DATA
    interface "MQTT Topic /devices/{id}/commands" as DEV_CMDS
}

rectangle "Mosquitto Broker" as MQTT
rectangle "Frontend" as FE
rectangle "Data Processing Service" as DPS

DMS -> MQTT: Subscribe to device data topics
MQTT -> DMS: Device data messages
DMS -> DPS: Forward data (via REST or internal queue)
FE -> DMS: [POST /devices/{id}/command] Send command
DMS -> MQTT: Publish command to /devices/{id}/commands

@enduml
```

### Class diagram

```plantuml
@startuml
title Device Management Service - Class Diagram

class DeviceController {
  + registerDevice(deviceDto: DeviceDto): ResponseEntity<DeviceDto>
  + getDevices(): ResponseEntity<List<DeviceDto>>
  + sendCommand(deviceId: String, command: String): ResponseEntity<Void>
  + getDeviceStatus(deviceId: String): ResponseEntity<DeviceStatusDto>
}

class DeviceService {
  + registerDevice(deviceDto: DeviceDto): Device
  + getAllDevices(): List<Device>
  + sendCommand(deviceId: String, command: String): void
  + updateStatus(deviceId: String, status: DeviceStatus): void
  + getDeviceStatus(deviceId: String): DeviceStatus
}

class DeviceRepository {
  + save(device: Device): Device
  + findById(deviceId: String): Optional<Device>
  + findAll(): List<Device>
  + update(device: Device): Device
}

class MqttClientAdapter {
  + publish(topic: String, payload: String): void
  + subscribe(topic: String, callback: MqttCallback): void
}

class Device {
  + deviceId: String
  + name: String
  + status: DeviceStatus
  + lastSeen: Date
}

enum DeviceStatus {
  ONLINE
  OFFLINE
  ERROR
}

DeviceController --> DeviceService
DeviceService --> DeviceRepository
DeviceService --> MqttClientAdapter : For sending commands
Device --> DeviceStatus
@enduml
```

**Diagram**

- **DeviceController**: REST endpoints to manage devices (registration, listing, sending commands).
- **DeviceService**: Business logic, updates device statuses, manages MQTT interactions, etc.
- **DeviceRepository**: Persistence logic for storing and retrieving device data.
- **MqttClientAdapter**: A wrapper or adapter around the MQTT library (e.g., Paho, Eclipse) for publish/subscribe.
- **Device**: Entity representing an IoT device record.
- **DeviceStatus**: Enum for device states.

---

## Interfaces
1. **MQTT Broker (Mosquitto)**
    - **Type**: MQTT
    - **Purpose**: Pub/Sub transport for device data and commands.
2. **Data Processing Service**
    - **Type**: REST or internal message queue
    - **Purpose**: Forward sensor data for analysis and storage.
3. **Frontend**
    - **Type**: REST
    - **Endpoints**:
        - `GET /devices` (list devices)
        - `POST /devices` (register new device)
        - `POST /devices/{id}/command` (send command)

---

## Database
- **Device Registry**: PostgreSQL or a simple key-value store to keep track of device info.
- **Last-Seen & Status**: Keep track of timestamps to alert if a device is offline.

---

## Security & Maintenance
- **Best-Practice Suggestion**: If the device secrets are stored here, encrypt them at rest.
- **Offline Alert**: Poll or event-driven detection for inactivity.

---