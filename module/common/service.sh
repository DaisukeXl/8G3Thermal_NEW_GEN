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
  ui_print "Abortando l'esecuzione del modulo per sicurezza."
  exit 1
}

# Funzione per verificare se un servizio è attivo
is_service_active() {
  service list | grep -q "$1"
}

# --- Verifiche Iniziali ---

print_modname()  # Stampa il nome del modulo all'inizio

# Safety Check for Snapdragon 8 Gen 3 SoC 
ui_print "- Verificando SoC Snapdragon 8 Gen 3"
if ! grep -q "Snapdragon 8 Gen 3" /proc/cpuinfo; then
  abort_with_warning "- Questo modulo è progettato solo per Snapdragon 8 Gen 3. Non compatibile."
fi

# --- Disabilitazione Servizi Termici ---

# Lista dei servizi termici da disabilitare
thermal_services=(
  logd
  android.thermal-hal
  vendor.thermal-engine
  vendor.thermal_manager
  vendor.thermal-hal-2-0
  vendor.thermal-symlinks
  thermal_mnt_hal_service
  thermal
  mi_thermald
  thermald
  thermalloadalgod
  thermalservice
  sec-thermal-1-0
  debug_pid.sec-thermal-1-0
  thermal-engine
  vendor.thermal-hal-1-0
  vendor-thermal-1-0
  init.svc_debug_pid.mi_thermald
  init.svc_debug_pid.android.thermal-hal
  thermal-hal
)

ui_print "- Disabilitazione dei servizi termici"
for service in "${thermal_services[@]}"; do
  if is_service_active "$service"; then 
    stop "$service"
  fi
done
sleep 3  # Breve pausa per garantire che i servizi si siano fermati completamente

# --- Impostazione Proprietà e Valori ---

# Disabilita sched_boost e controlli termici msm
echo 0 > /proc/sys/kernel/sched_boost
echo N > /sys/module/msm_thermal/parameters/enabled
echo 0 > /sys/module/msm_thermal/core_control/enabled
echo 0 > /sys/kernel/msm_thermal/enabled

# Disable I/O Stats in all sd, sda, sdb, etc.
for queue in /sys/block/sd*/queue
do
    echo "0" > "$queue/iostats"
done

# Disable additional thermal controls
for i in /sys/class/thermal/therm* ; do
chmod 666 $i/policy
chmod 666 $i/passive
chmod 666 $i/mode
echo user_space > $i/policy
echo 0 > $i/passive
echo disabled > $i/mode
chmod 444 $i/mode
chmod 444 $i/policy
chmod 444 $i/passive
stop logd
sleep 1
stop android.thermal-hal
sleep 1
stop vendor.thermal-engine
sleep 1
stop vendor.thermal_manager
sleep 1
stop vendor.thermal-manager
sleep 1
stop vendor.thermal-hal-2-0
sleep 1
stop vendor.thermal-symlinks
sleep 1
stop thermal_mnt_hal_service
sleep 1
stop thermal
sleep 1
stop mi_thermald
sleep 1
stop thermald
sleep 1
stop thermalloadalgod
sleep 1
stop thermalservice
sleep 1
stop sec-thermal-1-0
sleep 1
stop debug_pid.sec-thermal-1-0
sleep 1
stop thermal-engine
sleep 1
stop vendor.thermal-hal-1-0
sleep 1
stop vendor-thermal-1-0
sleep1
stop init.svc_debug_pid.mi_thermald
sleep 1
stop init.svc_debug_pid.android.thermal-hal
sleep 1
stop thermal-hal
sleep 3
done ;
for i in /sys/class/thermal/*therm ; do
chmod 666 $i/policy
chmod 666 $i/passive
chmod 666 $i/mode
echo user_space > $i/policy
echo 0 > $i/passive
echo disabled > $i/mode
chmod 444 $i/policy
chmod 444 $i/passive
chmod 444 $i/mode
chmod 0666 /proc/sys/vm/swappiness
echo 0 > /proc/sys/vm/swappiness
setprop init.svc.thermal stopped
setprop init.svc.thermal-managers stopped
setprop init.svc.thermal_manager stopped
setprop init.svc.thermal_mnt_hal_service stopped
setprop init.svc.thermal-engine stopped
setprop init.svc.mi-thermald stopped
setprop init.svc.thermalloadalgod stopped
setprop init.svc.thermalservice stopped
setprop init.svc.thermal-hal stopped
setprop init.svc.vendor.thermal-symlinks
setprop init.svc.android.thermal-hal stopped
setprop init.svc.vendor.thermal-hal stopped
setprop init.svc.thermal-manager stopped
setprop init.svc.vendor-thermal-hal-1-0 stopped
setprop init.svc.vendor.thermal-hal-1-0 stopped
setprop init.svc.vendor.thermal-hal-2-0.mtk stopped
setprop init.svc.vendor.thermal-hal-2-0 stopped
setprop init.svc_debug_pid.mi_thermald stopped
setprop init.svc_debug_pid.android.thermal-hal stopped
SET_TRIP_POINT_TEMP_MAX=500000
done

# Disabilita I/O stats per le unità di archiviazione
ui_print "- Disabilitazione I/O Stats"
for queue in /sys/block/sd*/queue; do
  echo 0 > "$queue/iostats"
