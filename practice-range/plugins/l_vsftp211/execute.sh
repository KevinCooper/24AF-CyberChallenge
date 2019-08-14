dos2unix *
tar -xzf vsftpd-2.1.1.tar.gz 
cp Makefile vsftpd-2.1.1 
make -C vsftpd-2.1.1 
make -C vsftpd-2.1.1 install 
cp vsftpd.conf /etc/vsftpd.conf
cp vsftpd_init.d /etc/init.d/vsftpd
chmod +x /etc/init.d/vsftpd
mkdir /home/ftp
groupadd ftp
useradd ftp -d /home/ftp -g ftp -m -p `mkpasswd DoNotUseThisLive1`
update-rc.d vsftpd defaults
update-rc.d vsftpd enable