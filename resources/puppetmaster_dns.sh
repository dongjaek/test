#!/bin/bash

echo "Setting up /etc/resolv.conf"
echo "" >> /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf
echo "nameserver 127.0.0.1" >> /etc/resolv.conf
