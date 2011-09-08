#!/bin/bash -x

echo "deb     http://deb.torproject.org/torproject.org $(lsb_release  -cs) main" > /etc/apt/sources.list.d/tor.list
gpg --keyserver keys.gnupg.net --recv 886DDD89
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -
apt-get update
apt-get install -y --force-yes tor tor-geoipdb git
cd /opt
git clone git://github.com/noisetor/ops

CPUS=$(cat /proc/cpuinfo  | grep "^processor	" | wc -l);

for i in $(seq 1 $CPUS); do
	cp /opt/ops/configs/torrc /etc/tor/torrc.${i}
	RPORT=$((442 + $i));
	DIRPORT=$((79 + $i))
	DATADIR="/var/lib/tor${i}"
	PIDFILE="/var/run/tor/tor${i}.pid"
	mkdir -p $DATADIR;
	sed -i "s/RPort 443/RPort $RPORT/g" /etc/tor/torrc.${i}
	sed -i "s/DirPort 80/RPort $DIRPORT/g" /etc/tor/torrc.${i}
	sed -i "s/DataDirectory \/var\/lib\/tor/DataDirectory $DATADIR/g" /etc/tor/torrc.${i}
	sed -i "s/PidFile \/var\/lib\/tor/PidFile $PIDFILE/g" /etc/tor/torrc.${i}
done

cp /opt/ops/bin/init-tor /etc/init.d/tor
/etc/init.d/tor start
