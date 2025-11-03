# Archived AI/ML Native Setup Scripts

> These files contain complex native AI/ML environment setup that was replaced with a container-first approach.
> Preserved here for reference or potential future restoration if native setup is needed.

## What's Archived

### Complex Installation Scripts
- `install-aiml.sh` - Full native CUDA + PyTorch setup (514 lines)
- `install-aiml-uv.sh` - UV-based AI/ML environment (145 lines) 
- Related CUDA configuration scripts

### GPU/CUDA Configuration
- WSL2 GPU testing scripts
- Native CUDA installation logic
- PyTorch CUDA verification

### Heavy Dependencies
- Native PyTorch installation
- CUDA toolkit setup
- GPU memory optimization

## Why Archived

**Container-First Strategy**: Shifted to using pre-built containers from experts (NVIDIA, Hugging Face) rather than maintaining complex native setups.

**Benefits of Container Approach**:
- Expert-maintained images with optimized CUDA setups
- Consistent environments across platforms
- Reduced maintenance overhead
- Faster bootstrap times
- Better resource isolation

## Replacement Strategy

**New approach uses**:
- Docker for AI/ML workloads
- Simple Python + uv for general development
- Container orchestration for training/inference
- Pre-built images: `nvidia/pytorch`, `huggingface/transformers`

## Restoration Instructions

If native AI/ML setup is needed again:

1. **Review hardware requirements** - Ensure CUDA compatibility
2. **Update for current versions** - CUDA, PyTorch may have evolved
3. **Test thoroughly** - Native setups are fragile and platform-specific
4. **Consider hybrid approach** - Native for development, containers for training

**Archival Date**: November 3, 2025
**Archival Reason**: Replaced with container-first development strategy
**Future Consideration**: May be restored if native GPU access is required