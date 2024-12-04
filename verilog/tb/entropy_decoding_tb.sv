`include "sys_defs.svh"

module entropy_decoding_tb;
    logic clk, rst;
    logic [`IN_BUS_WIDTH-1:0] data_in;
    logic valid_in;
    HUFF_TABLE_ENTRY [`H-1:0] tab;
    
    logic signed [11:0] block [7:0][7:0];
    logic valid_out;
    logic request;

    import displays::*;

    entropy_decoding dut (
        // in
        clk, rst,
        data_in, valid_in,
        tab,
        // out
        block, 
        valid_out,
        request
    );

	initial begin
        // huff table def 
        tab[0].size = 4'h5;
        tab[0].code = 16'h15;
        tab[0].symbol = 8'h69;
        
        tab[1].size = 4'h2;
        tab[1].code = 16'h3;
        tab[1].symbol = 8'h01;

        tab[2].size = 4'h9;
        tab[2].code = 16'h21;
        tab[2].symbol = 8'hF0;
        
        tab[3].size = 4'h8;
        tab[3].code = 16'hF0;
        tab[3].symbol = 8'h00;

        // initial values
        clk = 0;
        rst = 1;
        valid_in = 0;
        @(posedge clk);
        @(posedge clk);
        @(negedge clk);
        rst = 0;
        // start of (6,9)(-511); (15,0)(); (0,1)(-1); (6, 9)(511); 
        data_in = 32'b0_10101_000100001_0_11_111111111_10101; 
        valid_in = 1;
        @(negedge clk);
        
        valid_in = 0;
        @(negedge clk);
        @(negedge clk);

        // (rest) (0,0)(EOB); (0,1)(1); (0,1)(-1); (0,0)(EOB); end of (6,9)(-511);
        data_in = 32'b11110000_1_11_0_11_11110000_00000000;
        @(negedge clk);
        valid_in = 1;
        @(negedge clk);
        valid_in = 0;
        @(negedge clk);
        assert(valid_out) else disp_fail;
        disp_block;

        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        assert(valid_out) else disp_fail;
        disp_block;

        disp_pass;
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
