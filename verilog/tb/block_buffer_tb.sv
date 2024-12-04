`include "sys_defs.svh"

module block_buffer_tb;
    logic clk, rst;
    logic signed [11:0] vli_value;
    logic [3:0] run;
    logic wr_en;
    logic signed [`BLOCK_BUFF_SIZE-1:0][11:0]data_out;
    logic valid_out;

    import displays::*;

block_buffer dut (
    // in
    clk, rst,
    vli_value, 
    run, wr_en,
    // out
    data_out, valid_out
);

initial begin
    clk = 0;
    rst = 1;
    wr_en = 0;
    @(posedge clk);
    @(posedge clk);
    @(negedge clk);
    rst = 0;
    run = 6;
    vli_value = 12'd511;
    wr_en = 1;
    @(negedge clk);
    run = 0;
    vli_value = -12'sd1;
    @(negedge clk);
    run = 6;
    vli_value = -12'sd511;
    @(negedge clk);
    run = 0;
    vli_value = 0;

    @(negedge clk);
    assert(valid_out) else disp_fail;
    assert(data_out[6]==12'd511) else disp_fail;
    assert(signed'(data_out[7])==-12'sd1) else disp_fail;
    assert(signed'(data_out[14])==-12'sd511) else disp_fail;
    assert(data_out[`IN_BUFF_SIZE-1]==12'd0) else disp_fail;

    // repeter s'il vous plait
    run = 6;
    vli_value = 12'd511;
    wr_en = 1;
    @(negedge clk);
    run = 0;
    vli_value = -12'sd1;
    @(negedge clk);
    run = 6;
    vli_value = -12'sd511;
    @(negedge clk);
    run = 0;
    vli_value = 0;

    @(negedge clk);
    assert(valid_out) else disp_fail;
    assert(data_out[6]==12'd511) else disp_fail;
    assert(signed'(data_out[7])==-12'sd1) else disp_fail;
    assert(signed'(data_out[14])==-12'sd511) else disp_fail;
    assert(data_out[`IN_BUFF_SIZE-1]==12'd0) else disp_fail;

    disp_pass;
    $finish;
end

always #(`PERIOD/2) clk = ~clk;

endmodule
