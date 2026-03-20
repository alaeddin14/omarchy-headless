echo "Create ~/.local/bin/env for headless PATH setup"

# Create ~/.local/bin directory and env file for PATH setup
mkdir -p ~/.local/bin

# Create the env file that adds omarchy binaries to PATH
# This file is sourced by .bashrc to ensure omarchy commands are available
cat > ~/.local/bin/env << 'EOF'
#!/bin/sh
# Add binaries to PATH if they aren't added yet
# affix colons on either side of $PATH to simplify matching
case ":${PATH}:" in
    *:"$HOME/.local/share/omarchy/bin":*)
        ;;
    *)
        # Prepending path so omarchy binaries are found
        export PATH="$HOME/.local/share/omarchy/bin:$PATH"
        ;;
esac

# Also ensure ~/.local/bin is in PATH
case ":${PATH}:" in
    *:"$HOME/.local/bin":*)
        ;;
    *)
        export PATH="$HOME/.local/bin:$PATH"
        ;;
esac
EOF
chmod +x ~/.local/bin/env

# Ensure .bashrc sources the env file (make it conditional to avoid errors)
if [[ -f ~/.bashrc ]]; then
  # Remove any old broken references to the env file
  sed -i '/\.local\/share\/\.\.\/bin\/env/d' ~/.bashrc
  
  # Add conditional source if not already present
  if ! grep -q 'source.*\.local/bin/env' ~/.bashrc 2>/dev/null && ! grep -q '\.\s*"\$HOME/.local/bin/env"' ~/.bashrc 2>/dev/null; then
    echo "" >> ~/.bashrc
    echo "# Source local env file for PATH setup" >> ~/.bashrc
    echo '[[ -f ~/.local/bin/env ]] && . ~/.local/bin/env' >> ~/.bashrc
  fi
fi
