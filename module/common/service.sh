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
done ;

for i in /sys/class/thermal/cooling_device* ; do
    chmod 666 $i/cur_state
    echo 0 > $i/cur_state
    chmod 444 $i/cur_state
done ;
exit 0