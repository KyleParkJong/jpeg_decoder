VCS = vcs -kdb -sverilog -debug_access+all+reverse

TB = input_system_tb.sv
RTL = zigzag.sv huffman_decoder.sv vli_decoder.sv input_buffer.sv
DEFS = sys_defs.svh

.DEFAULT_GOAL = sim

SOURCES = $(addprefix tb/, $(TB)) $(addprefix rtl/, $(RTL)) $(DEFS)

simv: $(SOURCES)
	$(VCS) $^ -o $@

sim: simv
	./simv | tee program.out 

.PHONY: sim

verdi: $(SOURCES)
	$(VCS) $^ -R -gui 

.PHONY: verdi

clean:
	rm -rvf *simv csrc *.key vcdplus.vpd vc_hdrs.h
	rm -rf verdiLog
	rm -rf simv.daidir
	rm -rvf verdi* novas* *fsdb*
	rm -rvf *.out *.dump
	rm -rvf *.log
	rm -rf *.DB
	rm -rf *.lib++ 
	rm -rf *.vpd DVEfiles
	rm -rf .inter* .vcs* .restart*
	rm -rf *.chk *.rep

