HALIDE_PATH = /home/tim/src/Halide
#DEPS_PATH = /home/tim/.julia/v0.3/HalideCall/deps
#_DEPS = halidecall.c
#DEPS = $(pathsubst %,$(DEPS_PATH)/%,$(_DEPS))
HALIDELIBDIR = $(HALIDE_PATH)/bin
HALIDEINCLUDEDIR = $(HALIDE_PATH)/include
CFLAGS = -I$(HALIDEINCLUDEDIR) -L$(HALIDELIBDIR) -lHalide -Wl,-rpath -Wl,$(HALIDELIBDIR)

CXX = g++

blur_generate: blur_generate.cpp
	$(CXX) blur_generate.cpp $(CFLAGS) -o blur_generate

BLURFILES = blur_twopasses.o blur_twopasses_vectorized.o blur_tiled.o

blur%.o: blur_generate
	./blur_generate

libblur: $(BLURFILES)
	gcc -fPIC -shared $(BLURFILES) -o libblur.so
