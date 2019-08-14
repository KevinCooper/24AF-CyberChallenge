import atexit
import datetime
import ftplib
import json
import os
import platform
import re
import socketserver
import sqlite3
import subprocess
import threading
import time
from multiprocessing.pool import ThreadPool
from time import strftime

import dns.resolver
import fabric
import requests
import yaml
from flask import Flask, Response, jsonify, render_template, request

app = Flask(__name__)
lock = threading.Lock()
#conn = sqlite3.connect(':memory:', check_same_thread=False)
conn = sqlite3.connect('data.db', check_same_thread=False)
conn.execute('''CREATE TABLE IF NOT EXISTS commands (id integer primary key, conn_ip text, cmd_ip text, user text, pid int, cmd text, time text)''')
conn.execute('''CREATE TABLE IF NOT EXISTS sudoattempts (id integer primary key, conn_ip text, cmd_ip text, user text, password text)''')
conn.execute('''CREATE TABLE IF NOT EXISTS agents (id integer primary key, address text, username text, password text, status text)''')
conn.execute('''CREATE TABLE IF NOT EXISTS procs (id integer, user text, pid integer, tty text, atime text, command text)''')
conn.execute('''CREATE TABLE IF NOT EXISTS conns (id integer, laddress text, faddress text, state text, pid integer)''')
conn.commit()


@app.route("/consolidated")
def consolidated():
    return render_template('consolidated.html')

@app.route("/")
def index():
    return render_template('index.html')

@app.route("/commands", methods=['GET', 'OPTIONS'])
def commands():
    global conn
    data = []
    with conn:
        for row in conn.execute(f"select * from commands ORDER BY id DESC LIMIT 1000"):
            t_item = { 'id' : row[0], 'sendip' : row[1], 'cmdip' : row[2], 'user' : row[3], 'pid' : row[4], 'cmd': row[5], 'time':row[6] }
            data.append(t_item)
    js = json.dumps(data)
    return Response(js, status=200, mimetype='application/json')

@app.route("/sudo", methods=['GET', 'OPTIONS'])
def sudo():
    global conn
    data = []
    with conn:
        for row in conn.execute(f"select * from sudoattempts ORDER BY id DESC LIMIT 1000"):
            data.append({ 'id' : row[0], 'sendip' : row[1], 'cmdip' : row[2], 'user' : row[3], 'password' : row[4] })
    js = json.dumps(data)
    return Response(js, status=200, mimetype='application/json')

@app.route("/execute/<int:agentid>", methods=['POST'])
def g_execute(agentid):
    global conn
    data = []
    if request.method == 'POST':
        result = ""
        data = request.form
        command = request.form.get("command")
        cmd_ip = conn.execute(f"select address from agents where id = {agentid}").fetchone()[0]
        for connection in connections:
            if connection.host == cmd_ip:
                try:
                    result = connection.run(command, hide=True)
                    result = result.stdout
                except Exception as e:
                    result = str(e)    
                    
        return Response(result, status=200, mimetype='text/plain')
    return Response("", status=404, mimetype='text/plain')

@app.route("/netstat", methods=['GET', 'OPTIONS', 'POST'])
def g_netstat():
    global conn
    data = []
    if request.method == 'GET':
        with conn:
            for row in conn.execute(f"select * from conns ORDER BY id DESC LIMIT 1000"):
                data.append({ 'id' : row[0], 'laddress' : row[1], 'faddress' : row[2], 'state' : row[3], 'pid' : row[4] })
        js = json.dumps(data)
        return Response(js, status=200, mimetype='application/json')
    elif request.method == 'POST':
        result = ""
        data = request.form
        agentid = request.form.get("id")
        pid = request.form.get("pid").split("/")[0]
        cmd_ip = conn.execute(f"select address from agents where id = {agentid}").fetchone()[0]
        for connection in connections:
            if connection.host == cmd_ip:
                try:
                    result = connection.run(f"kill -9 {pid}", hide=True)
                    result = result.stdout
                except Exception as e:
                    result = str(e)    
                    
        return Response(result, status=200, mimetype='text/plain')

@app.route("/procs", methods=['GET', 'OPTIONS', 'POST'])
def g_procs():
    global conn, connections
    data = []
    if request.method == 'GET':
        with conn:
            for row in conn.execute(f"select * from procs ORDER BY id DESC LIMIT 1000"):
                data.append({ 'id' : row[0], 'user' : row[1], 'pid' : row[2], 'tty' : row[3], 'atime' : row[4], 'command' : row[5] })
        js = json.dumps(data)
        return Response(js, status=200, mimetype='application/json')
    elif request.method == 'POST':
        result = ""
        data = request.form
        agentid = request.form.get("id")
        pid = request.form.get("pid")
        cmd_ip = conn.execute(f"select address from agents where id = {agentid}").fetchone()[0]
        for connection in connections:
            if connection.host == cmd_ip:
                try:
                    result = connection.run(f"kill -9 {pid}", hide=True)
                    result = result.stdout
                except Exception as e:
                    result = str(e)   
        return Response(result, status=200, mimetype='text/plain')


