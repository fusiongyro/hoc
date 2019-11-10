all: hoc

hoc: hoc.o
	$(CC) -o $@ $^
