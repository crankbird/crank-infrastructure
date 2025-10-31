# 🚀 Cross-Platform Crank Platform Development

This directory contains cross-platform development tools and configurations for the Crank Platform, designed to work seamlessly across macOS, Linux, and WSL2.

## 📁 **Directory Contents**

```
cross-platform/
├── dev-crank-platform.sh        # Cross-platform development manager
├── docker-compose.local.yml      # Local development configuration
├── docker-compose.azure.yml      # Azure deployment configuration
├── .env.local.template           # Local environment template
├── .env.azure.template           # Azure environment template
└── README.md                     # This file
```

## 🛠️ **Quick Start**

### **1. Initial Setup**
```bash
# Copy environment template
cp .env.local.template .env.local

# Edit configuration for your setup
nano .env.local

# Run initial setup
./dev-crank-platform.sh setup
```

### **2. Start Development Environment**
```bash
# Start all services
./dev-crank-platform.sh start

# Or start minimal services (no ML/CV)
./dev-crank-platform.sh start-min
```

### **3. Monitor and Test**
```bash
# Check service status
./dev-crank-platform.sh status

# Test all endpoints
./dev-crank-platform.sh test

# Monitor in real-time
./dev-crank-platform.sh monitor
```

## 📱 **Platform Support**

| Platform | Status | Notes |
|----------|--------|-------|
| **macOS** | ✅ | Docker Desktop, Homebrew support |
| **Linux** | ✅ | Ubuntu, Debian, RHEL, Arch, Alpine |
| **WSL2** | ✅ | Windows Subsystem for Linux |

## 🔧 **Available Commands**

```bash
./dev-crank-platform.sh <command>

Commands:
  setup       Initial setup for local development
  start       Start all services
  start-min   Start minimal services (no ML/CV)
  stop        Stop all services  
  restart     Restart all services
  logs        Show logs for all services
  status      Show status of all services
  update      Pull latest images and restart
  test        Test all service endpoints
  clean       Clean up containers and volumes
  monitor     Monitor services in real-time
  help        Show this help message
```

## 🌐 **Service Architecture**

### **Core Services**
- **Platform API** (8443): Main application API with HTTPS
- **Document Converter** (8101): PDF/document processing
- **Email Classifier** (8201): ML-based email classification
- **Email Parser** (8301): Email parsing and extraction
- **Streaming Service** (8501): Real-time data streaming

### **Worker Services**
- **Document Worker**: Processes document conversion jobs
- **Email Worker**: Handles email processing tasks
- **Image Worker**: Computer vision and image processing
- **Streaming Worker**: Real-time data processing

## 🔐 **Security Features**

### **Built-in Security**
- **HTTPS by default** with self-signed certificates
- **Input sanitization** preventing injection attacks
- **Path traversal protection** for file operations
- **Resource limits** preventing DoS attacks
- **Health check authentication** with bearer tokens

### **Development Security**
```bash
# Default development token (change in production!)
PLATFORM_AUTH_TOKEN=local-dev-key-secure

# HTTPS endpoints
https://localhost:8443/health/live
https://localhost:8443/v1/workers
```

## 🐳 **Container Configuration**

### **Image Sources**
All images are pulled from Azure Container Registry:
```
crankplatformregistry.azurecr.io/crank-platform:latest
crankplatformregistry.azurecr.io/crank-doc-converter:latest
crankplatformregistry.azurecr.io/crank-email-classifier:latest
crankplatformregistry.azurecr.io/crank-email-parser:latest
crankplatformregistry.azurecr.io/crank-streaming:latest
```

### **Multi-Platform Support**
- **ARM64**: Apple Silicon Macs, ARM-based Linux
- **AMD64**: Intel/AMD processors, Azure VMs

### **Resource Limits**
```yaml
# Development-friendly limits
memory: 512MB per service
cpu: 0.5 cores per service  
# Adjust in .env.local for your hardware
```

## 🔍 **Troubleshooting**

### **Common Issues**

#### **Docker Not Running**
```bash
# macOS: Start Docker Desktop
open -a Docker

# Linux: Start Docker service
sudo systemctl start docker
sudo usermod -aG docker $USER  # Add to docker group
```

#### **Port Conflicts**
```bash
# Check what's using ports
netstat -tulpn | grep :8443
lsof -i :8443

# Kill conflicting processes
sudo kill -9 <PID>
```

#### **Azure Container Registry Login**
```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login to Azure
az login
az acr login --name crankplatformregistry
```

#### **Memory Issues on macOS**
```bash
# Increase Docker Desktop memory:
# Docker Desktop → Settings → Resources → Memory
# Recommended: 8GB+ for full stack
```

### **Health Check Failures**
```bash
# Check specific service logs
docker-compose -f docker-compose.local.yml logs platform

# Restart specific service
docker-compose -f docker-compose.local.yml restart platform

# Full reset
./dev-crank-platform.sh clean
./dev-crank-platform.sh start
```

## 🚀 **Production Deployment**

This development environment is designed to mirror production as closely as possible:

- **Same container images** used in Azure
- **Same configuration patterns** via environment variables
- **Same security model** with HTTPS and authentication
- **Same service architecture** with worker processes

For production deployment, see: `../../cloud/azure/deploy-azure.sh`

## 📊 **Performance Monitoring**

### **Built-in Monitoring**
```bash
# Real-time monitoring
./dev-crank-platform.sh monitor

# Docker stats
docker stats

# Service health
./dev-crank-platform.sh status
```

### **Custom Monitoring**
```bash
# Add Prometheus endpoint monitoring
curl -k https://localhost:8443/metrics

# Log aggregation
docker-compose -f docker-compose.local.yml logs -f | grep ERROR
```

## 🔄 **Update Workflow**

### **Updating Images**
```bash
# Pull latest images and restart
./dev-crank-platform.sh update

# Or manually
docker-compose -f docker-compose.local.yml pull
./dev-crank-platform.sh restart
```

### **Configuration Changes**
```bash
# After editing .env.local
./dev-crank-platform.sh restart

# Or for immediate effect
./dev-crank-platform.sh stop
./dev-crank-platform.sh start
```

## 🤝 **Contributing**

When making changes to this development environment:

1. **Test across platforms** (macOS, Linux, WSL2)
2. **Update documentation** in this README
3. **Validate security** with test endpoints
4. **Check resource usage** on lower-end hardware
5. **Verify Azure compatibility** with production deployment

## 📞 **Support**

- **Platform Issues**: Check service logs and health endpoints
- **Container Issues**: Verify Docker installation and permissions
- **Network Issues**: Check port conflicts and firewall settings
- **Performance Issues**: Monitor resource usage and adjust limits

---

*This cross-platform development environment ensures consistent experience across all developer machines while maintaining production parity.* 🎯