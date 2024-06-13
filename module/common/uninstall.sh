#!/system/bin/sh
# Super Thermal SD8G3 EXTREME EDITION Uninstaller (Ultra-Optimized)

MODNAME="Super Thermal SD8G3 EXTREME EDITION"

# Conferma disinstallazione (semplificata con 'read -p')
read -p "Sei sicuro di voler disinstallare $MODNAME? [y/N] " choice
case "$choice" in
  [yY]*) ;; # Procedi se l'utente risponde 'y' o 'Y'
  *) 
    ui_print "- Disinstallazione annullata."
    exit 1
    ;;
esac

# Disinstallazione
ui_print "*****************************************"
ui_print "  $MODNAME Uninstallation  "
ui_print "*****************************************"

if [ -f "$INFO" ]; then
  ui_print "- Ripristino dei file originali..."
  # Ottimizzazione: utilizzo di xargs per elaborare più file in parallelo
  xargs -a "$INFO" -I % sh -c 'if [ "$(echo -n "%" | tail -c 1)" != "~" ] && [ -f "%~" ]; then mv -f "%~" "%"; rmdir --ignore-fail-on-non-empty "$(dirname "%~")"; fi'
  rm -f "$INFO"
else
  ui_print "- File $INFO non trovato. Potrebbe essere già stato disinstallato."
fi

ui_print "- Disinstallazione completata!"
