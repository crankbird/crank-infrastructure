#!/bin/bash
# Archived Graphite installation snippet from install-aiml.sh
# Removed on November 3, 2025 - preserved for potential future restoration

# Original code from lines 205-217 in install-aiml.sh:

    # Install Graphite CLI for pull-based workflows
    if ! command -v gt >/dev/null 2>&1; then
        log_info "Installing Graphite CLI (stacked diffs & pull-based workflow)..."
        if command -v npm >/dev/null 2>&1; then
            npm install -g @withgraphite/graphite-cli >/dev/null 2>&1
        else
            log_warning "npm not available, Graphite will need manual installation"
            log_warning "Run: npm install -g @withgraphite/graphite-cli"
        fi
        log_success "Graphite CLI installation attempted"
    else
        log_success "Graphite CLI already installed"
    fi

# This was part of the install_system_tools() function