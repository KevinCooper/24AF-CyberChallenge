dos2unix *
tar -xzf vsftpd-2.3.5.tar.gz 
cp Makefile vsftpd-2.3.5
make -C vsftpd-2.3.5
make -C vsftpd-2.3.5 install 
cp vsftpd.conf /etc/vsftpd.conf
cp vsftpd_init.d /etc/init.d/vsftpd
chmod +x /etc/init.d/vsftpd
mkdir /home/ftp
groupadd ftp
useradd ftp -d /home/ftp -g ftp -m -p `mkpasswd DoNotUseThisLive1`
chmod 555 -R /home/ftp
update-rc.d vsftpd defaults
update-rc.d vsftpd enable