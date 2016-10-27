#!/bin/bash
set -e

DIR=~/spotify-connect-web-chroot
DIR_SYSTEM=/usr/local/lib/spotify-connect-web
DIR_SYSTEMD=/lib/systemd/system/
NAME=rpi-server3

if [ "$1" == "install-system" ]; then
  if [ "$(id -u)" != "0" ]; then
    echo "For system wide install this script must be run as root (e.g. use sudo $0)" 1>&2
    exit 1
  fi
        mkdir -p $DIR_SYSTEM
        cd $DIR_SYSTEM
        curl http://spotify-connect-web.s3-website.eu-central-1.amazonaws.com/spotify-connect-web.tar.gz | sudo tar xz
        cp $0 $DIR_SYSTEM/../../bin/
        cat >/lib/systemd/system/spotify-connect.service <<EOF
[Unit]
Description=Spotify Connect

[Service]
ExecStart=$DIR_SYSTEM/../../bin/$(basename $0) --name $NAME  --bitrate 320
StandardOutput=null

[Install]
WantedBy=multi-user.target
Alias=spotify-connect.service
        
EOF
        systemctl enable spotify-connect.service
        
elif [ "$1" == "install" ]; then
        mkdir -p $DIR
        cd $DIR
        curl -L https://github.com/Fornoth/spotify-connect-web/releases/download/0.0.3-alpha/spotify-connect-web_0.0.3-alpha_chroot.tar.gz | sudo tar xz
else
        trap "sudo umount $DIR/dev $DIR/proc" EXIT
        sudo mount --bind /dev $DIR/dev
        sudo mount -t proc proc $DIR/proc/
	sudo cp /etc/resolv.conf $DIR/etc/
        sudo chroot $DIR /bin/bash -c "cd /usr/src/app && python main.py $*"
fi
