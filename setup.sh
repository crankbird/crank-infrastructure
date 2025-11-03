#!/bin/bash
set -e

echo "🏗️ Crank Infrastructure Setup"
echo "============================="
echo "Infrastructure as a Service (IaaS) layer setup for Crank ecosystem"
echo ""

# Check if running on supported platform
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    PLATFORM="windows"
else
    echo "❌ Unsupported platform: $OSTYPE"
    exit 1
fi

echo "🖥️ Detected platform: $PLATFORM"

# Parse command line arguments
ENVIRONMENT_TYPE="ai-ml"  # default
DEPLOYMENT_TARGET="local"  # default
PERSONAL_REPO=""
PERSONAL_COMMIT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --environment)
            ENVIRONMENT_TYPE="$2"
            shift 2
            ;;
        --target)
            DEPLOYMENT_TARGET="$2"
            shift 2
            ;;
        --personal-repo)
            PERSONAL_REPO="$2"
            shift 2
            ;;
        --commit)
            PERSONAL_COMMIT="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --environment TYPE     Environment type: ai-ml, web-dev, cross-platform (default: ai-ml)"
            echo "  --target TARGET        Deployment target: local, azure, aws (default: local)"
            echo "  --personal-repo URL    Personal repository URL (e.g., https://github.com/user/dotfiles)"
            echo "  --commit HASH          Specific commit/tag/branch for personal repo (optional)"
            echo "  --help                Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                                           # Basic setup"
            echo "  $0 --personal-repo https://github.com/user/dotfiles"
            echo "  $0 --personal-repo https://github.com/user/dotfiles --commit v1.2.3"
            echo "  $0 --environment web-dev --target azure     # Web dev environment on Azure"
            exit 0
            ;;
        *)
            echo "❌ Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "🎯 Environment type: $ENVIRONMENT_TYPE"
echo "🌐 Deployment target: $DEPLOYMENT_TARGET"
if [[ -n "$PERSONAL_REPO" ]]; then
    echo "👤 Personal repository: $PERSONAL_REPO"
    if [[ -n "$PERSONAL_COMMIT" ]]; then
        echo "📌 Personal repo commit: $PERSONAL_COMMIT"
    fi
fi
echo ""

# Validate environment type
if [[ ! -d "development-environments/$ENVIRONMENT_TYPE" ]]; then
    echo "❌ Unknown environment type: $ENVIRONMENT_TYPE"
    echo "Available types: ai-ml, web-dev, cross-platform"
    exit 1
fi

# Step 1: Install base dependencies
echo "📦 Step 1: Installing base dependencies..."
if [[ $PLATFORM == "linux" ]]; then
    # Check if we're in a VM or container
    if [[ -f /proc/version ]] && grep -qi microsoft /proc/version; then
        echo "🐧 Detected WSL2 environment"
        ./vm-provisioning/local-vm/wsl2-experiments/test_wsl2_gpu.sh
    fi
    
    # Run the comprehensive environment setup
    echo "🛠️ Installing development essentials (container-first approach)..."
    bash development-environments/install-dev-essentials.sh
    
    # Install Docker/containers if not already available
    if ! command -v docker &> /dev/null; then
        echo "🐳 Installing Docker and container tools..."
        bash development-environments/install-containers.sh
    fi
    
elif [[ $PLATFORM == "macos" ]]; then
    echo "🍎 macOS setup"
    bash development-environments/install-containers.sh
    
elif [[ $PLATFORM == "windows" ]]; then
    echo "🪟 Windows setup"
    echo "Please run setup from WSL2 or use Azure deployment"
    exit 1
fi

# Step 1.5: Personal repository integration
if [[ -n "$PERSONAL_REPO" ]]; then
    echo ""
    echo "👤 Step 1.5: Setting up personal configuration repository..."
    
    PERSONAL_DIR="$HOME/.personal-config"
    
    if [[ -d "$PERSONAL_DIR" ]]; then
        echo "🔄 Updating existing personal configuration..."
        cd "$PERSONAL_DIR"
        git fetch origin
        if [[ -n "$PERSONAL_COMMIT" ]]; then
            echo "📌 Checking out specific commit: $PERSONAL_COMMIT"
            git checkout "$PERSONAL_COMMIT"
        else
            git pull origin main || git pull origin master
        fi
    else
        echo "📥 Cloning personal configuration repository..."
        git clone "$PERSONAL_REPO" "$PERSONAL_DIR"
        cd "$PERSONAL_DIR"
        if [[ -n "$PERSONAL_COMMIT" ]]; then
            echo "📌 Checking out specific commit: $PERSONAL_COMMIT"
            git checkout "$PERSONAL_COMMIT"
        fi
    fi
    
    # Apply personal configurations
    if [[ -f "setup.sh" ]]; then
        echo "🔧 Applying personal configurations..."
        bash setup.sh
    elif [[ -f "install.sh" ]]; then
        echo "🔧 Applying personal configurations..."
        bash install.sh
    elif [[ -f "bootstrap.sh" ]]; then
        echo "🔧 Applying personal configurations..."
        bash bootstrap.sh
    else
        echo "⚠️ No setup script found in personal repository"
        echo "📁 Personal configs cloned to: $PERSONAL_DIR"
        echo "💡 You may need to manually apply configurations"
    fi
    
    # Return to infrastructure directory
    cd - > /dev/null
    echo "✅ Personal configuration setup complete"
fi

# Step 2: Set up deployment target
echo ""
echo "🚀 Step 2: Setting up deployment target..."
if [[ $DEPLOYMENT_TARGET == "local" ]]; then
    echo "💻 Local development setup complete"
    
elif [[ $DEPLOYMENT_TARGET == "azure" ]]; then
    echo "☁️ Setting up Azure infrastructure..."
    if ! command -v az &> /dev/null; then
        echo "❌ Azure CLI not found. Installing..."
        curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    fi
    
    echo "📋 Azure setup guide: ./cloud/azure/deployment-guide.md"
    echo "🏗️ VM provisioning: ./vm-provisioning/azure-vm/create_azure_test_vm.sh"
    
elif [[ $DEPLOYMENT_TARGET == "aws" ]]; then
    echo "☁️ AWS setup not yet implemented"
    exit 1
    
else
    echo "❌ Unknown deployment target: $DEPLOYMENT_TARGET"
    exit 1
fi

# Step 3: Validate environment
echo ""
echo "✅ Step 3: Validating environment..."
if [[ -f "tools/validation/check-platform-requirements.sh" ]]; then
    bash tools/validation/check-platform-requirements.sh
else
    bash development-environments/check-env.sh
fi

echo ""
echo "🎉 Crank Infrastructure setup complete!"
echo ""
echo "🔗 Next steps:"
echo "1. Clone crank-platform: git clone https://github.com/crankbird/crank-platform"
echo "2. Validate platform requirements: cd crank-platform && ./scripts/validate-environment.sh"
echo "3. Start platform services: docker-compose up"
echo ""
echo "📚 Documentation:"
echo "- Infrastructure guide: ./README.md"
echo "- Bootstrap guide: ./docs/requirements.md"
echo "- Azure deployment: ./cloud/azure/deployment-guide.md"
if [[ -n "$PERSONAL_REPO" ]]; then
    echo "- Personal configs: $HOME/.personal-config"
fi