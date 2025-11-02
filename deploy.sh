#!/bin/bash

# 🚀 Smart Crank Platform Deployment Script
# 
# This script detects the target environment and deploys accordingly:
# - Kubernetes: Uses Helm charts with proper K8s resources
# - Azure Container Apps: Uses Azure CLI with Container Apps
# - Auto-detect: Chooses based on available tools and context

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
echo_success() { echo -e "${GREEN}✅ $1${NC}"; }
echo_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
echo_error() { echo -e "${RED}❌ $1${NC}"; }
echo_purple() { echo -e "${PURPLE}🚀 $1${NC}"; }

# Configuration
TARGET=""
NAMESPACE="crank-platform"
HELM_RELEASE="crank-platform"
AZURE_RG="crank-platform"

show_help() {
    echo_purple "🚀 Smart Crank Platform Deployment"
    echo ""
    echo "This script intelligently deploys the Crank Platform to the most appropriate target."
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --target <target>    Force specific deployment target"
    echo "                       Values: auto, kubernetes, azure-container-apps"
    echo "  --namespace <name>   Kubernetes namespace (default: crank-platform)"
    echo "  --release <name>     Helm release name (default: crank-platform)"
    echo "  --resource-group <rg> Azure resource group (default: crank-platform)"
    echo "  --dry-run           Show what would be deployed without executing"
    echo "  --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                           # Auto-detect and deploy"
    echo "  $0 --target kubernetes       # Force Kubernetes deployment"
    echo "  $0 --target azure-container-apps  # Force Azure Container Apps"
    echo "  $0 --dry-run                 # Show deployment plan"
    echo ""
    echo "Environment Detection:"
    echo "  🎯 Kubernetes: Checks for kubectl, current context, and cluster access"
    echo "  ☁️  Azure: Checks for az CLI, authentication, and Container Apps support"
    echo "  🔍 Auto: Chooses best option based on available tools and context"
}

detect_environment() {
    echo_info "🔍 Detecting deployment environment..."
    
    local kubernetes_available=false
    local azure_available=false
    
    # Check Kubernetes availability
    if command -v kubectl &> /dev/null; then
        if kubectl cluster-info &> /dev/null; then
            local context=$(kubectl config current-context 2>/dev/null || echo "none")
            echo_info "✅ Kubernetes detected - Context: $context"
            kubernetes_available=true
        else
            echo_warning "kubectl found but no cluster access"
        fi
    else
        echo_info "❌ kubectl not available"
    fi
    
    # Check Azure availability
    if command -v az &> /dev/null; then
        if az account show &> /dev/null; then
            local subscription=$(az account show --query name --output tsv 2>/dev/null || echo "unknown")
            echo_info "✅ Azure CLI detected - Subscription: $subscription"
            azure_available=true
        else
            echo_warning "Azure CLI found but not authenticated"
        fi
    else
        echo_info "❌ Azure CLI not available"
    fi
    
    # Determine best target
    if [ "$kubernetes_available" = true ] && [ "$azure_available" = true ]; then
        echo_info "🎯 Both environments available"
        
        # Check if we're in a K8s context that suggests preference
        local context=$(kubectl config current-context 2>/dev/null || echo "")
        if [[ "$context" == *"prod"* ]] || [[ "$context" == *"staging"* ]]; then
            echo_info "📋 Kubernetes context suggests K8s deployment: $context"
            echo "kubernetes"
        else
            echo_info "☁️  Defaulting to Azure Container Apps for cloud deployment"
            echo "azure-container-apps"
        fi
    elif [ "$kubernetes_available" = true ]; then
        echo_info "🎯 Kubernetes selected (only option available)"
        echo "kubernetes"
    elif [ "$azure_available" = true ]; then
        echo_info "☁️  Azure Container Apps selected (only option available)"
        echo "azure-container-apps"
    else
        echo_error "❌ No deployment environment available!"
        echo_error "Please install and configure either:"
        echo_error "  - kubectl + Kubernetes cluster access"
        echo_error "  - Azure CLI + authentication (az login)"
        exit 1
    fi
}

