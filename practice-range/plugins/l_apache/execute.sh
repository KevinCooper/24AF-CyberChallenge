dos2unix *
tar -xf httpd-2.4.39.tar.gz
cp -R httpd-2.4.39/* .
mkdir /etc/httpd
./configure --sysconfdir=/etc/httpd --exec-prefix=/usr/local/sbin
make clean
make
make install
cp httpd_init.d /etc/init.d/httpd
chmod +x /etc/init.d/httpd
echo scorebot > /var/www/html/ownership.html
update-rc.d httpd defaults
update-rc.d httpd enable