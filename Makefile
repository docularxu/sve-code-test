CC=gcc
# nok OPTS?=-O3 -ftree-vectorize -ftree-vectorizer-verbose=6
# ok OPTS?=-ftree-vectorize -ftree-vectorizer-verbose=2 -fdump-tree-vect-details -fopt-info -O2 -fopt-info-vec-missed
# ok OPTS?=-ftree-vectorize -O2 -fopt-info-vec-all 
# ok OPTS?=-O3 -fopt-info-vec-optimized -fopt-info-vec-missed 
# ok OPTS?=-O3 -fopt-info-vec-optimized -fopt-info-vec-missed 
# ok OPTS?=-O3 -fopt-info-vec-note -fopt-info-vec-optimized -fopt-info-vec-missed 
OPTS?=-O3 -fopenmp -fopt-info-vec-optimized-missed=vec.opt.log #-fopt-info-vec-missed

CFLAGS=-I. -march=armv8.2-a+sve
DEPS =
OBJ = test1.o sve_assembly-debug.os

%.os: %.S $(DEPS)
	$(CC) -c -o $@ $< $(OPTS) $(CFLAGS)

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(OPTS) $(CFLAGS)

test1: $(OBJ)
	$(CC) -o $@ $^ $(OPTS) $(CFLAGS)

example-armie: example-armie.c
	$(CC) -o $@ $^ $(OPTS) $(CFLAGS)

clean:
	rm -f *.o *.os test1 example-armie
