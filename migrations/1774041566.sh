echo "Mark installation as headless for migration runner"

# Create headless marker if not exists
mkdir -p ~/.local/state/omarchy
if [[ ! -f ~/.local/state/omarchy/headless ]]; then
  touch ~/.local/state/omarchy/headless
  echo "Marked this installation as headless"
  echo "Migrations using GUI-only commands will be auto-skipped"
fi

# GUI/headless-specific commands that only exist on desktop Omarchy
GUI_ONLY_COMMANDS=(
  "omarchy-restart-swayosd"
  "omarchy-refresh-hypridle"
  "omarchy-refresh-hyprland"
  "omarchy-refresh-waybar"
  "omarchy-refresh-walker"
  "omarchy-refresh-mako"
  "omarchy-restart-waybar"
  "omarchy-restart-walker"
  "omarchy-restart-mako"
  "omarchy-restart-hyprland"
  "omarchy-restart-terminal"
  "omarchy-refresh-sddm"
  "omarchy-refresh-plymouth"
  "omarchy-refresh-applications"
  "omarchy-refresh-limine"
)

# Auto-skip existing pending migrations that use GUI-only commands
skipped_count=0
for file in ~/.local/share/omarchy/migrations/*.sh; do
  if [[ -f "$file" ]]; then
    filename=$(basename "$file")
    if [[ ! -f ~/.local/state/omarchy/migrations/$filename && ! -f ~/.local/state/omarchy/migrations/skipped/$filename ]]; then
      for cmd in "${GUI_ONLY_COMMANDS[@]}"; do
        if grep -qE "\b${cmd//-/\\-}\b" "$file" 2>/dev/null; then
          touch ~/.local/state/omarchy/migrations/skipped/$filename
          ((skipped_count++))
          break
        fi
      done
    fi
  fi
done

if (( skipped_count > 0 )); then
  echo "Auto-skipped $skipped_count migrations requiring GUI-only commands"
fi
