#!/system/bin/sh
##########################################################################################
# Magisk Module Installer Script
# Super Thermal SD8G3 EXTREME EDITION
##########################################################################################

##########################################################################################
# Config Flags (Non modificare a meno che non si sappia cosa si sta facendo)
##########################################################################################

SKIPMOUNT=false
PROPFILE=false
POSTFSDATA=true
LATESTARTSERVICE=true

##########################################################################################
# Percorsi da sostituire (Aggiungere o rimuovere percorsi in base alle modifiche)
##########################################################################################

REPLACE="/system/etc/thermal
/system/etc/thermal-engine-normal.conf
/system/vendor/etc/thermal
/system/vendor/etc/thermal-engine-normal.conf
/sys/class/thermal
/sys/devices/virtual/thermal
/sys/devices/platform/soc
/sys/class/power_supply
/system/build.prop
/vendor/build.prop"

##########################################################################################
# Funzioni di Callback
##########################################################################################

# Funzione per stampare il nome del modulo
print_modname() {
  ui_print "*****************************************"
  ui_print "  Super Thermal SD8G3 EXTREME EDITION  "
  ui_print "*****************************************"
}

# Funzione eseguita all'installazione del modulo
on_install() {

  # Crea la cartella di backup
  ui_print "- Creazione cartella backup"
  mkdir -p $MODPATH/system/backup

  # Backup dei file originali
  ui_print "- Backup dei file originali in corso..."
  for DIR in $REPLACE; do
    if [ -e /system/$DIR ]; then
      cp -rf /system/$DIR $MODPATH/system/backup
    fi
  done

  # Estrazione dei file del modulo
  ui_print "- Estrazione dei file del modulo..."
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
}

# Funzione per impostare i permessi dei file
set_permissions() {
  # Imposta permessi ricorsivi di base
  set_perm_recursive $MODPATH 0 0 0755 0644

  # Imposta permessi specifici per le cartelle thermal
  set_perm_recursive $MODPATH/system/etc/thermal 0 0 0755 0644
  set_perm_recursive $MODPATH/system/vendor/etc/thermal 0 0 0755 0644

  # Permessi per modificare build.prop in /system e /vendor
  set_perm $MODPATH/system/build.prop 0 0 0644
  set_perm $MODPATH/vendor/build.prop 0 2000 0644 
}
