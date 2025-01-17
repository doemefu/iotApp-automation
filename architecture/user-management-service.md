# User Management Service

## Overview
Manages **user profiles**, **roles**, and **permissions**. This service is the central point for user-related operations, while the Auth Service handles token issuance and validation.

---

## Responsibilities
1. **User CRUD Operations**
    - Create, read, update, delete user profiles.
2. **Roles & Permissions**
    - Maintain simple role-based access (two roles: `admin`, `user`).
3. **User Activity Tracking**
    - Log user actions (e.g., login time, changes to user settings) for auditing (optional).
4. **Password Reset & Change**
    - **Best-Practice Suggestion**: Expose endpoints for handling password resets and changes, triggered by the Auth Service or the Frontend.

---

## Proposed Architecture

### Textual Description
- Runs as a **Spring Boot** microservice on **PostgreSQL**.
- Stores user details: username, email, hashed passwords, roles, and optional activity logs.
- Provides secure REST endpoints for user account management.

```plantuml
@startuml

rectangle "User Management Service" as UMS {
    interface "POST /users" as CREATE_USER
    interface "GET /users" as LIST_USERS
    interface "GET /users/{id}" as GET_USER
    interface "PUT /users/{id}" as UPDATE_USER
    interface "DELETE /users/{id}" as DELETE_USER
    interface "POST /users/{id}/reset-password" as RESET_PASSWORD
}

rectangle "Auth Service" as AUTH
rectangle "Frontend" as FE

FE -> UMS: [POST /users] Create new user
FE -> UMS: [PUT /users/{id}] Update user
FE -> UMS: [POST /users/{id}/reset-password] Reset password
UMS -> AUTH: Optionally notify about changed user roles/permissions

@enduml
```

### Class diagram

```plantuml
@startuml
title User Management Service - Class Diagram

class UserController {
  + createUser(userDto: UserDto): ResponseEntity<UserDto>
  + getUser(id: Long): ResponseEntity<UserDto>
  + updateUser(id: Long, userDto: UserDto): ResponseEntity<UserDto>
  + deleteUser(id: Long): ResponseEntity<Void>
  + resetPassword(id: Long, newPassword: String): ResponseEntity<Void>
}

class UserService {
  + createUser(userDto: UserDto): User
  + findUserById(id: Long): User
  + updateUser(id: Long, userDto: UserDto): User
  + deleteUser(id: Long): void
  + resetPassword(id: Long, newPassword: String): void
}

class UserRepository {
  + save(user: User): User
  + findById(id: Long): Optional<User>
  + findAll(): List<User>
  + delete(user: User): void
}

class User {
  + id: Long
  + username: String
  + email: String
  + passwordHash: String
  + role: Role
}

enum Role {
  USER
  ADMIN
}

class UserActivity {
  + id: Long
  + userId: Long
  + activityType: String
  + timestamp: Date
}

UserController --> UserService : Calls
UserService --> UserRepository : Calls

User --> Role
UserService --> UserActivity : (Optional) to log activities
@enduml
```

**Explanation**

- **UserController**: REST endpoints for creating, reading, updating, deleting users, and handling password resets.
- **UserService**: Business logic for managing users, including interactions with the repository and optional activity logging.
- **UserRepository**: Spring Data interface for database operations (e.g., PostgreSQL).
- **User**: Entity representing a user record in the database.
- **Role**: Simple enum for user roles.
- **UserActivity** (Optional): Entity to log user-related events (logins, resets, etc.).

---

## Interfaces
1. **Auth Service**
    - **Type**: REST (internal)
    - **Purpose**: Validating user credentials, notifying about role changes if needed.
2. **Frontend**
    - **Type**: REST
    - **Purpose**: Creating/updating user profiles, resetting passwords, etc.

---

## Database
- **Primary DB**: PostgreSQL
    - Table: `users` (username, email, password_hash, role, etc.)
    - Table: `user_activity` (optional, for logging significant events).

---

## Security & Maintenance
- **Best-Practice Suggestion**: Use strong password policies and hashed (bcrypt, Argon2, etc.) storage.
- **Best-Practice Suggestion**: Implement rate limiting on user creation/reset endpoints to prevent abuse.

---