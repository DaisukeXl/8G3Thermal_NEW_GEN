#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}

# This script will be executed in late_start service mode

# Disable sched_boost
echo 0 > /proc/sys/kernel/sched_boost

# Disable msm_thermal and core_control
echo N > /sys/module/msm_thermal/parameters/enabled
echo 0 > /sys/module/msm_thermal/core_control/enabled
echo 0 > /sys/kernel/msm_thermal/enabled

# Disable I/O Stats in all sd, sda, sdb, etc.
for queue in /sys/block/sd*/queue
do
    echo "0" > "$queue/iostats"
done ;
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
done ;
for THERMAL_ZONE in $(ls /sys/class/thermal/thermal_zone*/type | sort); do
  if cat "$THERMAL_ZONE" | grep -E "therm|ram|hardware|cpu|gpu|ddr|pa|sdr|sub|bcl-w|mmw|aoss|nspss|video|mdmss|tz|camera|battery" >/dev/null; then
    for TRIP_POINT_TEMP in $(ls "${THERMAL_ZONE%/*}"/trip_point_*_temp | sort); do
      if [ "$(cat "$TRIP_POINT_TEMP")" -lt "$SET_TRIP_POINT_TEMP_MAX" ]; then
        echo "$SET_TRIP_POINT_TEMP_MAX" > "$TRIP_POINT_TEMP"
      fi
    done
  fi
done ;


sed -i 's/。 --[^,]*$//' ${MODDIR}/module.prop
echo -n ". Changed temp limit to $SET_TRIP_POINT_TEMP_MAX！" >> ${MODDIR}/module.prop && sed -i 's/000/℃/' ${MODDIR
for i in /sys/class/thermal/cooling_device* ; do
    chmod 666 $i/cur_state
    echo 0 > $i/cur_state
    chmod 444 $i/cur_state
done ;
exit 0