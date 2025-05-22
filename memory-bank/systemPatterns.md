# System Patterns

_This document describes the system architecture, key technical decisions, design patterns in use, component relationships, and critical implementation paths._

## Overall Architecture (Inferred from Helm Chart Structure)

Hyperswitch appears to follow a microservices-oriented architecture, deployed on Kubernetes. Key components and their likely roles:

*   **`hyperswitch-app` (Main Application):**
    *   **Router (`hyperswitch-router`):** Likely the entry point for API requests, handling routing to appropriate internal services.
    *   **Consumer (`hyperswitch-consumer`):** Processes asynchronous tasks, possibly from Kafka queues.
    *   **Producer (`hyperswitch-producer`):** Publishes events or messages, likely to Kafka.
    *   **Control Center:** A web application providing a management UI.
    *   **App Server:** The core backend logic for payment processing and business rules.

*   **`hyperswitch-card-vault`:** A dedicated service for securely storing and managing payment card information. This suggests a pattern of isolating sensitive data into a specialized, hardened service.

*   **Supporting Infrastructure Services (Dependencies):**
    *   **Databases (PostgreSQL, ClickHouse):** PostgreSQL for transactional data, ClickHouse for analytical workloads.
    *   **Messaging/Event Streaming (Kafka, Redis):** Kafka for robust event-driven communication, Redis potentially for caching or simpler messaging.
    *   **Logging & Monitoring (Loki, Grafana, OpenTelemetry, Vector):** A comprehensive stack for observing system behavior.

## Key Technical Decisions

*   **Containerization and Orchestration:** Use of Docker and Kubernetes for deployment, scaling, and management.
*   **Helm for Packaging:** Standardizing deployment with Helm charts.
*   **Event-Driven Architecture:** Indicated by the use of Kafka for communication between components like producer and consumer.
*   **Separation of Concerns:**
    *   Dedicated Card Vault for PCI compliance and security.
    *   Separate services for API routing, core logic, asynchronous processing, and UI.
*   **Comprehensive Observability:** Integration of logging (Loki), metrics (Prometheus via OpenTelemetry), and tracing (OpenTelemetry) tools.

## Design Patterns (Potential)

*   **API Gateway:** The `hyperswitch-router` likely acts as an API gateway.
*   **Message Queue:** Kafka is used for asynchronous communication and decoupling services.
*   **Service Discovery:** Kubernetes handles service discovery.
*   **Configuration Management:** Helm `values.yaml` provides a centralized way to configure all components.
*   **Database per Service (Partially):** While there's a primary PostgreSQL, the Card Vault might have its own dedicated storage or a very specific schema within the main DB, emphasizing data isolation for security. ClickHouse serves a distinct analytical purpose.

## Component Relationships (High-Level)

*   External traffic likely hits the `hyperswitch-router`.
*   Router communicates with the App Server for synchronous operations.
*   App Server may publish events to Kafka via the Producer.
*   Consumer processes events from Kafka.
*   Control Center interacts with the App Server's API to provide management functions.
*   App Server and potentially other components interact with the Card Vault for operations involving stored card data.
*   All services likely send logs to Vector/Loki and metrics/traces to OpenTelemetry Collector.
*   PostgreSQL stores primary application data.
*   ClickHouse stores analytical data.
*   Redis is used for caching or other stateful operations.

## Critical Implementation Paths

*   **Payment Processing Flow:** The sequence of interactions between router, app server, payment gateways, and card vault.
*   **Card Data Security:** Implementation within the Card Vault and interactions with it.
*   **Asynchronous Event Handling:** Flow of messages through Kafka and processing by consumers.
*   **Configuration and Deployment:** The Helm chart installation and customization process.
*   **Key Management for Card Vault:** The manual steps for generating and deploying keys are critical for security.
