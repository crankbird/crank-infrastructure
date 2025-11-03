#!/bin/bash
# Archived Graphite installation function from install-aiml-uv.sh
# Removed on November 3, 2025 - preserved for potential future restoration

# Install Node.js and Graphite
install_nodejs_graphite() {
    # Install Node.js if not present
    if ! command -v node >/dev/null 2>&1; then
        echo "📦 Installing Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
    else
        echo "✅ Node.js is already installed: $(node --version)"
    fi

    # Install Graphite
    if command -v gt >/dev/null 2>&1; then
        echo "✅ Graphite is already installed"
        gt --version
    else
        echo "📦 Installing Graphite CLI..."
        npm install -g @withgraphite/graphite-cli
        echo "✅ Graphite installed successfully"
    fi
}

# Usage instructions that were in the original script:
# echo "   gt --help    # Graphite workflow commands"
# echo "   - Use 'gt' commands for stacked PRs"
# echo "   - See dev-environment/graphite-workflow.md"