dos2unix *
tar -xzf proftpd-1.3.2.tar.gz 
cp -R proftpd-1.3.2/* .
./configure --sysconfdir=/etc
make clean
make
make install
cp proftpd.conf /etc/proftpd.conf
cp proftpd_init.d /etc/init.d/proftpd
chmod +x /etc/init.d/proftpd
update-rc.d proftpd defaults
update-rc.d proftpd enable