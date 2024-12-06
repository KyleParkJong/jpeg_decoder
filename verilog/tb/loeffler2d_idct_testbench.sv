module loeffler2d_idct_testbench;

logic clk;
logic rst;
logic valid_in;
logic valid_out;

logic signed [11:0] idct_in     [7:0][7:0];
logic signed [11:0] idct_in_mem [7:0][7:0];
logic signed [8:0]  idct_out    [7:0][7:0];

initial begin
    $readmemh("./idct_input_block.mem", idct_in_mem);
end

// Instantiate IDCT module
loeffler2d_idct idct2d_module (
    .clk(clk),
    .rst(rst),
    .valid_in(valid_in),
    .idct_in(idct_in),
    .idct_out(idct_out),
    .valid_out(valid_out)

);

task wait_cycles(int n);
    repeat(n) @(posedge clk);
endtask

// Clock
always begin
    #5 clk <= ~clk;
end

always_comb begin
    for(int row = 0; row < 8; row++) begin
        for(int col = 0; col < 8; col++) begin
            idct_in[row][col] = idct_in_mem[row][col];
        end
    end
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

    // Wait until we are done calculating DCT coefficients
    while(~valid_out) begin
        @(posedge clk);
    end

    $finish();
end
endmodule: loeffler2d_idct_testbench