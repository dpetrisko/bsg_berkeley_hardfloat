TOP ?= $(shell git rev-parse --show-toplevel)

MKDIR        ?= mkdir -p
PYTHON       ?= python
ASCII_TO_ROM ?= $(EXTERNAL_DIR)/basejump_stl/bsg_mem/bsg_ascii_to_rom.py
GTKWAVE      ?= gtkwave

EXTERNAL_DIR ?= $(TOP)/external
SRC_DIR      ?= $(TOP)/src
TEST_DIR     ?= $(TOP)/test

SF_DIR ?= $(EXTERNAL_DIR)/SoftFloat-3e
HF_DIR ?= $(EXTERNAL_DIR)/HardFloat-1
TF_DIR ?= $(EXTERNAL_DIR)/TestFloat-3e

TF_GEN ?= $(TF_DIR)/build/Linux-x86_64-GCC/testfloat_gen

VV       ?= verilator
VV_OPTS  ?= --cc --exe --Wno-fatal --Wno-lint
VV_OPTS  += --trace --trace-structs
VV_OPTS  += --top-module testbench
VV_OPTS  += -f design.flist
VV_OPTS  += $(EXTERNAL_DIR)/basejump_stl/bsg_test/bsg_trace_replay.v
VV_OPTS  += +incdir+$(EXTERNAL_DIR)/basejump_stl/bsg_misc
VV_OPTS  += bsg_trace_rom.v
VV_OPTS  += testbench.v
VV_OPTS  += bsg_test.cpp
VV_OPTS  += +incdir+$(HF_DIR)/source
VV_OPTS  += +incdir+$(HF_DIR)/source/RISCV
VV_OPTS  += +incdir+$(SRC_DIR)

LINT_OPTS ?= --lint-only --Wall
LINT_OPTS += --top-module bsg_hardfloat_fpu
LINT_OPTS += -f design.flist
LINT_OPTS += +incdir+$(HF_DIR)/source
LINT_OPTS += +incdir+$(HF_DIR)/source/RISCV
LINT_OPTS += +incdir+$(SRC_DIR)

.DEFAULT: build

vcs:
	#vcs -full64 -debug_all +vcs+vcdpluson -sverilog -timescale=1ps/1ps -f sv.include bsg_trace_rom.v testbench.v
	vcs -full64 -sverilog -timescale=1ps/1ps -f sv.include bsg_trace_rom.v testbench.v
	./simv

verilate:
	$(VV) $(VV_OPTS) 

build: verilate
	$(MAKE) -C obj_dir/ -f Vtestbench.mk

sim: build
	./obj_dir/Vtestbench

gtkwave:
	$(GTKWAVE) -f dump.vcd &

dve:
	dve -full64 -vpd vcdplus.vpd &

lint:
	$(VV) $(LINT_OPTS)

TF_OPS ?= f64_sub
TRACE_GEN ?= tracegen.py

test: TF_OP ?= 
test: FU_OP ?= 
test: 
	$(TF_GEN) $(TF_OP) > bsg_trace_rom.txt
	$(PYTHON) $(TRACE_GEN) bsg_trace_rom.txt $(FU_OP) > bsg_trace_rom.tr
	$(PYTHON) $(ASCII_TO_ROM) bsg_trace_rom.tr bsg_trace_rom > bsg_trace_rom.v
	$(MAKE) vcs

regress:
	$(MAKE) TF_OP=f64_add FU_OP=fadd
	$(MAKE) TF_OP=f64_sub FU_OP=fsub
	$(MAKE) TF_OP=f64_mul FU_OP=fmul
	$(MAKE) TF_OP=f64_madd FU_OP=fmadd

clean:
	rm -rf *.tr
	rm -rf *.txt
	rm -rf *_rom.v
	rm -rf obj_dir
	rm -rf DVE*
	rm -rf csrc*
	rm -rf *.vcd
	rm -rf *.vpd
	rm -rf simv*
	rm -rf ucli.key
