# Bootstrap Guide

This guide explains how to set up a complete development environment from a vanilla Linux installation using Crank Infrastructure.

## Quick Start

### Basic Setup (Infrastructure Only)
```bash
git clone https://github.com/crankbird/crank-infrastructure.git
cd crank-infrastructure
./setup.sh
```

### Bootstrap with Personal Configuration
```bash
git clone https://github.com/crankbird/crank-infrastructure.git
cd crank-infrastructure
./setup.sh --personal-repo https://github.com/yourusername/dotfiles
```

### Advanced Bootstrap Options
```bash
# Specific commit/tag/branch
./setup.sh --personal-repo https://github.com/yourusername/dotfiles --commit v1.2.3

# Different environment type
./setup.sh --environment web-dev --personal-repo https://github.com/yourusername/dotfiles

# Azure cloud deployment
./setup.sh --target azure --personal-repo https://github.com/yourusername/dotfiles
```

## What Gets Installed

### Infrastructure Layer (Always)
- **Container Platform**: Docker, Docker Compose, container development tools
- **Development Essentials**: uv (Python package manager), pipx, Node.js, npm, yarn
- **Version Control**: Git, GitHub CLI with authentication
- **Essential Tools**: curl, wget, unzip, build-essential
- **Platform Detection**: Automatic WSL2, GPU, and architecture detection

### Personal Configuration Layer (Optional)
When you specify `--personal-repo`, the setup will:

1. Clone your personal repository to `~/.personal-config`
2. Look for a setup script in your repo (`setup.sh`, `install.sh`, or `bootstrap.sh`)
3. Execute the setup script to apply your personal configurations
4. Support specific commits/tags with `--commit` parameter

## Personal Repository Structure

Your personal repository should follow this structure:

```
dotfiles/
├── setup.sh              # Main setup script (required)
├── .bashrc               # Shell configuration
├── .gitconfig            # Git configuration
├── .starship.toml        # Starship prompt configuration
├── .vscode/              # VS Code settings
│   ├── settings.json
│   └── extensions.json
└── config/               # Application configs
    ├── ssh/
    └── tools/
```

### Example Personal Setup Script

```bash
#!/bin/bash
# setup.sh in your personal repository

echo "🎨 Applying personal configurations..."

# Link dotfiles
ln -sf ~/.personal-config/.bashrc ~/.bashrc
ln -sf ~/.personal-config/.gitconfig ~/.gitconfig
ln -sf ~/.personal-config/.starship.toml ~/.starship.toml

# VS Code settings
mkdir -p ~/.config/Code/User
ln -sf ~/.personal-config/.vscode/settings.json ~/.config/Code/User/settings.json

# Install VS Code extensions
if command -v code &> /dev/null; then
    code --install-extension ms-python.python
    code --install-extension ms-vscode.vscode-json
fi

echo "✅ Personal configuration applied"
```

## Container-First AI/ML Strategy

This setup uses a **container-first approach** for AI/ML development:

### Why Container-First?
- **Simplified Setup**: Avoid complex CUDA/PyTorch native installation
- **Consistency**: Same environment across different machines
- **Isolation**: Clean separation between projects
- **Pre-built Images**: Leverage NVIDIA, Hugging Face, and other optimized containers

### Available Containers
- **NVIDIA GPU**: `nvcr.io/nvidia/pytorch:23.10-py3`
- **Hugging Face**: `huggingface/transformers-pytorch-gpu`
- **Jupyter**: `jupyter/tensorflow-notebook`
- **Custom**: Build your own based on these foundations

### Usage Example
```bash
# Start AI/ML development container
docker run -it --gpus all \
    -v $(pwd):/workspace \
    -p 8888:8888 \
    nvcr.io/nvidia/pytorch:23.10-py3 \
    bash

# Or use docker-compose for complex setups
docker-compose -f development-environments/docker-compose.ai-ml.yml up
```

## Validation

After setup, validate your environment:

```bash
# Check infrastructure requirements
bash tools/validation/check-platform-requirements.sh

# Verify container access
docker run hello-world

# Test GPU access (if available)
docker run --gpus all nvidia/cuda:11.8-base-ubuntu20.04 nvidia-smi
```

## WSL2 Specific Notes

For WSL2 environments:
- GPU passthrough is automatically tested
- Windows Docker Desktop integration is configured
- Host filesystem access is optimized
- Performance monitoring is enabled

## Troubleshooting

### Common Issues

**Permission Issues**
```bash
# Fix Docker permissions
sudo usermod -aG docker $USER
newgrp docker
```

**Personal Repository Not Found**
```bash
# Verify repository URL and access
git clone https://github.com/yourusername/dotfiles /tmp/test-clone
```

**Setup Script Not Found**
The personal repository integration looks for these scripts in order:
1. `setup.sh`
2. `install.sh` 
3. `bootstrap.sh`

Ensure at least one exists and is executable.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Vanilla Linux                             │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│              crank-infrastructure                            │
│  • Platform detection & base tools                          │
│  • Container platform (Docker)                              │
│  • Development essentials (uv, Node.js, GitHub CLI)         │
│  • Infrastructure validation                                │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│              Personal Repository                             │
│  • Dotfiles & shell configuration                           │
│  • Application settings                                     │
│  • Personal tools & aliases                                 │
│  • Project-specific configurations                          │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│              Productive Environment                          │
│  • Ready for development                                    │
│  • All tools configured                                     │
│  • Personal preferences applied                             │
│  • Container-based workflows enabled                        │
└─────────────────────────────────────────────────────────────┘
```

## Next Steps

After successful bootstrap:

1. **Validate Environment**: Run validation scripts to ensure everything works
2. **Clone Platform**: Get the main crank-platform repository
3. **Start Development**: Launch your first containerized development environment
4. **Customize Further**: Adjust personal repository based on your workflow

## Backup and Recovery

To backup your current configuration state:
```bash
# Create configuration backup (future enhancement)
bash tools/backup-restore/backup-config.sh
```

This bootstrap approach ensures you can rebuild your development environment quickly and consistently across different machines.