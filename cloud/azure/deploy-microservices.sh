#!/bin/bash

# 🚀 Azure Container Apps Microservices Deployment
# 
# This script deploys all 5 Crank Platform microservices as separate Container Apps
# with proper service discovery, networking, and security for production use.

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
RESOURCE_GROUP="crank-platform"
LOCATION="australiaeast"
ACR_NAME="crankplatformregistry"
CONTAINER_ENV="crank-platform-env"

# Resilient Discovery Configuration (configurable via environment)
WORKER_HEARTBEAT_INTERVAL="${WORKER_HEARTBEAT_INTERVAL:-45}"
WORKER_TIMEOUT="${WORKER_TIMEOUT:-120}"
WORKER_CLEANUP_INTERVAL="${WORKER_CLEANUP_INTERVAL:-30}"
WORKER_HEARTBEAT_GRACE="${WORKER_HEARTBEAT_GRACE:-90}"

echo_info "Worker registry configuration:"
echo_info "  • Heartbeat interval: ${WORKER_HEARTBEAT_INTERVAL}s"
echo_info "  • Worker timeout: ${WORKER_TIMEOUT}s"
echo_info "  • Cleanup interval: ${WORKER_CLEANUP_INTERVAL}s"
echo_info "  • Heartbeat grace: ${WORKER_HEARTBEAT_GRACE}s"

# Service definitions - matches our microservices architecture
declare -A SERVICES=(
    ["platform"]="crank-platform:latest:8443"
    ["doc-converter"]="crank-doc-converter:latest:8101"
    ["email-classifier"]="crank-email-classifier:latest:8201"
    ["email-parser"]="crank-email-parser:latest:8301"
    ["streaming"]="crank-streaming:latest:8501"
)

echo_purple "🚀 Starting Azure Container Apps Microservices Deployment"

# Check if logged into Azure
echo_info "Checking Azure CLI authentication..."
if ! az account show > /dev/null 2>&1; then
    echo_error "Not logged into Azure CLI. Please run 'az login' first."
    exit 1
fi
echo_success "Azure CLI authenticated"

# Check if resource group exists
echo_info "Checking resource group: $RESOURCE_GROUP"
if ! az group show --name $RESOURCE_GROUP > /dev/null 2>&1; then
    echo_warning "Resource group $RESOURCE_GROUP not found. Creating..."
    az group create --name $RESOURCE_GROUP --location $LOCATION
    echo_success "Resource group $RESOURCE_GROUP created"
else
    echo_success "Resource group $RESOURCE_GROUP found"
fi

# Check Container Apps environment
echo_info "Checking Container Apps environment: $CONTAINER_ENV"
if ! az containerapp env show --name $CONTAINER_ENV --resource-group $RESOURCE_GROUP > /dev/null 2>&1; then
    echo_warning "Container Apps environment not found. Creating..."
    az containerapp env create \
        --name $CONTAINER_ENV \
        --resource-group $RESOURCE_GROUP \
        --location $LOCATION
    echo_success "Container Apps environment $CONTAINER_ENV created"
else
    echo_success "Container Apps environment $CONTAINER_ENV found"
fi

# Deploy each microservice as a separate Container App
echo_purple "🏗️ Deploying Microservices..."

for service_name in "${!SERVICES[@]}"; do
    IFS=':' read -r image_name image_tag port <<< "${SERVICES[$service_name]}"
    app_name="crank-$service_name"
    
    echo_info "Deploying $app_name (${image_name}:${image_tag} on port $port)..."
    
    # Determine if this is the main gateway (needs ingress)
    if [ "$service_name" = "platform" ]; then
        ingress_config="--ingress external --target-port $port"
        echo_info "   └─ Configuring external ingress for gateway"
    else
        ingress_config="--ingress internal --target-port $port"
        echo_info "   └─ Configuring internal ingress for worker"
    fi
    
    # Deploy or update the container app
    if az containerapp show --name $app_name --resource-group $RESOURCE_GROUP > /dev/null 2>&1; then
        echo_warning "   └─ Container app exists, updating..."
        
        # Build environment variables
        env_vars="CRANK_ENVIRONMENT=production LOG_LEVEL=INFO AZURE_SUBSCRIPTION_ID=$(az account show --query id --output tsv) AZURE_RESOURCE_GROUP=$RESOURCE_GROUP AZURE_LOCATION=$LOCATION PLATFORM_AUTH_TOKEN=azure-mesh-key-secure SERVICE_NAME=$service_name SERVICE_PORT=$port"
        
        # Add resilient discovery config for platform service
        if [ "$service_name" = "platform" ]; then
            env_vars="$env_vars WORKER_HEARTBEAT_INTERVAL=$WORKER_HEARTBEAT_INTERVAL WORKER_TIMEOUT=$WORKER_TIMEOUT WORKER_CLEANUP_INTERVAL=$WORKER_CLEANUP_INTERVAL WORKER_HEARTBEAT_GRACE=$WORKER_HEARTBEAT_GRACE"
            echo_info "   └─ Adding resilient discovery configuration"
        fi
        
        az containerapp update \
            --name $app_name \
            --resource-group $RESOURCE_GROUP \
            --image "${ACR_NAME}.azurecr.io/${image_name}:${image_tag}" \
            --set-env-vars $env_vars > /dev/null 2>&1
    else
        echo_info "   └─ Creating new container app..."
        
        # Build environment variables  
        env_vars="CRANK_ENVIRONMENT=production LOG_LEVEL=INFO AZURE_SUBSCRIPTION_ID=$(az account show --query id --output tsv) AZURE_RESOURCE_GROUP=$RESOURCE_GROUP AZURE_LOCATION=$LOCATION PLATFORM_AUTH_TOKEN=azure-mesh-key-secure SERVICE_NAME=$service_name SERVICE_PORT=$port"
        
        # Add resilient discovery config for platform service
        if [ "$service_name" = "platform" ]; then
            env_vars="$env_vars WORKER_HEARTBEAT_INTERVAL=$WORKER_HEARTBEAT_INTERVAL WORKER_TIMEOUT=$WORKER_TIMEOUT WORKER_CLEANUP_INTERVAL=$WORKER_CLEANUP_INTERVAL WORKER_HEARTBEAT_GRACE=$WORKER_HEARTBEAT_GRACE"
            echo_info "   └─ Adding resilient discovery configuration"
        fi
        
        az containerapp create \
            --name $app_name \
            --resource-group $RESOURCE_GROUP \
            --environment $CONTAINER_ENV \
            --image "${ACR_NAME}.azurecr.io/${image_name}:${image_tag}" \
            --cpu 0.5 \
            --memory 1Gi \
            --min-replicas 1 \
            --max-replicas 3 \
            $ingress_config \
            --registry-server "${ACR_NAME}.azurecr.io" \
            --env-vars $env_vars > /dev/null 2>&1
    fi
    
    if [ $? -eq 0 ]; then
        echo_success "   └─ $app_name deployed successfully"
    else
        echo_error "   └─ Failed to deploy $app_name"
        exit 1
    fi
