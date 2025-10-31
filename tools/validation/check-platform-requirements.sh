#!/bin/bash
set -e

echo "🔍 Crank Platform Requirements Validation"
echo "========================================"
echo "Checking if environment meets crank-platform requirements..."
echo ""

# Track validation results
VALIDATION_PASSED=true
MISSING_REQUIREMENTS=()

# Function to check command availability
check_command() {
    local cmd=$1
    local name=$2
    local install_hint=$3
    
    if command -v "$cmd" &> /dev/null; then
        echo "✅ $name: Found ($cmd)"
        return 0
    else
        echo "❌ $name: Not found"
        MISSING_REQUIREMENTS+=("$name: $install_hint")
        VALIDATION_PASSED=false
        return 1
    fi
}

# Function to check version requirements
check_version() {
    local cmd=$1
    local name=$2
    local min_version=$3
    local current_version=$4
    
    if [[ -n "$current_version" ]]; then
        echo "✅ $name: $current_version (required: $min_version+)"
        return 0
    else
        echo "❌ $name: Version check failed"
        VALIDATION_PASSED=false
        return 1
    fi
}

echo "📋 Required Dependencies:"
echo "------------------------"

# Essential tools
check_command "docker" "Docker" "Run ./setup.sh --environment ai-ml from crank-infrastructure"
check_command "python3.12" "Python 3.12" "Run ./setup.sh --environment ai-ml from crank-infrastructure"
check_command "git" "Git" "sudo apt install git (Ubuntu) or brew install git (macOS)"
check_command "curl" "curl" "sudo apt install curl (Ubuntu) or brew install curl (macOS)"

# Python package manager
if check_command "uv" "uv (Python package manager)" "curl -LsSf https://astral.sh/uv/install.sh | sh"; then
    UV_VERSION=$(uv --version 2>/dev/null | cut -d' ' -f2 || echo "unknown")
    check_version "uv" "uv" "0.1.0" "$UV_VERSION"
fi

# Docker compose
if check_command "docker" "Docker"; then
    if docker compose version &> /dev/null; then
        COMPOSE_VERSION=$(docker compose version --short 2>/dev/null || echo "unknown")
        check_version "docker-compose" "Docker Compose" "2.0.0" "$COMPOSE_VERSION"
    else
        echo "❌ Docker Compose: Not available"
        MISSING_REQUIREMENTS+=("Docker Compose: Included in recent Docker Desktop versions")
        VALIDATION_PASSED=false
    fi
fi

echo ""
echo "🚀 Optional AI/ML Dependencies:"
echo "------------------------------"

# NVIDIA GPU support (optional)
if command -v nvidia-smi &> /dev/null; then
    GPU_INFO=$(nvidia-smi --query-gpu=name --format=csv,noheader,nounits 2>/dev/null | head -1 || echo "unknown")
    echo "✅ NVIDIA GPU: $GPU_INFO"
    
    # Check CUDA
    if command -v nvcc &> /dev/null; then
        CUDA_VERSION=$(nvcc --version 2>/dev/null | grep "release" | awk '{print $6}' | cut -d',' -f1 || echo "unknown")
        echo "✅ CUDA: $CUDA_VERSION"
    else
        echo "⚠️ CUDA: Not found (GPU acceleration disabled)"
    fi
else
    echo "⚠️ NVIDIA GPU: Not detected (CPU-only mode)"
fi

# Node.js (for some tooling)
if check_command "node" "Node.js" "Run ./setup.sh --environment web-dev from crank-infrastructure"; then
    NODE_VERSION=$(node --version 2>/dev/null || echo "unknown")
    check_version "node" "Node.js" "18.0.0" "$NODE_VERSION"
fi

echo ""
echo "🌐 Cloud Tools (for deployment):"
echo "--------------------------------"

# Azure CLI (optional)
if check_command "az" "Azure CLI" "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"; then
    AZ_VERSION=$(az --version 2>/dev/null | head -1 | awk '{print $2}' || echo "unknown")
    check_version "az" "Azure CLI" "2.0.0" "$AZ_VERSION"
fi

# Optional development tools can be added here as needed
echo "📋 Optional tools check complete"

echo ""
echo "📊 Environment Assessment:"
echo "========================="

if [[ $VALIDATION_PASSED == true ]]; then
    echo "🎉 Environment validation PASSED!"
    echo "✅ All required dependencies are available"
    echo "🚀 Ready to run crank-platform services"
else
    echo "⚠️ Environment validation FAILED"
    echo "❌ Missing required dependencies:"
    echo ""
    for req in "${MISSING_REQUIREMENTS[@]}"; do
        echo "   • $req"
    done
    echo ""
    echo "🔧 To fix missing dependencies:"
    echo "1. Clone crank-infrastructure: git clone https://github.com/crankbird/crank-infrastructure"
    echo "2. Run setup: cd crank-infrastructure && ./setup.sh"
    echo "3. Re-run this validation: ./scripts/validate-environment.sh"
fi

echo ""
echo "📚 Next Steps:"
if [[ $VALIDATION_PASSED == true ]]; then
    echo "• Start diagnostic service: docker-compose -f docker-compose.refactored-mesh.yml up"
    echo "• Test mesh interface: python test-refactored-mesh.py"
    echo "• Deploy full platform: docker-compose up"
else
    echo "• Install missing dependencies using crank-infrastructure"
    echo "• Re-run this validation script"
fi

echo ""
echo "🔗 Resources:"
echo "• Infrastructure setup: https://github.com/crankbird/crank-infrastructure"
echo "• Platform documentation: ./README.md"
echo "• Mesh interface guide: ./services/mesh_interface_v2.py"

# Exit with appropriate code
if [[ $VALIDATION_PASSED == true ]]; then
    exit 0
else
    exit 1
fi