@app.route("/whitelist")
def whitelist():
    return render_template('teams.html')

@app.route("/agent/<int:agentid>", methods=['GET', 'OPTIONS', 'PUT', 'POST', 'DELETE'])
def agent(agentid):
    global conn
    data = []
    if request.method == 'GET':
        data.append({'id' : 1, 'action': 'list', 'result': "hacked"})
        js = json.dumps(data)
        return Response(js, status=200, mimetype='application/json')
    elif request.method == 'DELETE':
        with conn:
            conn.execute(f"DELETE FROM agents WHERE ID = {agentid}")
            conn.execute(f"DELETE FROM procs WHERE ID = {agentid}")
            conn.execute(f"DELETE FROM conns WHERE ID = {agentid}")

        cmd_ip = conn.execute(f"select address from agents where id = {agentid}").fetchone()
        if cmd_ip is not None:
            cmd_ip = cmd_ip[0]
            for connection in connections:
                if connection.host == cmd_ip:
                    connections.remove(connection)
                connection.close()
        else:
            pass
        js = json.dumps([])
        return Response(js, status=200, mimetype='application/json')



@app.route("/agent/<int:agentid>/procs", methods=['GET', 'DELETE'])
def procs(agentid):
    global conn
    data = []
    if request.method == 'GET':
        with conn:
            for row in conn.execute(f"select * from procs where id = {agentid}"):
                data.append({ 'id' : row[0], 'user' : row[1], 'pid' : row[2], 'tty' : row[3], 'atime' : row[4], 'command' : row[5] })
        js = json.dumps(data)
        return Response(js, status=200, mimetype='application/json')

@app.route("/agent/<int:agentid>/cmds", methods=['GET', 'DELETE'])
def cmds(agentid):
    global conn
    data = []
    if request.method == 'GET':
        with conn:
            cmd_ip = conn.execute(f"select address from agents where id = {agentid}").fetchone()
            if cmd_ip is not None:
                cmd_ip = cmd_ip[0]
                for row in conn.execute(f"select * from commands where cmd_ip = '{cmd_ip}' ORDER BY id DESC LIMIT 1000"):
                    data.append({ 'id' : row[0], 'conn_ip' : row[1], 'cmd_ip' : row[2], 'user' : row[3], 'pid' : row[4], 'cmd' : row[5], 'time':row[6] })
        js = json.dumps(data)
        return Response(js, status=200, mimetype='application/json')

@app.route("/agent/<int:agentid>/netstat", methods=['GET', 'DELETE'])
def netstat(agentid):
    global conn
    data = []
    if request.method == 'GET':
        with conn:
            for row in conn.execute(f"select * from conns where id = {agentid}"):
                data.append({ 'id' : row[0], 'laddress' : row[1], 'faddress' : row[2], 'state' : row[3], 'pid' : row[4] })
        js = json.dumps(data)
        return Response(js, status=200, mimetype='application/json')



@app.route("/agent/")
def agent_empty():
    global conn
    data = []
    with conn:
        for row in conn.execute(f"select * from agents ORDER BY id DESC LIMIT 1000"):
            t_item = { 'id' : row[0], 'address' : row[1], 'username' : row[2], 'password' : row[3], 'status': row[4] }
            data.append(t_item)
    js = json.dumps(data)
    return Response(js, status=200, mimetype='application/json')

@app.route("/agents", methods=['GET', 'POST'])
def agents():
    global conn, lock
    if request.method == 'POST':
        with lock:
            with conn:
                #print(request.form)
                #print(request.data)
                #print(request)
                address = request.form.get("address", "127.0.0.1")
                username = request.form.get("username", "root")
                password = request.form.get("password", "lol")
                conn.execute(f"insert into agents values (null, '{address}','{username}','{password}', 'Initial')")
        
    data = []
    with conn:
        for row in conn.execute(f"select * from agents ORDER BY id DESC LIMIT 1000"):
            data.append({ 'id' : row[0], 'address' : row[1], 'username' : row[2], 'password' : row[3] })
    return render_template('agents.html', data=data)
    






























class ThreadedUDPRequestHandler(socketserver.BaseRequestHandler):
    """
    The RequestHandler class for our server.

    It is instantiated once per connection to the server, and must
    override the handle() method to implement communication to the
    client.
    """

    def handle(self):
        global conn, lock
        # self.request is the TCP socket connected to the client
        #data = self.request.recv(1024*10).strip()
        data = self.request[0].strip()
        data = data.decode()
        recv_ip = self.client_address[0]
        #id integer primary key autoincrement, conn_ip text, cmd_ip text, user text, pid int, cmd text
        if re.match(r'(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) - (\w+) \[(\d+)\]: (.+) \[[0-9-]+\]', data):
            m = re.match(r'(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) - (\w+) \[(\d+)\]: (.+) \[[0-9-]+\]', data)
            #print("group 0:" + m.group(0))
            cmd_host = m.group(1)
            user = m.group(2)
            pid = m.group(3)
            cmd = m.group(4)
            time = datetime.datetime.now().strftime('%H:%M:%S')
            with lock:
                with conn:
                    conn.execute(f"insert into commands values (null, '{recv_ip}','{cmd_host}','{user}', {pid}, '{cmd}', '{time}')")
        elif re.match(r'(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) - (\w+) - sudo - (.+)', data):
            m = re.match(r'(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) - (\w+) - sudo - (.+)', data)
            #print("group 0:" + m.group(0))
            cmd_host = m.group(1)
            user = m.group(2)
            passwd = m.group(3)
            print(cmd_host, user, passwd)
            with lock:
                with conn:
                    conn.execute(f"insert into sudoattempts values (null, '{recv_ip}','{cmd_host}','{user}', '{passwd}')")
        else:
            print(f"Error: {data}")
               