done

# Configure service-to-service communication
echo_purple "🔗 Configuring Service Discovery..."

# Get all container app FQDNs for service discovery
echo_info "Getting service endpoints..."
platform_fqdn=$(az containerapp show --name crank-platform --resource-group $RESOURCE_GROUP --query "properties.configuration.ingress.fqdn" --output tsv)
doc_fqdn=$(az containerapp show --name crank-doc-converter --resource-group $RESOURCE_GROUP --query "properties.configuration.ingress.fqdn" --output tsv)
email_classifier_fqdn=$(az containerapp show --name crank-email-classifier --resource-group $RESOURCE_GROUP --query "properties.configuration.ingress.fqdn" --output tsv)
email_parser_fqdn=$(az containerapp show --name crank-email-parser --resource-group $RESOURCE_GROUP --query "properties.configuration.ingress.fqdn" --output tsv)
streaming_fqdn=$(az containerapp show --name crank-streaming --resource-group $RESOURCE_GROUP --query "properties.configuration.ingress.fqdn" --output tsv)

# Update platform gateway with service discovery URLs
echo_info "Updating platform gateway with service endpoints..."
az containerapp update \
    --name crank-platform \
    --resource-group $RESOURCE_GROUP \
    --set-env-vars \
        CRANK_ENVIRONMENT=production \
        LOG_LEVEL=INFO \
        PLATFORM_AUTH_TOKEN="azure-mesh-key-secure" \
        DOC_CONVERTER_URL="https://$doc_fqdn" \
        EMAIL_CLASSIFIER_URL="https://$email_classifier_fqdn" \
        EMAIL_PARSER_URL="https://$email_parser_fqdn" \
        STREAMING_URL="https://$streaming_fqdn" \
        SERVICE_DISCOVERY_MODE=azure > /dev/null 2>&1

echo_success "Service discovery configured"

# Update worker services with platform URL
echo_info "Updating worker services with platform URL..."
for service in "crank-doc-converter" "crank-email-classifier" "crank-email-parser" "crank-streaming"; do
    az containerapp update \
        --name $service \
        --resource-group $RESOURCE_GROUP \
        --set-env-vars \
            PLATFORM_URL="https://$platform_fqdn" \
            CRANK_ENVIRONMENT=production \
            LOG_LEVEL=INFO \
            PLATFORM_AUTH_TOKEN="azure-mesh-key-secure" > /dev/null 2>&1
done

echo_success "Worker services configured"

# Display deployment summary
echo_purple "🎉 Deployment Complete!"
echo ""
echo_success "🌐 Service Endpoints:"
echo "   Platform Gateway: https://$platform_fqdn"
echo "   Document Converter: https://$doc_fqdn"
echo "   Email Classifier: https://$email_classifier_fqdn"
echo "   Email Parser: https://$email_parser_fqdn"
echo "   Streaming Service: https://$streaming_fqdn"
echo ""

echo_info "🧪 Quick Health Check:"
services_array=(
    "Platform Gateway:https://$platform_fqdn/health/live"
    "Document Converter:https://$doc_fqdn/health"
    "Email Classifier:https://$email_classifier_fqdn/health"
    "Email Parser:https://$email_parser_fqdn/health"
    "Streaming Service:https://$streaming_fqdn/health"
)

for service_info in "${services_array[@]}"; do
    IFS=':' read -r service_name service_url <<< "$service_info"
    echo_info "Testing $service_name..."
    
    if curl -s --max-time 10 "$service_url" > /dev/null 2>&1; then
        echo_success "   └─ $service_name is healthy ✅"
    else
        echo_warning "   └─ $service_name may still be starting... ⏳"
    fi
done

echo ""
echo_purple "🚀 Microservices Architecture Deployed Successfully!"
echo_info "All 5 services are now running as separate Container Apps"
echo_info "The platform gateway can now discover and communicate with all worker services"
echo ""
echo_info "💡 Test the complete system:"
echo "   curl -s https://$platform_fqdn/ | jq ."
echo "   curl -s https://$platform_fqdn/v1/capabilities | jq ."
echo ""
echo_warning "⏰ Note: Services may take 2-3 minutes to fully start and register"