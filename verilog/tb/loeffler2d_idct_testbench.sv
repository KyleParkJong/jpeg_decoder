module loeffler2d_idct_testbench;

logic clk;
logic rst;
logic valid_in;
logic valid_out;

logic signed [11:0] idct_in_mem [7:0][7:0];
logic signed [11:0] idct_in     [7:0][7:0];
logic unsigned [7:0] idct_out    [7:0][7:0];

int finput;

initial begin
    finput = $fopen("../verilog/tb/idct_input_block2.txt", "r");
    for (int row = 0; row < 8; row++) begin
        for (int col = 0; col < 8; col++) begin
            $fscanf(finput, "%d\n", idct_in_mem[row][col]);
        end
    end
end

// Instantiate IDCT module
loeffler2d_idct idct2d_module (
    .clk(clk),
    .rst(rst),
    .valid_in(valid_in),
    .idct_in(idct_in),
    .idct_out(idct_out),
    .valid_out(valid_out),
    .channel_out()
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

    disp_block;

    $finish();
end

task disp_block;
        $write("Output Block: \n");
        for (int r = 0; r < 8; ++r) begin
            for (int c = 0; c < 8; ++c) begin
                $write("%4d ", idct_out[r][c]);
            end
            $write("\n");
        end
endtask

endmodule: loeffler2d_idct_testbench