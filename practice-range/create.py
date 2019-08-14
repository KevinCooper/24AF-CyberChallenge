import argparse
import glob
from multiprocessing.pool import ThreadPool as Pool
import random
import time
import sys
import importlib
from pathlib import Path
import pyVirtualize
import yaml
from pyVirtualize import vSphere
import threading

pool_size = 3  
scenarioConfig = None
pool = Pool(pool_size)
lock = threading.Lock()


def provision(host,vm,vsphere,args):
    global scenarioConfig, lock
    time.sleep(random.randint(1,5))
    print(f"[*] {host['name']}: creating")
    vm.operations.vmutils.clone(host['type'], host['name'], args.datacenter, args.cluster)
    t_vm = vsphere.VirtualMachines[host['name']]
    print(f"[*] {host['name']}: powering on")
    t_vm.operations.power.power_on()
    t_vm.set_credentials(username=host['username'], password=host['password'], credentials_type="admin",default=True)
    for operation in host['actions']:
        if operation['type'] == "execute":
            print(f"[*] {host['name']}: executing")
            t_vm.operations.process.execute(operation['program'], operation['arguments'], interactive=False)
        elif(operation['type'] == "restart"):
            print(f"[*] {host['name']}: restarting")
            t_vm.operations.power.restart()
        elif(operation['type'] == "snapshot"):
            print(f"[*] {host['name']}: snapshotting")
            t_vm.operations.snapshot.create(name=operation['name'], desc="", memory=False)
        elif(operation['type'] == "plugin_cmd"):
            print(f"[*] {host['name']}: running plugin")
            t_vm.operations.process.execute(program="c:\\windows\\system32\\cmd.exe", arguments="/c mkdir c:\\temp")
            files = glob.glob(operation['directory']+"*")
            lock.acquire(True)
            for t_file in files:
                if "execute.py" in t_file:
                    #import pdb; pdb.set_trace()
                    sys.path.append(str(Path(__file__).cwd()) + t_file.split("\\")[0].lstrip(".").replace("/","\\"))
                    t_module = importlib.import_module("execute", package=None)
                    t_module.execute()
            #        import pdb; pdb.set_trace()
            #        t_module = __import__("execute")
            #        t_module.execute()

            for t_file in files:
                t_vm.operations.file.upload(t_file, "C:\\temp\\" + t_file.split("\\")[-1])
            lock.release()

            try:
                if(operation['wait']):
                    t_vm.operations.process.execute(program="c:\\windows\\system32\\cmd.exe", arguments="/c c:\\temp\\execute.bat", cwd="c:\\temp", wait_for_program_to_exit=True)
                else:
                    t_vm.operations.process.execute(program="c:\\windows\\system32\\cmd.exe", arguments="/c c:\\temp\\execute.bat", cwd="c:\\temp", wait_for_program_to_exit=False)


                for t_file in files:
                    t_vm.operations.file.delete_remote("C:\\temp\\" + t_file.split("\\")[-1])
            except Exception as e:
                print(e)



        elif(operation['type'] == "plugin_psh"):
            files = glob.glob(operation['directory']+"*")
        elif(operation['type'] == "plugin_bash"):
            print(f"[*] {host['name']}: running plugin")
            files = glob.glob(operation['directory']+"*")
            #import pdb; pdb.set_trace()
            for t_file in files:
                if "execute.py" in t_file:
                    #import pdb; pdb.set_trace()
                    sys.path.append(str(Path(__file__).cwd()) + t_file.split("\\")[0].lstrip(".").replace("/","\\"))
                    t_module = importlib.import_module("execute", package=None)
                    t_module.execute()
                    
            for t_file in files:
                t_vm.operations.file.upload(t_file, "/tmp/" + t_file.split("\\")[-1])


            t_vm.operations.process.execute("/usr/bin/sudo", "/bin/bash -c \"dos2unix *\"","/tmp", interactive=False)
            t_vm.operations.process.execute("/usr/bin/sudo", "/bin/bash -c \"chmod +x execute.sh\"","/tmp", interactive=False)
            if(operation['wait']):
                t_vm.operations.process.execute("/usr/bin/sudo", "/bin/bash -c /tmp/execute.sh", "/tmp", wait_for_program_to_exit=True, interactive=False)
            else:
                t_vm.operations.process.execute("/usr/bin/sudo", "/bin/bash -c /tmp/execute.sh", "/tmp", wait_for_program_to_exit=False, interactive=False)
            #import pdb; pdb.set_trace()
            #for t_file in files:
            #    t_vm.operations.file.delete_remote("/tmp/" + t_file.split("\\")[-1])

    count = 0
    while t_vm.operations.network.get_ips() is None and count < 30:
        time.sleep(1)
        count += 1
    host['ips'] = t_vm.operations.network.get_ips()

def main():
    global scenarioConfig
    parser = argparse.ArgumentParser()
    parser.add_argument('--password', dest='password', required=True, help="VSphere password")
    parser.add_argument('--username', dest='username', required=True, help="VSphere username")
    parser.add_argument('--vsphere', dest='vsphere', help="VSphere name/ip", default="192.168.1.120")
    parser.add_argument('--datacenter', dest='datacenter', help="VSphere datacenter", default="datacenter")
    parser.add_argument('--cluster', dest='cluster', help="VSphere cluster", default="cluster1")
    parser.add_argument('--scenario', dest='scenario', help="Scenario to create", default="default.yaml")
    parser.add_argument('--create', dest='create', help="Build the scenario", action='store_true')
    parser.add_argument('--destroy', dest='destroy', help="Destroy the scenario", action='store_true')
    args = parser.parse_args()

    scenarioConfig = yaml.load(open(args.scenario, "r"))

    vsphere = vSphere(address=args.vsphere, username=args.username, password=args.password)
    vsphere.login()

    import pdb
    #pdb.set_trace()
    vm = vsphere.VirtualMachines['win-server-2003']
    if args.create:
        for host in scenarioConfig['hosts']:
            print(host)
            pool.apply_async(provision, (host,vm,vsphere,args))
            #provision(host,vm,vsphere,args)

        pool.close()
        pool.join()
        with open("output.yaml", "w") as f:
            yaml.dump(scenarioConfig, stream=f, default_flow_style=False)
    elif args.destroy:
        for host in scenarioConfig['hosts']:
            try:
                vm = vsphere.VirtualMachines[host['name']]
                print(f"[*] {host['name']}: destroying")
                vm.operations.vmutils.delete_from_disk(host['name'])
            except Exception as e:
                print(e)
            


    
    print("End")


if __name__ == "__main__":
    main()
