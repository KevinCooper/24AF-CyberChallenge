dos2unix *
tar -xjf proftpd-1.3.3.tar.bz2 
cp -R proftpd-1.3.3/* .
./configure --sysconfdir=/etc --disable-ident --enable-dso
make clean
make
make install
cp proftpd.conf /etc/proftpd.conf
cp proftpd_init.d /etc/init.d/proftpd
chmod +x /etc/init.d/proftpd
update-rc.d proftpd defaults
update-rc.d proftpd enable