done

# Modifica Zone Termiche e Dispositivi di Raffreddamento
SET_TRIP_POINT_TEMP_MAX=500000 

ui_print "- Modifica delle zone termiche e dei dispositivi di raffreddamento"
for target in /sys/class/thermal/thermal_zone* /sys/class/thermal/*therm /sys/class/thermal/cooling_device*; do
  if [ -d "$target" ]; then  # Controlla se è una directory
    for file in policy passive mode cur_state; do
      if [ -f "$target/$file" ]; then
        chmod 666 "$target/$file"
        case "$file" in
          policy)     echo user_space > "$target/$file" ;;
          passive)    echo 0 > "$target/$file" ;;
          mode)       echo disabled > "$target/$file" ;;
          cur_state)  echo 0 > "$target/$file" ;;  # Solo per i dispositivi di raffreddamento
        esac
        chmod 444 "$target/$file"
      fi
    done

    # Imposta la temperatura del trip point (solo per le zone termiche)
    if [[ "$target" == /sys/class/thermal/thermal_zone* ]]; then
      for trip_point in "$target"/trip_point_*_temp; do
        if [ -f "$trip_point" ]; then
          current_value=$(cat "$trip_point")
          if [ "$current_value" -lt "$SET_TRIP_POINT_TEMP_MAX" ]; then
            echo "$SET_TRIP_POINT_TEMP_MAX" > "$trip_point"
          fi
        fi
      done
    fi
  fi
done


# Disabilita swap
chmod 0666 /proc/sys/vm/swappiness
echo 0 > /proc/sys/vm/swappiness

# Imposta le proprietà di sistema per indicare che i servizi termici sono fermati
ui_print "- Impostazione proprietà dei servizi termici su 'stopped'"
for prop in init.svc.thermal init.svc.thermal-managers init.svc.thermal_manager init.svc.thermal_mnt_hal_service init.svc.thermal-engine init.svc.mi-thermald init.svc.thermalloadalgod init.svc.thermalservice init.svc.thermal-hal init.svc.vendor.thermal-symlinks init.svc.android.thermal-hal init.svc.vendor.thermal-hal init.svc.thermal-manager init.svc.vendor-thermal-hal-1-0 init.svc.vendor.thermal-hal-2-0.mtk init.svc.vendor.thermal-hal-2-0 init.svc_debug_pid.mi_thermald init.svc_debug_pid.android.thermal-hal; do
  setprop "$prop" stopped
done

# --- Messaggio Finale ---

ui_print "- Limite di temperatura modificato con successo!"

exit 0