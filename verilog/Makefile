VCS = vcs -kdb -sverilog -debug_access+all+reverse

TB = entropy_decoding_tb.sv
TB_LIBS = displays.sv
RTL = unzigzag.sv huffman_decoder.sv vli_decoder.sv input_buffer.sv block_buffer.sv entropy_decoding.sv diff_decoder.sv deQuant.sv top.sv supersample_4x4.sv supersample_8x8.sv supersample_top.sv
DEFS = sys_defs.svh

.DEFAULT_GOAL = sim

SOURCES = $(addprefix tb/, $(TB_LIBS) $(TB)) $(addprefix rtl/, $(RTL)) $(DEFS)

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

