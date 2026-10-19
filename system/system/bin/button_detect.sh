#!/system/bin/sh

echo "Entering button_detect.sh" > /dev/kmsg

if [ "$#" -ne 1 ]; then
    echo "usage: button_detect.sh <input file>"
    exit 1
fi

if [ ! -e "$1" ]; then
    echo "invalid file $1"
    exit 1
fi

echo "Wait for event to reboot" > /dev/kmsg
# wait for an event to appear and reboot
cat $1 | busybox od -N 3
echo "rebooting..." > /dev/kmsg
reboot
