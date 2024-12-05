`include "sys_defs.svh"

module entropy_decoding_tb;
    logic clk, rst;
    logic [`IN_BUS_WIDTH-1:0] data_in;
    logic valid_in;
    HUFF_PACKET hp;
    
    logic signed [11:0] block [7:0][7:0];
    logic valid_out;
    logic request;
    logic [$clog2(`CH+1)-1:0] ch;

    import displays::*;
    integer finput, line_len, index;

    entropy_decoding dut (
        // in
        clk, rst,
        data_in, valid_in,
        hp,
        // out
        block, 
        valid_out,
        request,
        ch
    );

	initial begin
        hp.map[0] = 0;
        hp.map[1] = 1;
        hp.map[2] = 1;

        finput = $fopen("../python/tiny/DC_HuffTable_Index0Flipped.txt", "r");
        line_len = -1;
        hp.tabs[0].dc_tab = 0;
        hp.tabs[0].dc_size = 12;
        index = 0;
        while(!$feof(finput)) begin
           line_len = $fscanf(finput, "%b %d %d\n", hp.tabs[0].dc_tab[index].code,
                    hp.tabs[0].dc_tab[index].symbol, hp.tabs[0].dc_tab[index].size);
            index = index + 1;
        end

        finput = $fopen("../python/tiny/DC_HuffTable_Index1Flipped.txt", "r");
        line_len = -1;
        hp.tabs[1].dc_tab = 0;
        hp.tabs[1].dc_size = 12;
        index = 0;
        while(!$feof(finput)) begin
           line_len = $fscanf(finput, "%b %d %d\n", hp.tabs[1].dc_tab[index].code,
                    hp.tabs[1].dc_tab[index].symbol, hp.tabs[1].dc_tab[index].size);
            index = index + 1;
        end

        finput = $fopen("../python/tiny/AC_HuffTable_Index0Flipped.txt", "r");
        line_len = -1;
        hp.tabs[0].ac_tab = 0;
        hp.tabs[0].ac_size= 162;
        index = 0;
        while(!$feof(finput)) begin
           line_len = $fscanf(finput, "%b %d %d\n", hp.tabs[0].ac_tab[index].code,
                    hp.tabs[0].ac_tab[index].symbol, hp.tabs[0].ac_tab[index].size);
            index = index + 1;
        end

        finput = $fopen("../python/tiny/AC_HuffTable_Index1Flipped.txt", "r");
        line_len = -1;
        hp.tabs[1].ac_tab = 0;
        hp.tabs[1].ac_size = 162;
        index = 0;
        while(!$feof(finput)) begin
           line_len = $fscanf(finput, "%b %d %d\n", hp.tabs[1].ac_tab[index].code,
                    hp.tabs[1].ac_tab[index].symbol, hp.tabs[1].ac_tab[index].size);
            index = index + 1;
        end

        // initial values
        clk = 0;
        rst = 1;
        valid_in = 0;
        data_in = 0;
        @(posedge clk);
        @(posedge clk);
        rst = 0;

        finput = $fopen("../python/tiny/bitStreamFlipped.txt", "r");
        line_len = -1;
        while(!$feof(finput)) begin
            @(negedge clk);
            if (request) begin
                line_len = $fscanf(finput, "%b\n", data_in);
                valid_in = 1;
            end else begin
                valid_in = 0;
            end
            if (valid_out) disp_block;
        end
        @(negedge clk);
        valid_in = 0;
        for (int i = 0; i < 20; ++i) begin
            @(negedge clk);
            if (valid_out) disp_block;
        end
        $finish; 
    end

    task disp_block;
        $write("Output Block\n");
        for (int r = 0; r < 8; ++r) begin
            for (int c = 0; c < 8; ++c) begin
                $write("%4d ", block[r][c]);
            end
            $write("\n");
        end
    endtask

    always #(`PERIOD/2) clk = ~clk;

endmodule
