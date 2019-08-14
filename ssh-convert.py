import re

done = []
for line in open("ssh_log.txt","r").readlines():
    matches = re.match(r".*Host: ([0-9.]+) User: ([a-zA-Z0-9]+) Password: ([a-zA-Z0-9]+).*", line)
    if matches is None: continue
    if matches.group(1) not in done:
        print(f"ssh {matches.group(2)}@{matches.group(1)} pass: {matches.group(3)}")
        done.append(matches.group(1))
    
