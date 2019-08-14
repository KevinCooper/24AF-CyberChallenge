# 67/688-CW-Challenge

## Windows  
### File Attributes  
 * attrib -s   
 * attrib -r  
 * icacls
 * takeown
 * pending file rename??
### Server 2019  
### Server 2016  
### Server 2012  
#### DNS 
dnscmd.exe /RecordAdd 1.1.1.1.in-addr.arpa 100 PTR 102ED6BC
#### SMB  
Get-WindowsFeature FS-SMB1  
Disable-WindowsOptionalFeature -Online -FeatureName smb1protocol  
Enable-WindowsOptionalFeature -Online -FeatureName smb1protocol  
Get-SmbServerConfiguration | Select EnableSMB2Protocol  
Set-SmbServerConfiguration -EnableSMB2Protocol $false  
Set-SmbServerConfiguration -EnableSMB2Protocol $true  
### Server 2008  
### Server 2003  
### Server 2000
## Linux  
### Debian   
### Solaris  
### FreeBSD  
### MacOS  
