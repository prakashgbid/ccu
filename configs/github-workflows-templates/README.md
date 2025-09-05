# 🤖 GitHub Workflows Central Repository

This repository contains reusable GitHub Actions workflows that automatically maintain documentation, wikis, and deployment across all projects.

## 🎯 What These Workflows Do

### On Every Commit:
1. **📚 Documentation Generation**
   - Generates API docs from code comments
   - Creates architecture diagrams from code structure
   - Updates README sections automatically
   - Generates CHANGELOG from commits

2. **📖 Wiki Synchronization**
   - Syncs README to Wiki home page
   - Converts docs/ folder to Wiki pages
   - Updates navigation and TOC
   - Maintains version history

3. **🌐 GitHub Pages Deployment**
   - Builds documentation site
   - Deploys to GitHub Pages
   - Updates API reference
   - Generates interactive demos

4. **📦 Package Publishing** (on version tags)
   - Publishes to npm/PyPI
   - Updates package registries
   - Creates GitHub releases
   - Generates release notes

5. **✅ Quality Checks**
   - Validates documentation completeness
   - Checks for missing professional elements
   - Ensures LICENSE and CONTRIBUTING exist
   - Verifies API documentation

## 🚀 Quick Setup

To add these automations to any project:

```bash
# 1. Copy the workflow to your project
cp .github-workflows/templates/auto-docs.yml YOUR_PROJECT/.github/workflows/

# 2. Configure project-specific settings
# Edit .github/workflows/auto-docs.yml

# 3. Enable GitHub Pages in repo settings
# Settings > Pages > Source: GitHub Actions

# 4. Enable Wiki in repo settings
# Settings > Features > ✅ Wikis
```

## 📁 Workflow Templates

### Core Workflows:
- `auto-docs.yml` - Complete documentation automation
- `wiki-sync.yml` - Wiki synchronization only
- `pages-deploy.yml` - GitHub Pages deployment only
- `package-publish.yml` - npm/PyPI publishing
- `quality-check.yml` - Documentation quality validation

### Language-Specific:
- `node-docs.yml` - Node.js/TypeScript projects
- `python-docs.yml` - Python projects
- `monorepo-docs.yml` - Lerna/Nx monorepos

## 🔧 Configuration

Each workflow can be customized via:
1. Workflow inputs
2. Repository secrets
3. Configuration files (`.docsconfig.yml`)

## 📊 Supported Features

| Feature | Node.js | Python | Go | Rust |
|---------|---------|--------|-----|------|
| API Docs | ✅ TypeDoc | ✅ Sphinx | ✅ GoDoc | ✅ rustdoc |
| Wiki Sync | ✅ | ✅ | ✅ | ✅ |
| GitHub Pages | ✅ | ✅ | ✅ | ✅ |
| Package Publish | ✅ npm | ✅ PyPI | ✅ pkg.go.dev | ✅ crates.io |
| Diagrams | ✅ Mermaid | ✅ PlantUML | ✅ | ✅ |

## 🔐 Required Secrets

Set these in your repository settings:
- `GITHUB_TOKEN` - Auto-provided by GitHub Actions
- `NPM_TOKEN` - For npm publishing (optional)
- `PYPI_TOKEN` - For PyPI publishing (optional)

## 📈 Benefits

- **Zero Manual Work**: Everything updates automatically
- **Consistency**: All projects follow same documentation standards
- **Professional**: Maintains high-quality open-source presence
- **Version Control**: All documentation is versioned
- **SEO Optimized**: GitHub Pages sites are search-engine friendly

## 🎓 Examples

See these projects using our workflows:
- [CAIA](https://github.com/prakashgbid/caia) - Complete automation
- [Orchestra](https://github.com/prakashgbid/orchestra) - Pages + Wiki
- [ParaForge](https://github.com/prakashgbid/paraforge) - PyPI publishing

## 📝 License

MIT - Use these workflows in any project!