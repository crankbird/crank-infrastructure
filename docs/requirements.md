# Development Environment Requirements

> Single source of truth for what crank-infrastructure should provide
> Last updated: November 3, 2025

## Core Mission

Provide a **one-command bootstrap** from vanilla Linux to a fully functional development environment that supports the crankbird development methodology.

## Target Bootstrap Flow

```bash
# From completely fresh Linux (WSL2, VM, cloud instance):
# 1. Install git: apt update && apt install -y git
# 2. mkdir ~/projects && cd ~/projects  
# 3. git clone https://github.com/crankbird/crank-infrastructure.git
# 4. cd crank-infrastructure
# 5. ./setup.sh --personal-repo https://github.com/username/my-crankdev-dotfiles.git [--commit abc123]
# 6. ./validate.sh
# 7. logout/login
# 8. Ready for development
```

## Platform Support Requirements

### Primary Platforms
- **WSL2** (Ubuntu/Debian) - Primary development environment
- **Docker containers** - For Mac/Windows development via Docker Desktop
- **Cloud VMs** - Azure, AWS, GCP instances

### Secondary Platforms  
- **Linux VMs** - Hyper-V, VMware, etc.
- **macOS VMs** - VMware Fusion, Parallels (if feasible)

## Core Development Tools

### Essential Tools
- **Git** - Version control with GitHub CLI integration
- **Docker** - Container management (prefer over Podman for simplicity)
- **Python ecosystem** - uv package manager, multiple Python versions
- **Node.js ecosystem** - Latest LTS, npm/yarn
- **Cloud CLIs** - Azure CLI, AWS CLI (on-demand)
- **VS Code** - Extensions and workspace settings

### AI/ML Tools
- **Strategy**: Prefer pre-built containers over custom CUDA setup
- **Rationale**: Experts (NVIDIA, Hugging Face) maintain better images than we can
- **Implementation**: Docker container orchestration rather than native GPU setup
- **Fallback**: Native CUDA setup only if container approach proves insufficient

### Deprecated/Archived Tools
- **Graphite CLI** - Archive for potential future use, not installed by default
- **Stacked PR workflow** - Replaced with standard GitHub workflow

## Architecture Integration

### Mascot System Integration
- **Location**: Mascot configurations belong in crank-infrastructure
- **Scope**: Cross-project architectural patterns and VS Code settings
- **Implementation**: Global VS Code extensions and workspace templates

### Personal Configuration Integration  
- **Location**: User-specified personal repository (configurable)
- **Scope**: Personal preferences, shell themes, individual customizations
- **Integration**: Setup script prompts for personal repo URL and optional commit/version
- **Flexibility**: User can rename, version, or relocate personal repo as needed

### Context Recovery
- **Tools Location**: crank-infrastructure provides backup/restore utilities
- **State Storage**: User's personal repository stores encrypted backups and configurations
- **Workflow**: Infrastructure tools can backup to and restore from any specified personal repo
- **Philosophy**: Projects should be self-documenting and agent-ready (Gary-first approach)

## Validation Requirements

### Automated Validation
- All tools installed and accessible in PATH
- Docker daemon running and accessible
- Python virtual environments can be created
- Git configured with user identity
- VS Code extensions installed and active
- Personal repository successfully cloned and applied

### Manual Validation
- Can clone and run a sample project
- Can build and run Docker containers
- Can access cloud services (with proper credentials)
- Personal configurations (shell, themes) are active

## Success Criteria

1. **Zero-touch bootstrap**: Complete setup with single command
2. **Cross-platform consistency**: Same development experience across all supported platforms  
3. **Recovery resilience**: Can rebuild identical environment from backup
4. **Agent readiness**: Any AI agent can understand project state without conversation history
5. **Maintenance simplicity**: Clear separation of concerns between infrastructure and personal configs

## Non-Requirements

### Explicitly Out of Scope
- **SSH key management** - Too sensitive for automated setup
- **Personal credentials** - Must be configured manually
- **Project-specific tools** - Handled by individual project setup
- **IDE preferences beyond VS Code** - Focus on VS Code as primary editor

### Technology Choices
- **Graphite CLI** - Archived, not actively maintained
- **Complex CUDA setup** - Prefer containerized ML workflows
- **Multiple container runtimes** - Docker focus, avoid Podman complexity for now

## Future Considerations

### Potential Expansions
- Support for additional cloud providers
- Integration with devcontainer specifications
- Automated credential management (if secure solution found)
- Support for additional development languages/frameworks

### Technology Evolution
- Monitor container runtime ecosystem for alternatives to Docker
- Evaluate AI/ML tooling evolution (local vs. cloud training)
- Assess need for CUDA native setup as GPU access patterns evolve

---

*This document should be updated whenever requirements change to maintain alignment between desired state and implementation.*