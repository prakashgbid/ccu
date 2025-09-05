#!/bin/bash

# Create docs folders with index.html for GitHub Pages

echo "📁 Creating docs folders for GitHub Pages..."

PROJECTS=(
    "/Users/MAC/Documents/projects/caia"
    "/Users/MAC/Documents/projects/standalone-apps/roulette-community"
    "/Users/MAC/Documents/projects/standalone-apps/adp"
    "/Users/MAC/Documents/projects/admin"
    "/Users/MAC/Documents/projects/old-projects/omnimind"
    "/Users/MAC/Documents/projects/old-projects/paraforge"
    "/Users/MAC/Documents/projects/old-projects/smart-agents-training-system"
)

for project in "${PROJECTS[@]}"; do
    if [ -d "$project" ]; then
        project_name=$(basename "$project")
        echo "📝 Creating docs for $project_name..."
        
        # Create docs directory
        mkdir -p "$project/docs"
        
        # Create index.html
        cat > "$project/docs/index.html" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$project_name Documentation</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@1/css/pico.min.css">
    <style>
        .hero { 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 4rem 2rem;
            text-align: center;
            margin-bottom: 2rem;
        }
        .hero h1 { color: white; }
        .container { max-width: 1200px; margin: 0 auto; padding: 2rem; }
        .features { 
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            margin: 2rem 0;
        }
        .feature {
            padding: 2rem;
            background: #f8f9fa;
            border-radius: 8px;
            text-align: center;
        }
        .nav-links {
            display: flex;
            gap: 1rem;
            justify-content: center;
            margin-top: 2rem;
        }
        .nav-links a {
            padding: 0.75rem 1.5rem;
            background: white;
            color: #333;
            text-decoration: none;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <div class="hero">
        <h1>📚 $project_name</h1>
        <p>Documentation and Resources</p>
        <div class="nav-links">
            <a href="https://github.com/prakashgbid/$project_name">🔗 GitHub</a>
            <a href="https://github.com/prakashgbid/$project_name/wiki">📖 Wiki</a>
            <a href="https://github.com/prakashgbid/$project_name/issues">💬 Issues</a>
        </div>
    </div>
    
    <div class="container">
        <div class="features">
            <div class="feature">
                <h3>📖 Documentation</h3>
                <p>Comprehensive guides and API references</p>
                <a href="https://github.com/prakashgbid/$project_name/wiki">Browse Wiki →</a>
            </div>
            
            <div class="feature">
                <h3>🚀 Quick Start</h3>
                <p>Get up and running in minutes</p>
                <a href="https://github.com/prakashgbid/$project_name#quick-start">Get Started →</a>
            </div>
            
            <div class="feature">
                <h3>💡 Examples</h3>
                <p>Learn from practical examples</p>
                <a href="https://github.com/prakashgbid/$project_name/tree/main/examples">View Examples →</a>
            </div>
            
            <div class="feature">
                <h3>🤝 Contributing</h3>
                <p>Help make this project better</p>
                <a href="https://github.com/prakashgbid/$project_name/blob/main/CONTRIBUTING.md">Contribute →</a>
            </div>
        </div>
        
        <h2>About $project_name</h2>
        <p>This documentation site is automatically generated and deployed via GitHub Actions.</p>
        <p>For the latest updates and detailed documentation, please visit our <a href="https://github.com/prakashgbid/$project_name/wiki">GitHub Wiki</a>.</p>
        
        <hr>
        
        <footer style="text-align: center; padding: 2rem 0;">
            <p>© $(date +%Y) $project_name | Built with ❤️ using GitHub Actions</p>
        </footer>
    </div>
</body>
</html>
EOF
        
        # Commit and push
        cd "$project"
        git add docs/
        git commit -m "📚 Add docs folder for GitHub Pages" 2>/dev/null
        git push 2>/dev/null && echo "  ✅ Pushed docs folder" || echo "  ⚠️  Already exists or no changes"
    fi
done

echo ""
echo "✅ Docs folders created! GitHub Pages should deploy automatically."