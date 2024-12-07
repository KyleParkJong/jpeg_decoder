`include "sys_defs.svh"

module supersample_4x4_tb ();

logic [$clog2(`CH+1)-1:0] ch;      // Cb: 2'b01, Cr: 2'b10
logic valid_in;
logic [7:0] block_in [3:0][3:0];       // input: 4x4 block

logic [7:0] block_out [7:0][7:0];     // output: 8x8 block
logic valid_out;

supersample_4x4 u0 (
    .ch(ch),
    .valid_in(valid_in),
    .block_in(block_in),
    .block_out(block_out),
    .valid_out(valid_out)
);

int x;

initial begin

    ch = 2'b01; // Cb
    valid_in = 0;

    #20;
    
    // valid input
    valid_in = 1;
    x = 1;
    for (int i = 3; i >= 0; i = i - 1) begin
        for (int j = 3; j >= 0; j = j - 1) begin
            block_in[i][j] = x;
            x = x + 1;
        end
    end
    
    #10;

    x = 2;
    for (int i = 3; i >= 0; i = i - 1) begin
        for (int j = 3; j >= 0; j = j - 1) begin
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