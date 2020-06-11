#!/bin/sh

systemctl stop dnsmasq
systemctl disable dnsmasq

systemctl stop hostapd
systemctl disable hostapd