#!/system/bin/sh

IPTABLES=/system/bin/iptables
SOCKS=/system/bin/socks
LOG=/system/bin/log
TAG=Socks5

# Read the P2P interface name
target=$($GETPROP ro.fireos.target.product)
if [ "${target}" == "full_sonar" ] || [ "${target}" == "rook" ] || [ "${target}" == "csm_sonar" ]; then
    IF_NAME='p2p-wlan0-'
    P2PIF=$($WPA_CLI interface | grep $IF_NAME)
else
    P2PIF=p2p0
fi

print() {
    $LOG -t $TAG $1
}

start_setup_socks () {
    print "Setting up ip table rules"
    #$IPTABLES -A INPUT -i "$P2PIF" -p udp --dport 1080 --sport 1080 -j ACCEPT
    #$IPTABLES -A INPUT -i "$P2PIF" -p tcp --dport 1080 -j ACCEPT
    #$IPTABLES -A OUTPUT -o "$P2PIF" -j ACCEPT
#accept all for now
    $IPTABLES -P INPUT ACCEPT
    $IPTABLES -P OUTPUT ACCEPT
    $IPTABLES -P FORWARD ACCEPT
    $IPTABLES -F
    print "starting server"
#attempt 5 times
    retry=0
    while [[ $retry -le 5 ]]; do
      $SOCKS -i  "$P2PIF" -p 1080
      (( retry++ ))
      sleep 1
    done
    print "exit"
}

stop_setup_socks() {
    print "Removing ip table rules"
    $IPTABLES -D INPUT -i "$P2PIF" -p udp --dport 1080 --sport 1080 -j ACCEPT
    $IPTABLES -D INPUT -i "$P2PIF" -p tcp --dport 1080 -j ACCEPT
    $IPTABLES -D OUTPUT -o "$P2PIF" -j ACCEPT
    print "Done"
}

case "$1" in
    start)
        start_setup_socks "$@"
        exit 0
        ;;
    stop)
        stop_setup_socks "$@"
        exit 0
        ;;
    *)
        exit 1
        ;;
esac

exit 1

