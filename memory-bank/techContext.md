# Tech Context

_This document lists the technologies used, development setup, technical constraints, dependencies, and tool usage patterns._

## Core Technologies

*   **Kubernetes:** The primary deployment platform.
*   **Helm:** Used for packaging and deploying applications on Kubernetes.
*   **Docker:** Containerization technology for the application components.

## Key Dependencies (from Helm Chart)

*   **Redis:** (Bitnami chart `18.6.1`) - Likely used for caching, session management, or as a message broker.
*   **PostgreSQL:** (Bitnami chart `15.5.38`) - Primary database for persistent storage.
*   **Hyperswitch Card Vault:** (Local chart `0.1.0`) - Custom component for secure card data storage.
*   **Kafka:** (Bitnami chart `31.0.0`) - Used for event streaming and asynchronous processing.
*   **ClickHouse:** (Bitnami chart `6.3.3`) - Columnar database, likely used for analytics and logging.
*   **MailHog:** (Codecentric chart `4.0.0`) - Email testing tool.
*   **Loki-stack:** (Grafana chart `2.10.2`) - Log aggregation and visualization (Loki for logging, Grafana for dashboards).
*   **Vector:** (Vector chart `0.37.0`) - Data pipeline tool, possibly for log/metric collection and forwarding.
*   **OpenTelemetry Collector:** (OpenTelemetry chart `0.120.0`) - For collecting and exporting telemetry data (metrics, traces).

## Development Setup (Inferred)

*   Requires `git` for cloning the repository.
*   Requires `kubectl` for interacting with the Kubernetes cluster.
*   Requires `helm` for installing the charts.
*   The `hyperswitch-card-vault` component seems to have a Rust (Cargo) build process for utility functions (key generation).

## Technical Constraints

*   Minimum Kubernetes node resources: 4 CPUs, 6GB RAM (as mentioned in README).
*   Requires a Kubernetes namespace (e.g., `hyperswitch`).
*   Card vault requires manual key generation and configuration steps.

## Tool Usage Patterns

*   **Helm:** Central to deployment and configuration management. `values.yaml` files are key for customization.
*   **kubectl:** Used for initial setup (namespace creation, node labeling) and verification.
*   **Git:** For version control and obtaining the Helm chart source.
*   **OpenSSL:** Used for generating private/public key pairs for the card vault.
*   **Cargo:** (Rust's package manager/build tool) Used for utilities related to the card vault.
*   **cURL:** Used for interacting with the card vault API for key management.
