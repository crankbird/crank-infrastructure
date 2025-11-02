# Crank Platform Kubernetes Deployment

This directory contains Kubernetes-native deployment options for the Crank Platform, designed with the **principle of least surprise** for K8s users.

## 🎯 **Deployment Options**

### **1. Azure Container Apps** (Current)
- Best for: Cloud-native, serverless microservices
- Features: Auto-scaling, managed ingress, built-in service mesh
- Use when: You want managed infrastructure

### **2. Kubernetes Native** (New)
- Best for: Full K8s control, on-premises, multi-cloud
- Features: kubectl lifecycle, CSI integration, K8s networking
- Use when: You need K8s-native operations

## 📁 **Directory Structure**

```
kubernetes/
├── helm/                           # Helm chart for production deployment
│   ├── Chart.yaml
│   ├── values.yaml                 # Default configuration
│   ├── values-dev.yaml             # Development overrides  
│   ├── values-prod.yaml            # Production overrides
│   └── templates/
│       ├── namespace.yaml
│       ├── configmap.yaml
│       ├── secrets.yaml
│       ├── services/               # One file per microservice
│       │   ├── platform.yaml
│       │   ├── doc-converter.yaml
│       │   ├── email-classifier.yaml
│       │   ├── email-parser.yaml
│       │   └── streaming.yaml
│       ├── ingress.yaml            # K8s native ingress
│       ├── rbac.yaml               # Service accounts and RBAC
│       └── monitoring.yaml         # ServiceMonitor for Prometheus
├── manifests/                      # Raw K8s manifests
│   ├── 00-namespace.yaml
│   ├── 01-configmap.yaml
│   ├── 02-secrets.yaml
│   ├── 03-services.yaml
│   ├── 04-deployments.yaml
│   └── 05-ingress.yaml
├── kustomize/                      # Kustomize overlays
│   ├── base/
│   ├── overlays/
│   │   ├── development/
│   │   ├── staging/
│   │   └── production/
└── operators/                      # Custom operators (future)
    └── crank-operator/
```

## 🚀 **Quick Start**

### **Helm Deployment** (Recommended)
```bash
# Add Crank Platform repo
helm repo add crank-platform https://charts.crankbird.com
helm repo update

# Install with default configuration
helm install crank-platform crank-platform/crank-platform

# Or install with custom values
helm install crank-platform crank-platform/crank-platform -f values-prod.yaml
```

### **kubectl Deployment**
```bash
# Apply all manifests
kubectl apply -f manifests/

# Or apply with kustomize
kubectl apply -k kustomize/overlays/production/
```

## 🔧 **Smart Deployment Detection**

The deployment scripts automatically detect the target environment:

```bash
# Auto-detect and deploy
./deploy.sh

# Force specific target
./deploy.sh --target kubernetes
./deploy.sh --target azure-container-apps
```

## 🏷️ **K8s Native Features**

When deployed on Kubernetes, the platform automatically leverages:

### **Lifecycle Management**
- **kubectl** commands work as expected
- **Helm** lifecycle (install, upgrade, rollback)
- **Kustomize** configuration management

### **Storage Integration**
- **CSI drivers** for persistent volumes
- **ConfigMaps** for configuration
- **Secrets** for sensitive data

### **Networking**
- **Services** for internal communication  
- **Ingress** for external access
- **NetworkPolicies** for security

### **Observability**
- **ServiceMonitor** for Prometheus scraping
- **PodMonitor** for detailed metrics
- **Jaeger** tracing integration

### **Security**
- **ServiceAccounts** with minimal permissions
- **RBAC** for fine-grained access control
- **PodSecurityPolicies** for container security

### **Scaling & Reliability**
- **HorizontalPodAutoscaler** for auto-scaling
- **PodDisruptionBudgets** for reliability
- **Probes** for health checking

## 📊 **Configuration**

### **Environment Detection**
```yaml
# values.yaml
deployment:
  target: auto  # auto, kubernetes, azure-container-apps
  
kubernetes:
  enabled: true
  ingress:
    className: nginx
    annotations:
      kubernetes.io/ingress.class: nginx
      cert-manager.io/cluster-issuer: letsencrypt-prod
  
azureContainerApps:
  enabled: false
  resourceGroup: crank-platform
  environment: crank-platform-env
```

### **Service Configuration**
```yaml
# values.yaml
services:
  platform:
    replicaCount: 2
    image:
      repository: crankplatformregistry.azurecr.io/crank-platform
      tag: latest
    resources:
      requests:
        memory: "512Mi"
        cpu: "250m"
      limits:
        memory: "1Gi" 
        cpu: "500m"
    
  docConverter:
    replicaCount: 1
    image:
      repository: crankplatformregistry.azurecr.io/crank-doc-converter
      tag: latest
```

## 🎯 **Benefits of K8s Native Deployment**

### **For DevOps Teams**
- **Familiar tooling**: kubectl, helm, kustomize
- **GitOps ready**: ArgoCD, Flux integration
- **Monitoring**: Native Prometheus/Grafana
- **Security**: K8s RBAC and policies

### **For Developers** 
- **Local development**: minikube, kind, k3s
- **Debugging**: kubectl logs, exec, port-forward
- **Testing**: Job and CronJob resources
- **Configuration**: ConfigMaps and Secrets

### **For Platform Teams**
- **Multi-cluster**: Deploy across clusters
- **Backup/Restore**: Velero integration
- **Service Mesh**: Istio/Linkerd compatibility
- **Policy Enforcement**: OPA Gatekeeper

This gives you the **best of both worlds**: simplified Container Apps deployment for quick starts, and full K8s native deployment for enterprise use cases. 🚀