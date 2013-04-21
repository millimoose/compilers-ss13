CFLAGS := -std=c99 $(CFLAGS)
LIBS = l y

all: parser

#samples: _asma.s _asma2.s

clean:
	-rm scanner.c parser.c parser.h # generated C files
	-rm *.o # object files
	-rm scanner parser # executables
	-rm y.output # verbose bison output

#%.s: %.c
#	$(CC) $(CFLAGS) -S $<

parser.h: parser.c
	mv -f y.tab.h parser.h

scanner.o: parser.h
parser: scanner.o parser.o
