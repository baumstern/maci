#!/bin/bash

sudo mkswap -f /dev/xvdb
sudo swapon /dev/xvdb

sudo fallocate -l 30G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

sudo sh -c 'echo "vm.max_map_count=10000000" >>/etc/sysctl.conf'
sudo sh -c 'echo 10000000 > /proc/sys/vm/max_map_count'