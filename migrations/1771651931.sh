echo "Hide wiremix and limine-snapper-restore from app launcher"

[[ -f $OMARCHY_PATH/applications/hidden/wiremix.desktop ]] && cp $OMARCHY_PATH/applications/hidden/wiremix.desktop ~/.local/share/applications/
[[ -f $OMARCHY_PATH/applications/hidden/limine-snapper-restore.desktop ]] && cp $OMARCHY_PATH/applications/hidden/limine-snapper-restore.desktop ~/.local/share/applications/
