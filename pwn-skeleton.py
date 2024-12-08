from pwn import *

binary = args.BIN
HOST = "127.0.0.1"
PORT = 31337

context.terminal = ["tmux", "splitw", "-h"]
e = context.binary = ELF(binary)
r = ROP(e)

if args.LIBC:
    libc = args.LIBC
else:
    libc = e.libc

gs = """
continue
"""


def start():
    if args.GDB:
        return gdb.debug(binary, gdbscript=gs)
    elif args.REMOTE:
        return remote(HOST, PORT)
    else:
        return process(binary)


p = start()


p.interactive()
