# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT

XOSHIRO_PATH = ..

SOURCES = $(wildcard *.c)
SOURCES += $(wildcard $(XOSHIRO_PATH)/*.c)

HEADERS = $(wildcard *.h)
HEADERS = $(wildcard $(XOSHIRO_PATH)/*.h)

OBJECTS = $(patsubst %.c,%.o,$(SOURCES))

INCLUDE = -I$(XOSHIRO_PATH)

CFLAGS  = -O3 -std=c99 -Wall -Wextra -pedantic -Werror -Wpedantic \
	  -Wredundant-decls -Wvla -Wcast-align -Wmissing-prototypes

EXE = prng

all: $(EXE)
	./$(EXE)

$(EXE): $(OBJECTS)
	$(CC) $(CFLAGS) $(INCLUDE) $(OBJECTS) -o $(EXE)

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) $(INCLUDE) -c -o $@ $<

clean:
	$(RM) $(OBJECTS)
	$(RM) $(EXE)
