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
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --environment TYPE    Environment type: ai-ml, web-dev, cross-platform (default: ai-ml)"
            echo "  --target TARGET       Deployment target: local, azure, aws (default: local)"
            echo "  --help               Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                                    # Local AI/ML development environment"
            echo "  $0 --environment web-dev              # Local web development environment"
            echo "  $0 --target azure                     # Azure cloud deployment"
            echo "  $0 --environment ai-ml --target azure # AI/ML environment on Azure"
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
    if [[ -f "development-environments/$ENVIRONMENT_TYPE/setup_hybrid_environment.sh" ]]; then
        bash "development-environments/$ENVIRONMENT_TYPE/setup_hybrid_environment.sh"
    else
        bash development-environments/install-containers.sh
        bash development-environments/install-aiml.sh
    fi
    
elif [[ $PLATFORM == "macos" ]]; then
    echo "🍎 macOS setup"
    bash development-environments/install-containers.sh
    
elif [[ $PLATFORM == "windows" ]]; then
    echo "🪟 Windows setup"
    echo "Please run setup from WSL2 or use Azure deployment"
    exit 1
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
echo "- Azure deployment: ./cloud/azure/deployment-guide.md"
echo "- Environment setup: ./development-environments/$ENVIRONMENT_TYPE/"