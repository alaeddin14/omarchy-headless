echo "Mark installation as headless for migration runner"

# Create headless marker if not exists
mkdir -p ~/.local/state/omarchy
if [[ ! -f ~/.local/state/omarchy/headless ]]; then
  touch ~/.local/state/omarchy/headless
  echo "Marked this installation as headless"
  echo "GUI-related migrations will be auto-skipped"
fi

# GUI-specific patterns to detect migrations that shouldn't run on headless
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

GUI_PACKAGES=("sddm" "plymouth" "hyprland" "waybar")
GUI_SERVICES=("omarchy-seamless-login" "plymouth-quit" "sddm" "hyprland")

# Auto-skip existing pending migrations that are GUI-related
skipped_count=0
for file in ~/.local/share/omarchy/migrations/*.sh; do
  if [[ -f "$file" ]]; then
    filename=$(basename "$file")
    if [[ ! -f ~/.local/state/omarchy/migrations/$filename && ! -f ~/.local/state/omarchy/migrations/skipped/$filename ]]; then
      should_skip=false
      
      # Check for GUI-only commands
      for cmd in "${GUI_ONLY_COMMANDS[@]}"; do
        if grep -qE "\b${cmd//-/\\-}\b" "$file" 2>/dev/null; then
          should_skip=true
          break
        fi
      done
      
      # Check for GUI packages
      if [[ $should_skip == false ]]; then
        for pkg in "${GUI_PACKAGES[@]}"; do
          if grep -qE "(omarchy-pkg-add|pacman\s+.*-S).*$pkg\b" "$file" 2>/dev/null; then
            should_skip=true
            break
          fi
        done
      fi
      
      # Check for GUI services
      if [[ $should_skip == false ]]; then
        for svc in "${GUI_SERVICES[@]}"; do
          if grep -qE "\b${svc//-/\\-}\.service\b" "$file" 2>/dev/null; then
            should_skip=true
            break
          fi
        done
      fi
      
      if [[ $should_skip == true ]]; then
        touch ~/.local/state/omarchy/migrations/skipped/$filename
        ((skipped_count++))
      fi
    fi
  fi
done

if (( skipped_count > 0 )); then
  echo "Auto-skipped $skipped_count GUI-related migrations"
fi
