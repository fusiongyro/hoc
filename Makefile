CFLAGS = -Wall
YFLAGS = -d
OBJS = hoc.o init.o math.o symbol.o

all: hoc

hoc: $(OBJS)
	$(CC) -o $@ -lm $^

init.o symbol.o: hoc.h y.tab.h

pr:
	@pr hoc.y hoc.h init.c math.c symbol.c Makefile

clean:
	rm -f $(OBJS) y.tab.[ch]
