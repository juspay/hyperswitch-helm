# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is the official Helm chart repository for Hyperswitch, an open-source payments switch. The repository contains multiple Helm charts organized under `charts/incubator/`:

- **hyperswitch-stack**: Main umbrella chart that deploys the complete Hyperswitch stack
- **hyperswitch-app**: Backend application chart (payment router, consumer, producer services)
- **hyperswitch-web**: Frontend SDK and control center chart
- **hyperswitch-card-vault**: Secure card storage service chart
- **hyperswitch-keymanager**: Encryption key management service chart
- **hyperswitch-istio**: Service mesh configuration chart

## Architecture

The Hyperswitch stack consists of:

1. **Payment Router**: Core payment processing service
2. **Consumer/Producer**: Message queue processing services
3. **Control Center**: Web-based management dashboard
4. **Web SDK**: Frontend integration library
5. **Card Vault**: PCI-compliant card storage
6. **Key Manager**: Encryption key management

Dependencies include PostgreSQL, Redis, Kafka, ClickHouse, and optional monitoring (Prometheus, Grafana, Loki).

## Common Commands

### Root Level (Task runner commands)
```bash
# List all available tasks
task

# Package the hyperswitch-stack chart
task package-incubator-hyperswitch-helm
# Alias: task pihh

# Update README documentation
task update-readme
# Alias: task ur

# Update repository index
task repo-update-index
```

### Chart Development (within chart directories)
```bash
# Template and render chart
task template
# Alias: task t

# Install/upgrade chart
task install
# Alias: task i

# Dry run installation
task dry-run
# Alias: task dr

# Generate documentation
task generate-doc
# Alias: task d
```

### Hyperswitch-app specific
```bash
# Install external PostgreSQL
task install-pg-ext
# Alias: task ipe

# Install external Redis
task helm-redis-install
# Alias: task hri

# Install external PostgreSQL via Helm
task helm-postgres-install
# Alias: task hpi

# Add required Helm repositories
task helm-add-repo
# Alias: task har
```

## Installation Workflow

1. Add the Helm repository:
   ```bash
   helm repo add hyperswitch https://juspay.github.io/hyperswitch-helm
   helm repo update
   ```

2. Create namespace:
   ```bash
   kubectl create namespace hyperswitch
   ```

3. Install the stack:
   ```bash
   helm install hypers-v1 hyperswitch/hyperswitch-stack -n hyperswitch
   ```

## Development Dependencies

- **helm-docs**: Required for documentation generation
- **Task**: Task runner for development workflows
- **Helm 3.x**: Chart packaging and deployment

## Chart Structure

Each chart follows standard Helm conventions:
- `Chart.yaml`: Chart metadata and dependencies
- `values.yaml`: Default configuration values
- `templates/`: Kubernetes manifest templates
- `README.md`: Auto-generated documentation

The hyperswitch-stack uses local file dependencies to reference other charts in the repository.

## Configuration

Key configuration areas:
- Database connections (PostgreSQL, Redis)
- Message queue settings (Kafka)
- Service endpoints and ingress
- Resource limits and scaling
- Security and RBAC settings

Version management follows semantic versioning, with chart versions independent of application versions.