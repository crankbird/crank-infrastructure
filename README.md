# Crank Infrastructure - IaaS Layer

> Infrastructure as a Service layer for the Crank ecosystem. Handles environment provisioning, container orchestration, and development environment setup.

## � **Meet Our Architectural Menagerie**

Our codebase includes references to architectural mascots who guide our design decisions:

| Mascot | Role | Files/Patterns | Mission |
|--------|------|----------------|---------|
| 🐰 **Wendy** | Zero-Trust Security Bunny | `*security*`, `*mTLS*`, `*auth*` | Ensures all communications are encrypted and services are properly isolated |
| 🦙 **Kevin** | Portability Llama | `*runtime*`, `*portable*`, `*kevin*` | Provides container runtime abstraction (Docker/Podman/Containerd) |
| 🐩 **Bella** | Modularity Poodle | `*separation*`, `*modular*`, `*plugin*` | Ensures clean service boundaries and separation readiness |
| 🦅 **Oliver** | Anti-Pattern Eagle | `*pattern*`, `*review*`, `*quality*` | Prevents architectural anti-patterns and maintains code quality |

*When you see mascot names in filenames or code, they indicate the architectural principle being applied!*

---

## �🏗️ Architecture Role

**IaaS Layer** in the three-tier Crank architecture:
- **IaaS** (this repo): Infrastructure provisioning and environment setup
- **PaaS** ([crank-platform](https://github.com/crankbird/crank-platform)): Service mesh, security, and governance
- **SaaS** (crankdoc, parse-email-archive, etc.): Business logic services

## 📁 Repository Structure

```
crank-infrastructure/
├── environments/           # Environment definitions
│   ├── development/       # Local development setup
│   ├── staging/          # Staging environment config
│   └── production/       # Production deployment config
├── containers/           # Base container images and orchestration
│   ├── base-images/     # Common base images (Python, Node.js, etc.)
│   ├── gpu-images/      # GPU-enabled development images
│   └── compose/         # Docker Compose configurations
├── cloud/               # Cloud provider infrastructure
│   ├── azure/          # Azure deployment scripts and configs
│   ├── aws/            # AWS deployment scripts (future)
│   └── gcp/            # Google Cloud deployment (future)
├── vm-provisioning/    # Virtual machine setup scripts
│   ├── azure-vm/       # Azure VM creation and configuration
│   ├── local-vm/       # Local VM setup (WSL2, VMware, etc.)
│   └── scripts/        # Common provisioning utilities
├── development-environments/ # Development environment setup
│   ├── ai-ml/          # AI/ML development environment
│   ├── web-dev/        # Web development environment
│   └── cross-platform/ # Cross-platform development setup
└── tools/              # Infrastructure management tools
    ├── monitoring/     # Infrastructure monitoring
    ├── backup/         # Backup and recovery scripts
    └── validation/     # Environment validation tools
```

## 🚀 Quick Start

### 1. Set Up Development Environment
```bash
# Clone this repository
git clone https://github.com/crankbird/crank-infrastructure
cd crank-infrastructure

# Run environment setup for your platform
./development-environments/ai-ml/setup.sh
```

### 2. Provision Cloud Infrastructure
```bash
# Azure setup (requires Azure CLI)
./cloud/azure/provision-dev-environment.sh

# Includes VM creation, networking, and base software
```

### 3. Validate Environment
```bash
# Check if environment is ready for Crank platform
./tools/validation/check-platform-requirements.sh
```

## 🎯 Integration with Crank Platform

This IaaS layer provides the foundation for the [crank-platform](https://github.com/crankbird/crank-platform) PaaS layer:

```bash
# After infrastructure setup, deploy platform
cd ../crank-platform
./scripts/validate-environment.sh  # Checks IaaS requirements
docker-compose up  # Deploys PaaS layer
```

## 📋 Environment Requirements

### Minimum Requirements
- Docker Desktop or Docker Engine
- Python 3.12+
- Git
- curl/wget

### Recommended for AI/ML
- NVIDIA GPU with CUDA support
- 16GB+ RAM
- 100GB+ storage

### Cloud Deployment
- Azure CLI (for Azure deployment)
- Terraform (for infrastructure as code)
- kubectl (for Kubernetes deployment)

## 🔧 Development Workflows

### Local Development
1. Run `./development-environments/ai-ml/setup.sh`
2. Validate with `./tools/validation/check-environment.sh`
3. Start developing with crank-platform services

### Cloud Deployment
1. Configure cloud credentials
2. Run `./cloud/azure/provision-dev-environment.sh`
3. Deploy crank-platform to provisioned infrastructure
4. Monitor with `./tools/monitoring/check-health.sh`

## 🔗 Related Repositories

- **[crank-platform](https://github.com/crankbird/crank-platform)** - PaaS layer (service mesh, security)
- **[crankdoc](https://github.com/crankbird/crankdoc)** - Document processing service
- **[parse-email-archive](https://github.com/crankbird/parse-email-archive)** - Email analysis service
- **[dotfiles](https://github.com/crankbird/dotfiles)** - Personal development configuration

## 📝 License

MIT License - See LICENSE file for details.