CFLAGS = -Wall
YFLAGS = -d
OBJS = hoc.o lex.o init.o math.o symbol.o

all: hoc

hoc: $(OBJS)
	$(CC) -o $@ -lm -lfl $^

hoc.o: hoc.h

lex.o init.o symbol.o: hoc.h y.tab.h

pr:
	@pr hoc.y hoc.h init.c math.c symbol.c Makefile

clean:
	rm -f hoc $(OBJS) y.tab.[ch]
