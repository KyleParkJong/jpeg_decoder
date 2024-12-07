`include "sys_defs.svh"

module unzigzag_tb;
    import displays::*;
    logic [`BLOCK_BUFF_SIZE-1:0][`Q-1:0] line;
    logic signed [`Q-1:0] block [7:0][7:0];

    unzigzag dut (
        // in
        line,
        // out
        block
    );

    initial begin
        for (int i = 0; i < `BLOCK_BUFF_SIZE; ++i) begin
            line[i] = i;
        end 

        #`PERIOD
        
        for (int r = 0; r < 8; ++r) begin
            for (int c = 0; c < 8; ++c) begin
                $write("%d ", block[r][c]);
            end
            $write("\n");
        end

        $finish;
        
    end

endmodule
