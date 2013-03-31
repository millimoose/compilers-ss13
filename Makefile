CFLAGS := -std=c99 $(CFLAGS)

all: asmb.o

#samples: _asma.s _asma2.s

clean:
	-rm *.o asmb

%.s: %.c
	$(CC) $(CFLAGS) -S $<

asma-test: asmb.o main.o
	gcc -o $@ $^
