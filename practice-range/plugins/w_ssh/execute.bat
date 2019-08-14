.\7za.exe x ssh.zip
mv OpenSSH-Win32 "C:\Program Files\OpenSSH"

echo scorebot > "C:\Program Files\OpenSSH\sshd-banner"

sc.exe create ssh-agent binpath= "C:\Program Files\OpenSSH\ssh-agent.exe" start= auto
sc.exe sdset ssh-agent "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;IU)(A;;CCLCSWLOCRRC;;;SU)(A;;RP;;;AU)"
sc.exe privs ssh-agent SeImpersonatePrivilege
sc.exe start ssh-agent

sc.exe create sshd binpath= "C:\Program Files\OpenSSH\sshd.exe -f %PROGRAMDATA%\ssh\sshd_config" start= auto
sc.exe privs sshd SeAssignPrimaryTokenPrivilege/SeTcbPrivilege/SeBackupPrivilege/SeRestorePrivilege/SeImpersonatePrivilege
sc.exe start sshd

ping 127.0.0.1 -n 6 > nul

sc.exe stop sshd
sc.exe stop ssh-agent

echo Port 22 > "%PROGRAMDATA%\ssh\sshd_config"
echo AddressFamily any >> "%PROGRAMDATA%\ssh\sshd_config"
echo ListenAddress 0.0.0.0 >> "%PROGRAMDATA%\ssh\sshd_config"
echo PermitRootLogin yes >> "%PROGRAMDATA%\ssh\sshd_config"
echo PasswordAuthentication yes >> "%PROGRAMDATA%\ssh\sshd_config"
echo Banner "C:\Program Files\OpenSSH\sshd-banner" >> "%PROGRAMDATA%\ssh\sshd_config"

sc.exe start ssh-agent
sc.exe start sshd
