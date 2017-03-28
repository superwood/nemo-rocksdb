SRC_DIR = $(CURDIR)/src
LIB_OUTPUT = $(CURDIR)/lib

ifndef ROCKSDB_PATH
ROCKSDB_PATH = $(CURDIR)/rocksdb
endif


dummy := $(shell (cd $(ROCKSDB_PATH); export ROCKSDB_ROOT="$(ROCKSDB_PATH)"; "$(ROCKSDB_PATH)/build_tools/build_detect_platform" "$(CURDIR)/make_config.mk"))
include $(CURDIR)/make_config.mk
CXXFLAGS = $(PLATFORM_CXXFLAGS) $(PLATFORM_SHARED_CFLAGS) -Wall -W -Wno-unused-parameter -g -O2 -D__STDC_FORMAT_MACROS 


INCLUDE_PATH = -I./include/ \
			   -I$(ROCKSDB_PATH)/ \
			   -I$(ROCKSDB_PATH)/include/

LIBRARY = libnemodb.a
ROCKSDB = $(ROCKSDB_PATH)/librocksdb.a

.PHONY: all clean distclean

BASE_OBJS := $(wildcard $(SRC_DIR)/*.cc)
BASE_OBJS += $(wildcard $(SRC_DIR)/*.c)
BASE_OBJS += $(wildcard $(SRC_DIR)/*.cpp)
OBJS = $(patsubst %.cc,%.o,$(BASE_OBJS))

all: $(ROCKSDB) $(LIBRARY)
	mkdir -p $(LIB_OUTPUT)
	mv $(LIBRARY) $(LIB_OUTPUT)
	@echo "Success, go, go, go..."

$(ROCKSDB):
	make -C $(ROCKSDB_PATH) static_lib

$(LIBRARY): $(OBJS)
	rm -rf $@
	ar -rcs $@ $(OBJS)

$(OBJS): %.o : %.cc
	$(CXX) $(CXXFLAGS) -c $< -o $@ $(INCLUDE_PATH)

clean: 
	rm -rf $(SRC_DIR)/*.o
	rm -rf $(LIB_OUTPUT)
	rm -f $(CURDIR)/make_config.mk

distclean: clean
	make -C $(ROCKSDB_PATH) clean
	rm -rf $(CURDIR)/make_config.mk

