#!/bin/bash
# Quick test runner for Docker
# Usage: ./docker-test.sh [install|test|shell]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

show_help() {
  echo "Omarchy Headless - Docker Testing"
  echo ""
  echo "Usage: ./docker-test.sh [command]"
  echo ""
  echo "Commands:"
  echo "  build     - Build the Docker image"
  echo "  install   - Build and run full installation"
  echo "  test      - Run tests in container (after install)"
  echo "  shell     - Open interactive shell in container"
  echo "  clean     - Remove container and image"
  echo ""
  echo "Examples:"
  echo "  ./docker-test.sh build    # First time setup"
  echo "  ./docker-test.sh install  # Run full installation"
  echo "  ./docker-test.sh test     # Run tests"
  echo "  ./docker-test.sh shell    # Debug/interactive mode"
}

case "${1:-}" in
  build)
    echo "🔨 Building Docker image..."
    docker-compose -f docker-compose.test.yml build
    echo "✅ Image built!"
    ;;
    
  install)
    echo "🚀 Starting installation test..."
    docker-compose -f docker-compose.test.yml up -d
    echo "⏳ Running install.sh (this may take a while)..."
    docker exec -it omarchy-headless-test bash -c "
      export OMARCHY_PATH=/home/tester/.local/share/omarchy
      export PATH=\"\$OMARCHY_PATH/bin:\$PATH\"
      source install.sh
    " || {
      echo "❌ Installation failed. Check logs with:"
      echo "  docker logs omarchy-headless-test"
      exit 1
    }
    echo "✅ Installation complete!"
    echo ""
    echo "Next: Run tests with:"
    echo "  ./docker-test.sh test"
    ;;
    
  test)
    echo "🧪 Running tests..."
    docker exec -it omarchy-headless-test bash -c "
      export OMARCHY_PATH=/home/tester/.local/share/omarchy
      export PATH=\"\$OMARCHY_PATH/bin:\$PATH\"
      source ~/.bashrc 2>/dev/null || true
      ./tests/test-arch.sh
    "
    ;;
    
  shell)
    echo "🐚 Opening shell in container..."
    docker-compose -f docker-compose.test.yml up -d 2>/dev/null || true
    docker exec -it omarchy-headless-test bash
    ;;
    
  clean)
    echo "🧹 Cleaning up..."
    docker-compose -f docker-compose.test.yml down --rmi all -v 2>/dev/null || true
    docker rm -f omarchy-headless-test 2>/dev/null || true
    echo "✅ Cleanup complete"
    ;;
    
  *)
    show_help
    ;;
esac