class ThreadedUDPServer(socketserver.ThreadingMixIn, socketserver.UDPServer):
    pass












def executor():
    global connections
    while True:
        for connection in connections:
            agentID = connection.agentID

            with lock:
                with conn:
                    conn.execute(f"DELETE FROM conns WHERE id = {agentID}") 
                    conn.execute(f"DELETE FROM procs WHERE id = {agentID}")

            try:
                netstat = connection.run("netstat -natpu | grep 'LISTEN\|ESTABLISHED' | grep -v '::' | grep -v '127.0.0.1'", hide=True).stdout
            except Exception as e:
                connections.remove(connection)
                print(e)
                continue

            
            with lock:
                with conn:
                    for line in netstat.strip().split("\n"): 
                        if(len(line) < 10): continue
                        t_line = line.split()
                        t_line[6:] = [" ".join(t_line[6:])]
                        proto, _ , _, local, foreign, state, pid = t_line
                        conn.execute(f"insert into conns values ('{agentID}', '{local}','{foreign}','{state}', '{pid}')")

            try:
                ps = connection.run('ps auxw | grep -v CPU | grep -v "/sbin/getty" | grep -v $$', hide=True).stdout
            except Exception as e:
                connections.remove(connection)
                print(e)
                continue

            with lock:                
                with conn:
                    for line in ps.strip().split("\n"): 
                        if(len(line) < 10): continue
                        t_line = line.split()
                        t_line[10:] = [" ".join(t_line[10:])]
                        user, pid , _, _, _, _, tty, _, _, atime, command = t_line
                        if(tty == "?"): continue
                        #print(user, pid, tty, atime, command)
                        conn.execute(f"insert into procs values ('{agentID}', '{user}','{pid}','{tty}', '{atime}', '{command}')")
            
        time.sleep(5)



connections = []
def connection_builder():
    global connections
    while True:
        data = []

        with conn:
            for row in conn.execute(f"select * from agents"):
                data.append({ 'id' : row[0], 'address' : row[1], 'username' : row[2], 'password' : row[3], 'status': row[4] })
        

        curHosts = [f"{connection.user}:{connection.host}" for connection in connections]

        for item in data:
            #print(item)
            agentID, username, address, password = item['id'], item['username'], item['address'], item['password']

            result = ""
            connection = None

            if(f"{username}:{address}" not in curHosts):
                try:
                    connection = fabric.Connection(host=f"{username}@{address}", connect_timeout=15, connect_kwargs={"password": password})
                    connection.agentID = agentID
                    connection.run('date', hide=True)
                    result = "Alive - " + datetime.datetime.now().strftime('%H:%M:%S')
                    connections.append(connection)
                except Exception as e:
                    error = str(e)
                    result = datetime.datetime.now().strftime('%H:%M:%S') + f" - Exception: {error}"
            else:
                connection = list(filter(lambda x: f"{username}:{address}" in f"{x.user}:{x.host}", connections))[0]
                try:
                    connection.run('date', hide=True)
                    result = "Alive - " + datetime.datetime.now().strftime('%H:%M:%S')
                except Exception as e:
                    error = str(e)
                    result = datetime.datetime.now().strftime('%H:%M:%S') + f" - Exception: {error}"
            
            with lock:
                with conn:
                    conn.execute(f"UPDATE agents SET status = '{result}' WHERE id = {agentID}") 
            
        time.sleep(1)







































if __name__=="__main__":
    #Setup code for log processing
    HOST, PORT = "0.0.0.0", 1337
    server = ThreadedUDPServer((HOST, PORT), ThreadedUDPRequestHandler)
    ip, port = server.server_address

    # Start a thread with the server -- that thread will then start one
    # more thread for each request
    server_thread = threading.Thread(target=server.serve_forever)
    # Exit the server thread when the main thread terminates
    server_thread.daemon = True
    server_thread.start()
    print("* Server loop running in thread:", server_thread.name)

    with lock:
        with conn:
            conn.execute(f"DELETE FROM procs")
            conn.execute(f"DELETE FROM conns")

    runner_thread = threading.Thread(target=executor)
    # Exit the server thread when the main thread terminates
    runner_thread.daemon = True
    runner_thread.start()

    runner_thread = threading.Thread(target=connection_builder)
    # Exit the server thread when the main thread terminates
    runner_thread.daemon = True
    runner_thread.start()

    try:
        app.run("0.0.0.0", 80, debug=False)
    except KeyboardInterrupt as e:
        server.shutdown()
        server.server_close()
