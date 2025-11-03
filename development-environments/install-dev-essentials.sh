#!/usr/bin/env bash
set -euo pipefail

# Simple Development Environment Setup
# Container-first approach for AI/ML, essential tools for development

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Setting up container-first development environment..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to handle errors gracefully
handle_error() {
    local exit_code=$?
    local line_number=$1
    log_error "Error on line $line_number. Exit code: $exit_code"
    log_warning "Continuing with next installation step..."
    return 0  # Don't exit, continue with other installations
}

# Set error trap for better error handling
trap 'handle_error $LINENO' ERR

# Install essential Python tools
install_python_tools() {
    log_info "Installing Python development tools..."
    
    # Install uv (fast Python package manager)
    if ! command -v uv >/dev/null 2>&1; then
        log_info "Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.local/bin:$PATH"
        source "$HOME/.local/bin/env" 2>/dev/null || true
        log_success "uv installed"
    else
        log_success "uv already installed: $(uv --version)"
    fi
    
    # Ensure pip is available for pipx installation
    if ! python3 -m pip --version >/dev/null 2>&1; then
        log_info "Installing pip..."
        sudo apt-get update
        sudo apt-get install -y python3-pip python3-venv
        log_success "pip installed"
    fi
    
    # Install pipx for global Python tools (fallback to uv if pip fails)
    if ! command -v pipx >/dev/null 2>&1; then
        log_info "Installing pipx..."
        if python3 -m pip install --user pipx 2>/dev/null; then
            python3 -m pipx ensurepath
            log_success "pipx installed via pip"
        else
            log_info "pip failed, installing pipx via uv..."
            if command -v uv >/dev/null 2>&1; then
                uv tool install pipx
                log_success "pipx installed via uv"
            else
                log_warning "Could not install pipx, continuing without it"
            fi
        fi
    else
        log_success "pipx already installed"
    fi
}

# Install Node.js for tooling
install_nodejs() {
    if ! command -v node >/dev/null 2>&1; then
        log_info "Installing Node.js LTS..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
        log_success "Node.js installed: $(node --version)"
    else
        log_success "Node.js already installed: $(node --version)"
    fi
}

# Install development tools
install_dev_tools() {
    log_info "Installing development tools..."
    
    # Essential packages
    sudo apt-get update
    sudo apt-get install -y \
        curl \
        wget \
        git \
        build-essential \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release \
        jq \
        tree \
        htop \
        unzip
    
    # GitHub CLI
    if ! command -v gh >/dev/null 2>&1; then
        log_info "Installing GitHub CLI..."
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install gh
        log_success "GitHub CLI installed"
    else
        log_success "GitHub CLI already installed"
    fi
    
    log_success "Development tools installed"
}

# Main setup
main() {
    log_info "Starting container-first development environment setup..."
    echo
    
    # Run installations with individual error handling
    set +e  # Disable exit on error for individual steps
    
    install_dev_tools || log_warning "Some development tools may not have installed correctly"
    install_python_tools || log_warning "Some Python tools may not have installed correctly"
    install_nodejs || log_warning "Node.js installation may have issues"
    
    # Call container setup
    if [[ -f "$SCRIPT_DIR/install-containers.sh" ]]; then
        bash "$SCRIPT_DIR/install-containers.sh" || log_warning "Container setup had issues"
    else
        log_warning "Container setup script not found - Docker setup may be incomplete"
    fi
    
    set -e  # Re-enable exit on error
    
    echo
    validate_installation
    log_success "Development environment setup complete!"
    echo
}

# Validate installation
validate_installation() {
    log_info "Validating installation..."
    
    local tools_status=()
    
    # Check essential tools
    if command -v uv >/dev/null 2>&1; then
        tools_status+=("✅ uv: $(uv --version)")
    else
        tools_status+=("❌ uv: not found")
    fi
    
    if command -v node >/dev/null 2>&1; then
        tools_status+=("✅ Node.js: $(node --version)")
    else
        tools_status+=("❌ Node.js: not found")
    fi
    
    if command -v gh >/dev/null 2>&1; then
        tools_status+=("✅ GitHub CLI: installed")
    else
        tools_status+=("❌ GitHub CLI: not found")
    fi
    
    if command -v docker >/dev/null 2>&1; then
        tools_status+=("✅ Docker: $(docker --version 2>/dev/null || echo 'installed but not accessible')")
    else
        tools_status+=("❌ Docker: not found")
    fi
    
    if command -v pipx >/dev/null 2>&1; then
        tools_status+=("✅ pipx: installed")
    else
        tools_status+=("⚠️  pipx: not found (optional)")
    fi
    
    echo
    log_info "Installation Summary:"
    for status in "${tools_status[@]}"; do
        echo "  $status"
    done
    echo
    echo "🐳 Container-First AI/ML:"
    echo "   docker run --gpus all -it pytorch/pytorch:latest"
    echo "   docker run -it huggingface/transformers-pytorch-gpu"
    echo
    echo "🐍 Python Development:"
    echo "   uv init my-project     # Create new project"
    echo "   uv add requests        # Add dependencies"  
    echo "   uv run python app.py   # Run with dependencies"
    echo
    echo "📚 Next Steps:"
    echo "   - Configure Git: git config --global user.name 'Your Name'"
    echo "   - Login to GitHub: gh auth login"
    echo "   - Install VS Code extensions via personal repo"
}

# Run main function
main "$@"