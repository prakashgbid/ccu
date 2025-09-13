#\!/bin/bash

echo "📦 Installing missing performance tools..."

# Detect package manager
if command -v brew &> /dev/null; then
    PM="brew"
elif command -v apt-get &> /dev/null; then
    PM="apt"
elif command -v yum &> /dev/null; then
    PM="yum"
fi

install_tool() {
    local tool=$1
    local package=$2
    
    if \! command -v $tool &> /dev/null; then
        echo "Installing $tool..."
        case $PM in
            brew) brew install $package ;;
            apt) sudo apt-get install -y $package ;;
            yum) sudo yum install -y $package ;;
        esac
    else
        echo "✅ $tool already installed"
    fi
}

# Install all tools in parallel
(install_tool parallel parallel) &
(install_tool mosh mosh) &
(install_tool ccache ccache) &
(install_tool pnpm pnpm || npm install -g pnpm) &
(install_tool rg ripgrep) &
(install_tool fd fd-find) &
(install_tool htop htop) &

wait
echo "✅ All tools installed\!"
