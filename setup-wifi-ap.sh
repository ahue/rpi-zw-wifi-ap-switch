#!/bin/sh

CONFIGDIR=$1
BACKUPDIR=$2

# Backup

if [ -d "$BACKUPDIR" ]; then
  echo "backup directory exists"
  exit 1
fi

mkdir -p $BACKUPDIR

# Current wpa_supplicant.conf
mkdir -p $BACKUPDIR/etc/wpa_supplicant/
cp /etc/wpa_supplicant/wpa_supplicant.conf $BACKUPDIR/etc/wpa_supplicant/wpa_supplicant.conf

# Backup current config
cp /etc/dhcpcd.conf $BACKUPDIR/etc/dhcpcd.conf
cp /etc/dnsmasq.conf $BACKUPDIR/etc/dnsmasq.conf

echo Try backing up hostapd.conf
echo May not be present
mkdir -p $BACKUPDIR/etc/hostapd/
cp /etc/hostapd/hostapd.conf $BACKUPDIR/etc/hostapd/hostapd.conf

mkdir -p $BACKUPDIR/etc/default
cp /etc/default/hostapd $BACKUPDIR/etc/default/hostapd

# Install required packages
apt-get update -y
apt-get install dnsmasq hostapd -y

# Write dhcpcd.conf
cp $CONFIGDIR/etc/dhcpcd.conf /etc/dhcpcd.conf

cp $CONFIGDIR/etc/dnsmasq.conf /etc/dnsmasq.conf

dnsmasq --test -C /etc/dnsmasq.conf

cp $CONFIGDIR/etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf
chmod 600 /etc/hostapd/hostapd.conf

cp $CONFIGDIR/etc/default/hostapd /etc/default/hostapd

# Remove current wifi connection setup
truncate -s 0 /etc/wpa_supplicant/wpa_supplicant.conf

# start up

systemctl daemon-reload

systemctl restart dhcpcd

systemctl restart dnsmasq
systemctl enable dnsmasq

systemctl unmask hostapd
systemctl start hostapd
systemctl enable hostapd

reboot


