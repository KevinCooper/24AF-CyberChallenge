import atexit
import os
import platform
import subprocess
import threading
import time
from smb.SMBConnection import SMBConnection
import dns.resolver
import ftplib

import requests
import yaml
from flask import Flask, render_template

app = Flask(__name__)
worker = threading.Thread()
status = dict()
scores = {}

@app.route("/")
def index():
    global status
    print(scores)
    return render_template('index.html', status=scores)

@app.route("/teams")
def teams():
    return render_template('teams.html', status=scores)

@app.route("/services")
def services():
    return render_template('services.html', status=status)

def ping(host):
    """
    Returns True if host (str) responds to a ping request.
    Remember that a host may not respond to a ping (ICMP) request even if the host name is valid.
    """

    # Option for the number of packets as a function of
    param = '-n' if platform.system().lower()=='windows' else '-c'

    # Building the command. Ex: "ping -c 1 google.com"
    command = ['ping', param, '1', host]
    FNULL = open(os.devnull, 'w')
    return subprocess.call(command, stdout=FNULL, stderr=subprocess.STDOUT) == 0

def check_http(host):
    """
    Returns the data if host (str) responds to a web request. Returns None if host does not respond.
    """

    url = f"http://{host}/ownership.html"

    try:
        r = requests.get(url, timeout=3)
        if r.status_code != 200:
            raise Exception(f"[-] {host} HTTP returning error code {r.status_code}")
        print(f"[+] {host} HTTP alive")
        return r.text
    except Exception as e:
        url = f"http://{host}:8080/ownership.html"
        try:
            r = requests.get(url, timeout=3)
            if r.status_code != 200:
                raise Exception(f"[-] {host} HTTP returning error code {r.status_code}")
            print(f"[+] {host} HTTP alive")
            return r.text
        except Exception as e:
            print(f"[-] {host} HTTP down")
            print(e)
            return None
        print(f"[-] {host} HTTP down")
        print(e)
        return None

def check_smb(host):
    """
    Returns the data if host (str) responds to a smb request. Returns None if host does not respond.
    """

    command = ['smbclient', f"//{host}/Public", '-U', '" "%" "', "-c", "get ownership.txt"]
    FNULL = open(os.devnull, 'w')
    success = subprocess.call(command, stdout=FNULL, stderr=subprocess.STDOUT) == 0
    if success:
        data = open("ownership.txt", 'r').read()
        os.unlink("ownership.txt")
        print(f"[+] {host} SMB alive")
        return data
    else:
        print(f"[-] {host} SMB down")
        return None

def check_dns(host):
    """
    Returns the data if host (str) responds to a smb request. Returns None if host does not respond.
    """

    t_resolver = dns.resolver.Resolver()
    t_resolver.nameservers = [host]
    t_resolver.timeout = 3
    t_resolver.lifetime = 3
    answer = None
    try:
        answer = t_resolver.query("ownership.ctf-net.com", "TXT")
    except Exception as e:
        print(e)
    
    if answer is not None:
        print(f"[+] {host} DNS alive")
        return answer.response.answer[0][-1].strings[0].decode()
    else:
        print(f"[-] {host} DNS down")
        return None

def check_ftp(host):
    """
    Returns the data if host (str) responds to a smb request. Returns None if host does not respond.
    """

    
    banner = None
    try:
        ftp = ftplib.FTP(host)
        banner = ftp.getwelcome()
    except Exception as e:
        print(e)
    
    if banner is not None:
        print(f"[+] {host} FTP alive")
        return banner
    else:
        print(f"[-] {host} FTP down")
        return None


def score():
    global status,scores
    config = yaml.load(open("output.yaml", "r"))

    stopped = False
    while not stopped:
        for host in config['hosts']:
            try:
                ip = host['ips'][0]
            except Exception as e:
                print(e)
                continue
            host_alive = ping(ip)

            if(not host_alive):
                print(f"[-] {ip} is dead")
                status[ip] = {"alive":False}
            else:
                print(f"[+] {ip} is alive")
                status[ip] = {"alive":True}

            for service in host['services']:
                service_status = None
                if "smb" in service and host_alive:
                    service_status = check_smb(ip)
                elif "http" in service and host_alive:
                    service_status = check_http(ip)
                elif "dns" in service and host_alive:
                    service_status = check_dns(ip)
                elif "ssh" in service and host_alive:
                    pass
                elif "ftp" in service and host_alive:
                    service_status = check_ftp(ip)

                if service_status is not None:
                    service_status = service_status.replace(" ", "").replace("\n","").replace("\r","").strip("").lower()
                    status[ip][service] = True
                    status[ip]['owner'] = service_status
                    if service_status not in scores:
                        scores[service_status] = 0
                    else:
                        scores[service_status] += 1
                else:
                    status[ip][service] = False
                    status[ip]['owner'] = "scorebot"

        time.sleep(60)
    

if __name__=="__main__":
    worker = threading.Thread(target=score)
    worker.daemon = True
    worker.start()
    app.run("0.0.0.0", 80)
