#!/bin/bash
set -e

echo "🧪 Testing Bootstrap on Azure VM"
echo "================================"

# Configuration
RESOURCE_GROUP="bootstrap-test-rg"
VM_NAME="bootstrap-test-vm"
LOCATION="eastus"
ADMIN_USERNAME="testuser"

# Check if VM exists and is running
echo "🔍 Checking VM status..."
VM_STATUS=$(az vm show --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --query "powerState" --output tsv 2>/dev/null || echo "NotFound")

if [[ "$VM_STATUS" == "NotFound" ]]; then
    echo "❌ VM not found. Please create it first with:"
    echo "   bash vm-provisioning/azure-vm/create_bootstrap_test_vm.sh"
    exit 1
elif [[ "$VM_STATUS" != "VM running" ]]; then
    echo "🔄 Starting VM..."
    az vm start --resource-group "$RESOURCE_GROUP" --name "$VM_NAME"
    echo "⏳ Waiting for VM to be ready..."
    sleep 30
fi

# Get VM IP
VM_IP=$(az vm show --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --show-details --query "publicIps" --output tsv)
echo "🌐 VM IP: $VM_IP"

# Wait a moment for VM to be fully ready
echo "⏳ Waiting for VM to be ready for SSH..."
sleep 10

# Create bootstrap test script
cat > /tmp/bootstrap-test.sh << 'EOF'
#!/bin/bash
set -e

echo "🏗️ Starting Bootstrap Test on Fresh Ubuntu VM"
echo "=============================================="

# Update system
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install git (required for cloning)
echo "📥 Installing git..."
sudo apt install -y git

# Clone infrastructure repository
echo "📦 Cloning crank-infrastructure..."
git clone https://github.com/crankbird/crank-infrastructure.git
cd crank-infrastructure

# Show current commit
echo "📌 Current commit:"
git log --oneline -1

# Test help output
echo "📖 Testing help output..."
./setup.sh --help

# Run basic bootstrap (no personal repo for now)
echo "🚀 Running bootstrap..."
./setup.sh

echo "✅ Bootstrap test completed!"
echo ""
echo "🔍 Validation checks:"
echo "- Docker installed: $(command -v docker >/dev/null && echo "✅" || echo "❌")"
echo "- uv installed: $(command -v uv >/dev/null && echo "✅" || echo "❌")"
echo "- Node.js installed: $(command -v node >/dev/null && echo "✅" || echo "❌")"
echo "- GitHub CLI installed: $(command -v gh >/dev/null && echo "✅" || echo "❌")"

echo ""
echo "🐳 Testing Docker:"
sudo docker run hello-world

echo ""
echo "🎉 All tests completed successfully!"
EOF

# Copy and execute the test script on the VM
echo "📤 Uploading test script to VM..."
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /tmp/bootstrap-test.sh $ADMIN_USERNAME@$VM_IP:/tmp/

echo "🚀 Executing bootstrap test on VM..."
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $ADMIN_USERNAME@$VM_IP 'chmod +x /tmp/bootstrap-test.sh && /tmp/bootstrap-test.sh'

echo ""
echo "✅ Bootstrap test completed on Azure VM!"
echo "🌐 VM IP: $VM_IP"
echo "🔗 SSH access: ssh $ADMIN_USERNAME@$VM_IP"