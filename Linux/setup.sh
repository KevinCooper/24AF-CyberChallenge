gcc -pthread dirty.c -o dirty_64 -lcrypt -m64
gcc -pthread dirty.c -o dirty_32 -lcrypt -m32
gcc -Wall -o linux-sendpage_32 linux-sendpage.c -m32
gcc -Wall -o linux-sendpage_64 linux-sendpage.c -m64
chmod +x les.sh dirty_32 dirty_64 linux-send*
