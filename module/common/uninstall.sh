#!/system/bin/sh
MODDIR=${0%/*}

# --- Funzioni ---

# Funzione per stampare il nome del modulo
print_modname() {
  ui_print "*****************************************"
  ui_print "  Super Thermal SD8G3 EXTREME EDITION  "
  ui_print "*****************************************"
}

# Funzione per interrompere l'esecuzione con un messaggio di avviso
abort_with_warning() {
  ui_print "$1"
  ui_print "Abortando la disinstallazione del modulo."
  exit 1
}

# Funzione per chiedere conferma all'utente
confirm_uninstall() {
  ui_print "Sei sicuro di voler disinstallare Super Thermal SD8G3 EXTREME EDITION?"
  ui_print "Questo ripristinerà le impostazioni termiche originali."
  local choice
  while true; do
    ui_print "[Volume Su] - Sì [Volume Giù] - No"
    read choice
    case "$choice" in
      1) return 0 ;;  # Sì
      0) abort_with_warning "- Disinstallazione annullata dall'utente." ;;
      *) ui_print "Scelta non valida. Premi Volume Su per Sì o Volume Giù per No." ;;
    esac
  done
}

# --- Disinstallazione ---

print_modname()  # Stampa il nome del modulo
confirm_uninstall  # Chiedi conferma all'utente

# Verifica se il file $INFO esiste
if [ -f "$INFO" ]; then
  ui_print "- Ripristino dei file originali..."
  while read LINE; do
    if [ "$(echo -n "$LINE" | tail -c 1)" == "~" ]; then
      continue  # Salta i file di backup
    elif [ -f "$LINE~" ]; then
      ui_print "  - Ripristino $LINE"
      mv -f "$LINE~" "$LINE"  # Ripristina il backup
    else
      ui_print "  - Rimozione $LINE"
      rm -f "$LINE"  # Rimuovi il file del modulo

      # Rimuovi le directory vuote in modo ricorsivo
      while true; do
        LINE=$(dirname "$LINE")
        if [ "$(ls -A "$LINE" 2>/dev/null)" ]; then
          break  # Esci dal ciclo se la directory non è vuota
        else
          rm -rf "$LINE"  # Rimuovi la directory vuota
        fi
      done
    fi
  done < "$INFO"
  rm -f "$INFO"  # Rimuovi il file $INFO
else
  ui_print "- File $INFO non trovato. Potrebbe essere già stato disinstallato."
fi

ui_print "- Disinstallazione completata!"
