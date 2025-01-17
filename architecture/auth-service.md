# Auth Service

## Overview
The Auth Service handles **authentication** and **authorization** in the IoT application. It issues and validates **JWT tokens** and delegates any user profile management to the **User Management Service**.

---

## Responsibilities
1. **Token Issuance & Validation**  
   - Issue JWTs upon successful user login.
   - Validate incoming JWTs for other microservices.
2. **Authorization Rules**  
   - Maintain a mapping of roles (`admin`, `user`) to specific permissions.
   - Provide a secure way for services (e.g., Device Management Service) to verify a user’s or device’s authorization levels.
3. **Endpoints**  
   - `/login`: Accepts credentials, issues JWT.  
   - `/validate`: Validates JWT for other services (internal endpoint).  
   - `/refresh`: Issues a new JWT if the current one is about to expire.  
   - **Best-Practice Suggestion:** For password resets and changes, the Auth Service can coordinate with the User Management Service. Implementation details vary depending on your security policies.

---

## Proposed Architecture

### Textual Description
1. **JWT Issuance**: When the user logs in (via the Frontend), the Auth Service checks credentials (in collaboration with the User Management Service) and issues a signed JWT.  
2. **JWT Validation**: Other services send the JWT to the Auth Service for validation or use a shared secret/public key approach to validate tokens independently.  
3. **Scalable Design**: Runs as a Spring Boot microservice, packaged in Docker. Can be deployed locally via Docker Compose or in production with K3s.

```plantuml
@startuml

rectangle "Auth Service" as AUTH {
    interface "POST /login" as LOGIN
    interface "POST /validate" as VALIDATE
    interface "POST /refresh" as REFRESH
}

rectangle "User Management Service" as UMS {
    interface "GET /users/{id}" as GET_USER
}

rectangle "Device Management Service" as DMS
rectangle "Data Processing Service" as DPS
rectangle "Frontend" as FE

FE -> AUTH: [POST /login] Credentials
AUTH -> UMS: [GET /users/{id}] Validate credentials
UMS --> AUTH: Valid user or invalid user
AUTH --> FE: JWT issued or error

FE -> AUTH: [POST /refresh] Refresh token
AUTH --> FE: New JWT

DMS -> AUTH: [POST /validate] Validate JWT
AUTH --> DMS: Valid / invalid token
DPS -> AUTH: [POST /validate] Validate JWT
AUTH --> DPS: Valid / invalid token

@enduml
```

### Class diagram

```plantuml
@startuml
title Auth Service - Class Diagram

class AuthController {
+ login(credentials: LoginRequest): ResponseEntity<TokenResponse>
+ refreshToken(refreshToken: String): ResponseEntity<TokenResponse>
  }

class AuthService {
+ authenticate(credentials: LoginRequest): User
+ generateToken(user: User): String
+ validateToken(token: String): boolean
+ getUserFromToken(token: String): User
  }

class JwtTokenProvider {
- secretKey: String
+ createToken(user: User): String
+ validateToken(token: String): boolean
- parseClaims(token: String): Claims
  }

class SecurityConfig {
+ configure(http: HttpSecurity)
+ passwordEncoder(): PasswordEncoder
  }

' This may come from User Management directly or a local representation:
class User {
+ id: Long
+ username: String
+ email: String
+ passwordHash: String
+ role: Role
  }

AuthController --> AuthService : Uses
AuthService --> JwtTokenProvider : Uses
AuthService --> User : Returns or consumes
@enduml
```

**Diagram**
- **AuthController**: Exposes REST endpoints for login, token refresh.
- **AuthService**: Contains the core logic for authenticating a user (by contacting the User Management Service or checking cached info), generating/validating JWTs, and extracting user info from tokens.
- **JwtTokenProvider**: Handles the creation and validation of JWT tokens.
- **SecurityConfig**: Standard Spring Security configuration (e.g., HTTP security, password encoding).
- **User**: Typically fetched from the User Management Service. Shown here for clarity.

---

## Interfaces with Other Services

1. **User Management Service**
    - **Type**: Internal REST API
    - **Endpoints**: `GET /users/{id}` for credential checks (or `/users/validate`).
2. **Device Management Service**
    - **Type**: REST API calls for validating tokens.
3. **Data Processing Service**
    - **Type**: REST API calls for validating tokens.
4. **Frontend**
    - **Type**: REST (login, token refresh).

---

## Security & Maintenance
- **Best-Practice Suggestion**: Consider storing **client secrets** and **tokens** in a secure vault (e.g., HashiCorp Vault).
- **Best-Practice Suggestion**: Rotate JWT signing keys periodically for better security.
- **Auto-Scaling**: If user load spikes, replicate the Auth Service to handle more concurrent logins.

---