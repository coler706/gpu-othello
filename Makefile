CC              = /usr/bin/g++

CUDA_PATH       = /opt/cuda
CUDA_INC_PATH   = $(CUDA_PATH)/include
CUDA_BIN_PATH   = $(CUDA_PATH)/bin
CUDA_LIB_PATH   = $(CUDA_PATH)/lib64

NVCC		= nvcc

# CUDA code generation flags
GENCODE_FLAGS = -shared -Xcompiler -fPIC -gencode arch=compute_30,code=sm_30 \
		-gencode arch=compute_35,code=sm_35 \
		-gencode arch=compute_50,code=sm_50 \
		-gencode arch=compute_52,code=sm_52 \
		-gencode arch=compute_60,code=sm_61 \
		-gencode arch=compute_61,code=sm_61 \

CUDA_LIB_PATH := $(CUDA_LIB_PATH)
LDFLAGS       = -lm -lpthread -L$(CUDA_LIB_PATH) -lcudart -lcuda -lcufft -lcurand
CCFLAGS       = -std=c++11 -m64 -Wall -pedantic -O3 -fPIC
NVCCFLAGS     = -shared -Xcompiler -fPIC --std=c++11 -x cu -m64 -lcudart -lcuda -lcufft -lcurand -O3 -dc -D_FORCE_INLINES

OBJS        = board.o simulate.o gametree.o player.o gpu_utilities.o
PLAYERNAME  = gpu-othello

all: $(PLAYERNAME) testgame test

$(PLAYERNAME): gpuCode.o $(OBJS) wrapper.cpp
	$(CC) $^ -o $@ $(CCFLAGS) $(LDFLAGS) -I$(CUDA_INC_PATH)

testgame: gpuCode.o $(OBJS) testgame.cpp
	$(CC) $^ -o $@ $(CCFLAGS) $(LDFLAGS) -I$(CUDA_INC_PATH)

test: gpuCode.o $(OBJS) test.cpp
	$(CC) $^ -o $@ $(CCFLAGS) $(LDFLAGS) -I$(CUDA_INC_PATH)

gpuCode.o: $(OBJS)
	$(NVCC) $(GENCODE_FLAGS) -dlink $^ -o $@

%.o: %.cpp
	$(NVCC) $(NVCCFLAGS) $(GENCODE_FLAGS) -I$(CUDA_INC_PATH) -o $@ -c $<

java:
	make -C java/

cleanjava:
	make -C java/ clean

clean:
	rm -f *.o $(PLAYERNAME) test testgame

.PHONY: java
