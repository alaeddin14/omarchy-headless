echo "Mark installation as headless for migration runner"

# Create headless marker if not exists
mkdir -p ~/.local/state/omarchy
if [[ ! -f ~/.local/state/omarchy/headless ]]; then
  touch ~/.local/state/omarchy/headless
  echo "Marked this installation as headless"
  echo "Future interactive migrations will be auto-skipped"
fi
