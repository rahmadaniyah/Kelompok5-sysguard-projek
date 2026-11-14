
#!/bin/bash

echo "       SYSTEM MONITORING"

while true
do
    read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
    idle1=$idle
    total1=$((user + nice + system + idle + iowait + irq + softirq + steal))

    sleep 1

    read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
    idle2=$idle
    total2=$((user + nice + system + idle + iowait + irq + softirq + steal))

    total_diff=$((total2 - total1))
    idle_diff=$((idle2 - idle1))

    CPU=$(awk "BEGIN {printf \"%.2f\", (1 - $idle_diff / $total_diff) * 100}")

    TOTAL_RAM=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
    AVAILABLE_RAM=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)

    USED_RAM=$((TOTAL_RAM - AVAILABLE_RAM))
    RAM=$(awk "BEGIN {printf \"%.2f\", ($USED_RAM / $TOTAL_RAM) * 100}")

    DISK=$(df -P / | awk 'NR==2 {gsub("%","",$5); print $5}')

    echo ""
    echo "Waktu       : $(date)"
    echo "CPU         : $CPU%"
    echo "RAM         : $RAM%"
    echo "Disk        : $DISK%"

    if (( $(echo "$CPU >= 80" | bc -l) )); then
        echo "[PERINGATAN] Penggunaan CPU tinggi!"
    else
        echo "[AMAN] Penggunaan CPU normal."
    fi

    if (( $(echo "$RAM >= 80" | bc -l) )); then
        echo "[PERINGATAN] Penggunaan RAM tinggi!"
    else
        echo "[AMAN] Penggunaan RAM normal."
    fi

    if [ "$DISK" -ge 80 ]; then
        echo "[PERINGATAN] Penggunaan Disk tinggi!"
    else
        echo "[AMAN] Penggunaan Disk normal."
    fi

    sleep 5
done
