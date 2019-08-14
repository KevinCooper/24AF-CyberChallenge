#!/bin/bash
# Author: Imp3rial

echo "Deleteing old scans directory"
rm -rf ./scans
mkdir scans

read -p "Enter an IP range (ex: 192.168.10.0): " range

echo "Scanning for SSH hosts"
nmap -n -T4 -oG ./scans/22_scan.txt -p 22 $range/24 &> /dev/null
awk '/22\/open/{print $2}' ./scans/22_scan.txt > temp
mv temp ./scans/22_scan.txt

echo "Scanning for SMB hosts"
nmap -n -T4 -oG ./scans/445_scan.txt -p 445 $range/24 &> /dev/null
awk '/445\/open/{print $2}' ./scans/445_scan.txt > temp
mv temp ./scans/445_scan.txt

echo "Scanning for Telnet hosts"
nmap -n -T4 -oG ./scans/23_scan.txt -p 23 $range/24 &> /dev/null
awk '/23\/open/{print $2}' ./scans/23_scan.txt > temp
mv temp ./scans/23_scan.txt

echo "Scanning for FTP hosts"
nmap -n -T4 -oG ./scans/21_scan.txt -p 21 $range/24 &> /dev/null
awk '/21\/open/{print $2}' ./scans/21_scan.txt > temp
mv temp ./scans/21_scan.txt

echo "Scanning for MYSQL hosts"
nmap -n -T4 -oG ./scans/3306_scan.txt -p 3306 $range/24 &> /dev/null
awk '/3306\/open/{print $2}' ./scans/3306_scan.txt > temp
mv temp ./scans/3306_scan.txt

echo "Scanning for VNC hosts"
nmap -n -T4 -oG ./scans/5900_scan.txt -p 5900 $range/24 &> /dev/null
awk '/3306\/open/{print $2}' ./scans/5900_scan.txt > temp
mv temp ./scans/5900_scan.txt
