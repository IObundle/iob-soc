#!/usr/bin/env python3

import sys
import termios

PROGNAME: str = "IOb-Non-Canonical"

stdin = sys.stdin
fd = stdin.fileno()

old = termios.tcgetattr(fd)
new = termios.tcgetattr(fd)
new[3] &= ~termios.ECHO
new[3] &= ~termios.ICANON

termios.tcsetattr(fd, termios.TCSAFLUSH, new)
print(f"{PROGNAME}: activating terminal non-canonical mode")
