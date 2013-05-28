CFLAGS = -std=c99 -g $(shell pkg-config --cflags glib-2.0)
LDFLAGS = $(shell pkg-config --libs glib-2.0)

all: codea

#samples: _asma.s _asma2.s

clean:
	-rm *.tab.*
	-rm *.yy.c matcher.c
	-rm oxout.*
	-rm *.o # object files
	-rm scanner parser ag foo codea # executables
	-rm *.output # verbose bison output

#%.s: %.c
#	$(CC) $(CFLAGS) -S $<

oxout.y oxout.l: parser.y scanner.l 
	ox parser.y scanner.l
	sed 's,///%,%,' oxout.y > _oxout.y
	mv _oxout.y oxout.y

parser.tab.c parser.tab.h: oxout.y
	bison --file-prefix=parser --verbose --defines oxout.y

scanner.yy.c: oxout.l
	flex -o scanner.yy.c oxout.l

scanner.yy.o: scanner.yy.c parser.tab.h
parser.tab.o: parser.tab.c
	$(CC) $(CFLAGS)

parser: scanner.l parser.y
	flex -o scanner.yy.c scanner.l
	bison --file-prefix=parser --verbose --defines parser.y
	$(CC) $(LDFLAGS) -o parser scanner.yy.c parser.tab.c

ag: scanner.yy.o parser.tab.o ag.o

matcher.c: matcher.bfe
	bfe < matcher.bfe | iburg > matcher.c

codea.o: matcher.c codea.c

codea: scanner.yy.o parser.tab.o ag.o codea.o

# test crap, not shared
foo: foo.c