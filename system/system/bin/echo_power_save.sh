#!/system/bin/sh

echo "Entering power save mode" > /dev/kmsg

# Attempt to write to IDME up to 3 times
retry=0
while [ $retry -lt 3 ]
do
    if [ $retry -gt 0 ]
    then
        echo "retry entering power save mode #$retry" > /dev/kmsg
    fi
    # Set bootmode to 5 = power save mode
    /system/bin/idme bootmode 5
    mode=`/system/bin/idme print bootmode`
    if [ $mode -eq 5 ]
    then
        break
    fi
    retry=$((retry + 1))
done

if [ $retry -eq 3 ]
then
    echo "Unable to enter power save mode after $retry retries" > /dev/kmsg
fi

# Now reboot to enter power mode
/system/bin/reboot