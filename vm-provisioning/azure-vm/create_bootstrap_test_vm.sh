#!/usr/bin/env bash
set -euo pipefail

# Azure VM Setup for Bootstrap Testing
# Creates a clean Ubuntu environment to validate single-command bootstrap

# Configuration
RESOURCE_GROUP="bootstrap-test-rg"
VM_NAME="bootstrap-test-vm"
LOCATION="eastus"
VM_SIZE="Standard_D2s_v3"  # CPU-only, sufficient for bootstrap testing
IMAGE="Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest"
ADMIN_USERNAME="testuser"
SSH_KEY_PATH="$HOME/.ssh/id_rsa.pub"

echo "🚀 Setting up Azure VM for bootstrap testing"
echo "Resource Group: $RESOURCE_GROUP"
echo "VM Name: $VM_NAME"
echo "Location: $LOCATION"
echo "VM Size: $VM_SIZE (CPU-only)"
echo

# Check if Azure CLI is installed
if ! command -v az >/dev/null 2>&1; then
    echo "❌ Azure CLI not found. Install with:"
    echo "   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
    exit 1
fi

# Check if logged in
if ! az account show >/dev/null 2>&1; then
    echo "🔐 Logging into Azure..."
    az login
fi

# Create resource group
echo "📦 Creating resource group..."
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --output table

# Create VM (CPU-only)
echo "🖥️  Creating CPU-only VM..."
az vm create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --image "$IMAGE" \
    --size "$VM_SIZE" \
    --admin-username "$ADMIN_USERNAME" \
    --ssh-key-values "$SSH_KEY_PATH" \
    --public-ip-sku Standard \
    --output table

# Get public IP
echo "🌐 Getting public IP address..."
PUBLIC_IP=$(az vm show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --show-details \
    --query publicIps \
    --output tsv)

echo "✅ VM created successfully!"
echo
echo "Connection details:"
echo "  SSH: ssh $ADMIN_USERNAME@$PUBLIC_IP"
echo "  Public IP: $PUBLIC_IP"
echo
echo "🧪 Bootstrap test commands:"
echo "1. SSH into the VM:"
echo "   ssh $ADMIN_USERNAME@$PUBLIC_IP"
echo
echo "2. Clone infrastructure:"
echo "   git clone https://github.com/crankbird/crank-infrastructure.git"
echo "   cd crank-infrastructure"
echo
echo "3. Test basic bootstrap:"
echo "   ./setup.sh"
echo
echo "4. Test with personal repo (replace with your dotfiles URL):"
echo "   ./setup.sh --personal-repo https://github.com/yourusername/dotfiles"
echo
echo "5. Validate installation:"
echo "   docker --version"
echo "   uv --version"
echo "   node --version"
echo "   gh --version"
echo
echo "💰 Clean up when done:"
echo "   az group delete --name $RESOURCE_GROUP --yes --no-wait"
echo
echo "📋 VM details for reference:"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   VM Name: $VM_NAME"
echo "   Public IP: $PUBLIC_IP"