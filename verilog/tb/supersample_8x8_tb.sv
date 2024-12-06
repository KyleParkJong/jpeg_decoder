`include "sys_defs.svh"

module supersample_8x8_tb ();

    logic [$clog2(`CH+1)-1:0] ch;      // Cb: 2'b01, Cr: 2'b10
    logic valid_in;
    logic signed [8:0] block_in [7:0][7:0];       // input: 4x4 block
    logic signed [8:0] block_1_out [7:0][7:0];     // output: 8x8 block
    logic signed [8:0] block_2_out [7:0][7:0];
    logic signed [8:0] block_3_out [7:0][7:0];
    logic signed [8:0] block_4_out [7:0][7:0];
    logic [3:0] valid_out;

    supersample_8x8 u0 (
        .ch(ch),
        .valid_in(valid_in),
        .block_in(block_in),
        .block_1_out(block_1_out),
        .block_2_out(block_2_out),
        .block_3_out(block_3_out),
        .block_4_out(block_4_out),
        .valid_out(valid_out)
    );

    int x;

    initial begin
        ch = 2'b01; // Cb
        valid_in = 0;

        #20;
        
        valid_in = 1;
        x = 1;
        for (int i = 7; i >= 0; i = i - 1) begin
            for (int j = 7; j >= 0; j = j - 1) begin
                block_in[i][j] = x;
                x = x + 1;
            end
        end

        #10;

        x = 2;
        for (int i = 7; i >= 0; i = i - 1) begin
            for (int j = 7; j >= 0; j = j - 1) begin
                block_in[i][j] = x;
                x = x + 1;
            end
        end

        #10;

        valid_in = 0;

        #20;

        $stop;

    end

endmodule