`include "sys_defs.svh"

module zigzag_tb;

    logic clk, reset;
    logic signed [`Q-1:0] quantized [7:0][7:0];
    logic signed [`Q-1:0] quantized_zz [63:0];
    logic [$clog2(64)-1:0] count;

    zigzag dut (
        // in
        clk, reset,
        quantized, 
        // out
        quantized_zz
    );

    initial begin
        count = 0;
        reset = 1;
        for (int i = 0; i < 8; ++i) begin
            for (int j = 0; j < 8; ++j) begin
                quantized[i][j] = count;
                ++count;
            end
        end
        #`PERIOD
        reset = 0;
        #(`PERIOD * 2)
        
        $write("quantized array: \n");
        for (int i = 0; i < 8; ++i) begin
            for (int j = 0; j < 8; ++j) begin
                $write("%2d ", quantized[i][j]);
            end
            $write("\n");
        end

        $write("zigzag: \n");
        for (int i = 0; i < 64; ++i) begin
            $write("%0d ", quantized_zz[i]);
        end
        $write("\n");

        $finish;
    end

endmodule



