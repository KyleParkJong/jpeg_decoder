`include "sys_defs.svh"

module supersample_4x4_tb ();

logic clk;
logic rst;
logic [$clog2(`CH+1)-1:0] ch_in;      // Cb: 2'b01, Cr: 2'b10
logic valid_in;
logic signed [7:0] block_in [3:0][3:0];       // input: 4x4 block

logic signed [7:0] block_out [7:0][7:0];     // output: 8x8 block
logic valid_out;

parameter CLOCK_PERIOD = 10;

supersample_4x4 u0 (
    .clk(clk),
    .rst(rst),
    .ch_in(ch_in),
    .valid_in(valid_in),
    .block_in(block_in),
    .block_out(block_out),
    .valid_out(valid_out)
);

always #(CLOCK_PERIOD/2) begin
    clk = ~clk;
end

int x;

initial begin
    clk = 0;
    rst = 1;
    ch_in = 2'01; // Cb
    valid_in = 0;

    repeat(5) @(negedge clk)
    rst = 0;
    
    // valid input
    valid_in = 1;
    x = 1;
    for (int i = 3; i >= 0; i = i - 1) begin
        for (int j = 3; j >= 0; j = j - 1) begin
            block_in[i][j] = x;
            x = x + 1;
        end
    end
    
    @(negedge clk)

    valid_in = 0;

    @(negedge clk)
    @(negedge clk)

    $stop;

end

endmodule