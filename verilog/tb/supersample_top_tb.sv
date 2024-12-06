`include "sys_defs.svh"

module supersample_top_tb ();

logic clk;
logic rst;
logic valid_in;
logic [$clog2(`CH+1)-1:0] ch_in;     // 0=Y, 1=Cb, 2=Cr
logic [8:0] block_in [7:0][7:0];
logic [8:0] block_1_out [7:0][7:0];
logic [8:0] block_2_out [7:0][7:0];
logic [8:0] block_3_out [7:0][7:0];
logic [8:0] block_4_out [7:0][7:0];
logic [$clog2(`CH+1)-1:0] ch_out;
logic [3:0] valid_out;

parameter CLK_PERIOD = 10;

supersample_top u0 (
    .clk(clk),
    .rst(rst),
    .valid_in(valid_in),
    .ch_in(ch_in),
    .block_in(block_in),
    .block_1_out(block_1_out),
    .block_2_out(block_2_out),
    .block_3_out(block_3_out),
    .block_4_out(block_4_out),
    .ch_out(ch_out),
    .valid_out(valid_out)
);

always #(CLK_PERIOD/2) begin
    clk = ~clk;
end

int x;

initial begin
    clk = 0;
    rst = 1;
    ch_in = 2'b00; // Y
    valid_in = 0;

    repeat(3) @(negedge clk)
    rst = 0;

    @(negedge clk)

    /* Y Channel */
    valid_in = 1;
    x = 1;

    for (int i = 7; i >= 0; i = i - 1) begin
        for (int j = 7; j >= 0; j = j - 1) begin
            block_in[i][j] = x;
            x = x + 1;
        end
    end
    @(negedge clk);

    /* Y Channel */
    valid_in = 1;
    x = 2;

    for (int i = 7; i >= 0; i = i - 1) begin
        for (int j = 7; j >= 0; j = j - 1) begin
            block_in[i][j] = x;
            x = x + 1;
        end
    end
    @(negedge clk);

    /* Y Channel */
    valid_in = 1;
    x = 3;

    for (int i = 7; i >= 0; i = i - 1) begin
        for (int j = 7; j >= 0; j = j - 1) begin
            block_in[i][j] = x;
            x = x + 1;
        end
    end
    @(negedge clk);

    /* Y Channel */
    valid_in = 1;
    x = 4;

    for (int i = 7; i >= 0; i = i - 1) begin
        for (int j = 7; j >= 0; j = j - 1) begin
            block_in[i][j] = x;
            x = x + 1;
        end
    end
    @(negedge clk);

    /* Cb Channel */
    ch_in = 2'b01;
    valid_in = 1;
    x = 5;

    for (int i = 7; i >= 0; i = i - 1) begin
        for (int j = 7; j >= 0; j = j - 1) begin
            block_in[i][j] = x;
            x = x + 1;
        end
    end
    @(negedge clk);

    /* Cr Channel */
    ch_in = 2'b10;
    valid_in = 1;
    x = 6;

    for (int i = 7; i >= 0; i = i - 1) begin
        for (int j = 7; j >= 0; j = j - 1) begin
            block_in[i][j] = x;
            x = x + 1;
        end
    end
    @(negedge clk);

    valid_in = 0;

    @(negedge clk);
    @(negedge clk);

    $stop;

end

endmodule