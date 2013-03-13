CFLAGS=-std=c99

all: asma.o

samples: _asma.s _asma2.s

clean:
	-rm _*.s *.o asma-test

%.s: %.c
	$(CC) -O3 -S $<

asma-test: asma.o asma_test.o
	gcc -o $@ $^
