CFLAGS := -std=c99 $(CFLAGS)
LIBS := -lfl
LEX := flex

all: scanner

#samples: _asma.s _asma2.s

clean:
	-rm *.o *.yy.c scanner.c scanner

#%.s: %.c
#	$(CC) $(CFLAGS) -S $<
scanner.c: scanner.l

scanner: scanner.o

