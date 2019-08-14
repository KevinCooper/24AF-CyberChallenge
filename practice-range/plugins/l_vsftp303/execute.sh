dos2unix *
tar -xzf vsftpd-3.0.3.tar.gz 
cp Makefile vsftpd-3.0.3
make -C vsftpd-3.0.3
make -C vsftpd-3.0.3 install 
cp vsftpd.conf /etc/vsftpd.conf
cp vsftpd_init.d /etc/init.d/vsftpd
chmod +x /etc/init.d/vsftpd
mkdir /home/ftp
groupadd ftp
useradd ftp -d /home/ftp -g ftp -m -p `mkpasswd DoNotUseThisLive1`
chmod 555 -R /home/ftp
update-rc.d vsftpd defaults
update-rc.d vsftpd enable