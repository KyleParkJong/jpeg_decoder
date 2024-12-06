module loeffler_dct_testbench;

logic clk;
logic rst;
logic valid_in;
logic valid_out;

logic signed [7:0] dct_in  [7:0];
logic signed [31:0] dct_out [7:0];

// Instantiate DCT module
loeffler_dct dct (
    .clk(clk),
    .rst(rst),
    .valid_in(valid_in),
    .dct_in(dct_in),
    .dct_out(dct_out),
    .valid_out(valid_out)

);

task wait_cycles(int n);
    repeat(n) @(posedge clk);
endtask

// Clock
always begin
    #5 clk <= ~clk;
end

initial begin
    clk   = 0;
    rst   = 0;
    valid_in = 0;

     // Clk and reset initial value
    clk = 0;
    rst = 0;

    // Reset
    wait_cycles(5);
    rst = 1;

    wait_cycles(5);
    rst = 0;

    // Drive DCT module
    valid_in = 1;
    dct_in[0] = 50;
    dct_in[1] = 60;
    dct_in[2] = 70;
    dct_in[3] = 80;
    dct_in[4] = 90;
    dct_in[5] = 100;
    dct_in[6] = 110;
    dct_in[7] = 120;

    // Wait until we are done calculating DCT coefficients
    while(~valid_out) begin
        @(posedge clk);
    end

    $finish();
end
endmodule: loeffler_dct_testbench