deploy_kubernetes() {
    echo_purple "🎯 Deploying to Kubernetes with Helm"
    
    # Check if Helm is installed
    if ! command -v helm &> /dev/null; then
        echo_error "Helm not found. Please install Helm: https://helm.sh/docs/intro/install/"
        exit 1
    fi
    
    # Create namespace if it doesn't exist
    echo_info "Creating namespace: $NAMESPACE"
    kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
    
    # Check if chart directory exists
    if [ ! -d "cloud/kubernetes/helm" ]; then
        echo_error "Helm chart not found at cloud/kubernetes/helm"
        echo_info "Please run this script from the crank-infrastructure root directory"
        exit 1
    fi
    
    # Deploy with Helm
    echo_info "Installing/upgrading Helm release: $HELM_RELEASE"
    helm upgrade --install "$HELM_RELEASE" cloud/kubernetes/helm \
        --namespace "$NAMESPACE" \
        --create-namespace \
        --wait \
        --timeout 300s \
        --set global.imageRegistry=crankplatformregistry.azurecr.io \
        --set config.crankEnvironment=kubernetes \
        --set platform.ingress.hosts[0].host=crank-platform.local
    
    if [ $? -eq 0 ]; then
        echo_success "✅ Kubernetes deployment successful!"
        echo ""
        echo_info "📋 Deployment Summary:"
        kubectl get pods,svc,ingress -n "$NAMESPACE"
        echo ""
        echo_info "🔧 Useful Commands:"
        echo "  kubectl get pods -n $NAMESPACE"
        echo "  kubectl logs -f deployment/crank-platform-platform -n $NAMESPACE"
        echo "  kubectl port-forward svc/crank-platform-platform 8000:8000 -n $NAMESPACE"
        echo ""
        echo_info "🌐 Access the platform:"
        echo "  Local: kubectl port-forward svc/crank-platform-platform 8000:8000 -n $NAMESPACE"
        echo "  Ingress: http://crank-platform.local (configure /etc/hosts or DNS)"
    else
        echo_error "❌ Kubernetes deployment failed"
        exit 1
    fi
}

deploy_azure_container_apps() {
    echo_purple "☁️  Deploying to Azure Container Apps"
    
    # Check if Azure Container Apps extension is installed
    echo_info "Checking Azure Container Apps extension..."
    if ! az extension list --query "[?name=='containerapp'].name" -o tsv | grep -q containerapp; then
        echo_info "Installing Azure Container Apps extension..."
        az extension add --name containerapp
    fi
    
    # Use the existing microservices deployment script
    if [ -f "cloud/azure/deploy-microservices.sh" ]; then
        echo_info "Using existing Azure deployment script..."
        bash cloud/azure/deploy-microservices.sh
    else
        echo_error "Azure deployment script not found at cloud/azure/deploy-microservices.sh"
        exit 1
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --target)
            TARGET="$2"
            shift 2
            ;;
        --namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        --release)
            HELM_RELEASE="$2"
            shift 2
            ;;
        --resource-group)
            AZURE_RG="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Main deployment logic
echo_purple "🚀 Smart Crank Platform Deployment"
echo ""

# Determine target
if [ -z "$TARGET" ] || [ "$TARGET" = "auto" ]; then
    TARGET=$(detect_environment)
else
    echo_info "🎯 Target forced to: $TARGET"
fi

echo ""
echo_info "📋 Deployment Configuration:"
echo "  Target: $TARGET"
echo "  Namespace: $NAMESPACE"
echo "  Helm Release: $HELM_RELEASE"
echo "  Azure RG: $AZURE_RG"
echo ""

if [ "$DRY_RUN" = true ]; then
    echo_warning "🏁 Dry run mode - showing plan only"
    case $TARGET in
        kubernetes)
            echo_info "Would deploy to Kubernetes using Helm chart"
            echo_info "Namespace: $NAMESPACE"
            echo_info "Release: $HELM_RELEASE"
            ;;
        azure-container-apps)
            echo_info "Would deploy to Azure Container Apps"
            echo_info "Resource Group: $AZURE_RG"
            ;;
    esac
    exit 0
fi

# Execute deployment
case $TARGET in
    kubernetes)
        deploy_kubernetes
        ;;
    azure-container-apps)
        deploy_azure_container_apps
        ;;
    *)
        echo_error "Unknown target: $TARGET"
        exit 1
        ;;
esac

echo ""
echo_success "🎉 Deployment Complete!"
echo_info "The Crank Platform is now running on $TARGET"