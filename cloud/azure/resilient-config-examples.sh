#!/bin/bash

# Example deployment configurations for different scenarios

echo "🔧 Crank Platform Resilient Discovery Configuration Examples"
echo

# Example 1: High Availability (fast failover)
echo "📋 Example 1: High Availability Configuration"
echo "   Use case: Production environment with good network reliability"
echo "   Recovery time: ~30-45 seconds"
echo
echo "   export WORKER_HEARTBEAT_INTERVAL=30"
echo "   export WORKER_TIMEOUT=90"  
echo "   export WORKER_CLEANUP_INTERVAL=15"
echo "   export WORKER_HEARTBEAT_GRACE=60"
echo "   ./deploy-microservices.sh"
echo

# Example 2: Balanced (default)
echo "📋 Example 2: Balanced Configuration (Default)"
echo "   Use case: Most production workloads"
echo "   Recovery time: ~60-90 seconds"
echo
echo "   # No exports needed - these are the defaults"
echo "   ./deploy-microservices.sh"
echo

# Example 3: IoT/Low Bandwidth
echo "📋 Example 3: IoT/Low Bandwidth Configuration"
echo "   Use case: Edge deployments, unreliable networks"
echo "   Recovery time: ~90-120 seconds"
echo
echo "   export WORKER_HEARTBEAT_INTERVAL=60"
echo "   export WORKER_TIMEOUT=180"
echo "   export WORKER_CLEANUP_INTERVAL=60" 
echo "   export WORKER_HEARTBEAT_GRACE=120"
echo "   ./deploy-microservices.sh"
echo

# Example 4: Development/Testing
echo "📋 Example 4: Development Configuration"
echo "   Use case: Local development with fast iteration"
echo "   Recovery time: ~15-30 seconds"
echo
echo "   export WORKER_HEARTBEAT_INTERVAL=15"
echo "   export WORKER_TIMEOUT=45"
echo "   export WORKER_CLEANUP_INTERVAL=10"
echo "   export WORKER_HEARTBEAT_GRACE=30"
echo "   ./deploy-microservices.sh"
echo

echo "💡 Tips:"
echo "   • Start with defaults and adjust based on your network conditions"
echo "   • Monitor platform logs for worker cleanup messages"
echo "   • Set timeout to 2.5-3x heartbeat interval"
echo "   • Lower values = faster recovery but more network traffic"