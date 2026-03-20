echo "Mark installation as headless and skip GUI migrations"

# Create headless marker if not exists
mkdir -p ~/.local/state/omarchy
if [[ ! -f ~/.local/state/omarchy/headless ]]; then
  touch ~/.local/state/omarchy/headless
  echo "Marked this installation as headless"
fi

# Auto-skip GUI-related migrations that haven't run yet
GUI_MIGRATIONS=(
  "1751887718.sh"
  "1752725616.sh"
  "1752793122.sh"
  "1752896442.sh"
  "1752981883.sh"
  "1753495989.sh"
  "1754228071.sh"
  "1754331529.sh"
  "1754389057.sh"
  "1756371020.sh"
  "1757279511.sh"
  "1757511571.sh"
  "1757879836.sh"
  "1758107879.sh"
  "1758487660_change_dm_to_sddm.sh"
  "1758487662_move_to_custom_uki.sh"
  "1760462260.sh"
  "1760693222.sh"
  "1760787158.sh"
  "1761269603.sh"
  "1762121828.sh"
  "1762156000.sh"
)

skipped_count=0
for migration in "${GUI_MIGRATIONS[@]}"; do
  if [[ -f ~/.local/share/omarchy/migrations/$migration ]]; then
    if [[ ! -f ~/.local/state/omarchy/migrations/$migration && ! -f ~/.local/state/omarchy/migrations/skipped/$migration ]]; then
      touch ~/.local/state/omarchy/migrations/skipped/$migration
      ((skipped_count++))
    fi
  fi
done

if (( skipped_count > 0 )); then
  echo "Auto-skipped $skipped_count GUI migrations (not applicable to headless)"
fi
