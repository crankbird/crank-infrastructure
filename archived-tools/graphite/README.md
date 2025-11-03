# Archived Graphite Configuration

> These files contain Graphite CLI setup and configuration that was removed from the main infrastructure setup.
> Preserved here for potential future restoration if stacked PR workflows are needed again.

## What's Archived

### Install Scripts
- `install-nodejs-graphite-function.sh` - The install function from install-aiml-uv.sh
- `install-aiml-graphite-snippets.sh` - Graphite references from install-aiml.sh  

### Documentation Snippets
- `graphite-workflow-references.md` - Documentation references that mentioned Graphite workflows

## Restoration Instructions

If Graphite workflows are needed again in the future:

1. **Review archived files** - Check what was removed and why
2. **Update for current versions** - Graphite may have evolved since archival
3. **Test integration** - Verify compatibility with current Node.js and development setup
4. **Update documentation** - Ensure workflow docs reflect current best practices

## Original Context

Graphite CLI was originally included to support stacked PR workflows, but was removed as part of a shift to standard GitHub workflows and simplified development processes.

**Removal Date**: November 3, 2025
**Removal Reason**: Deprecated in favor of standard GitHub workflows
**Future Consideration**: May be restored if team adopts stacked PR methodology