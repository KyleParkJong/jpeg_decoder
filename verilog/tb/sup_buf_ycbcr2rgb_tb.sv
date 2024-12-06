`include "sys_defs.svh"

module sup_buf_ycbcr2rgb_tb ();

logic clk;
logic rst;
logic valid_in;
logic [$clog2(`CH+1)-1:0] ch_in;     // 0=Y, 1=Cb, 2=Cr
logic [7:0] block_in [7:0][7:0];
logic unsigned [7:0] r [7:0][7:0];
logic unsigned [7:0] g [7:0][7:0];
logic unsigned [7:0] b [7:0][7:0];
logic valid_out;

sup_buf_ycbcr2rgb u0 (
    .clk(clk),
    .rst(rst),
    .valid_in(valid_in),
    .ch_in(ch_in),
    .block_in(block_in),
    .r(r),
    .g(g),
    .b(b),
    .valid_out(valid_out)
);

task wait_cycles(int n);
    repeat(n) @(negedge clk);
endtask

parameter CLK_PERIOD = 10;

always #(CLK_PERIOD/2) begin
    clk = ~clk;
end

int x;

integer fileID1, status_ID1;
integer R_chan, G_chan, B_chan;

initial begin
    fileID1 = $fopen("tb/tiny_postIDCT.txt", "r");
    R_chan = $fopen("tb/tiny_R.txt", "w");
    G_chan = $fopen("tb/tiny_G.txt", "w");
    B_chan = $fopen("tb/tiny_B.txt", "w");

    if (fileID1 == 0) begin
        $display("ERROR: Failed to open files.");
        $finish;
    end

    clk = 0;
    rst = 1;
    ch_in = 2'b00; // Y
    valid_in = 0;

    wait_cycles(2);
    rst = 0;

    valid_in = 1;

    /* Y1 */
    for (int i = 7; i >= 0; i = i - 1) begin
        for (int j = 7; j >= 0; j = j - 1) begin
            status_ID1 = $fscanf(fileID1, "%d", block_in[i][j]);
            if (status_ID1 == 0) begin
                $display("ERROR: Failed to read from files.");
                $finish;
            end
        end
    end
    @(negedge clk);

    /* Y2 */
    for (int i = 7; i >= 0; i = i - 1) begin
        for (int j = 7; j >= 0; j = j - 1) begin
            status_ID1 = $fscanf(fileID1, "%d", block_in[i][j]);
        end
    end
    @(negedge clk);

    /* Y3 */
    for (int i = 7; i >= 0; i = i - 1) begin
        for (int j = 7; j >= 0; j = j - 1) begin
            status_ID1 = $fscanf(fileID1, "%d", block_in[i][j]);
        end
    end
    @(negedge clk);

    /* Y4 */
    for (int i = 7; i >= 0; i = i - 1) begin
        for (int j = 7; j >= 0; j = j - 1) begin
            status_ID1 = $fscanf(fileID1, "%d", block_in[i][j]);
        end
    end
    @(negedge clk);

    ch_in = 2'b01;
    /* Cb */
    for (int i = 7; i >= 0; i = i - 1) begin
        for (int j = 7; j >= 0; j = j - 1) begin
            status_ID1 = $fscanf(fileID1, "%d", block_in[i][j]);
        end
    end
    @(negedge clk);

    ch_in = 2'b10;
    /* Cr */
    for (int i = 7; i >= 0; i = i - 1) begin
        for (int j = 7; j >= 0; j = j - 1) begin
            status_ID1 = $fscanf(fileID1, "%d", block_in[i][j]);
        end
    end
    @(negedge clk);

    valid_in = 0;

    wait_cycles(15);

    $fclose(fileID1);
    $fclose(R_chan);
    $fclose(G_chan);
    $fclose(B_chan);

    $stop;
end

always @(negedge clk) begin
        if (valid_out) begin
            for (int i = 7; i >= 0; i = i - 1) begin
                for (int j = 7; j >= 0; j = j - 1) begin
                    $fwrite(R_chan, "%d ", r[i][j]);
                end
                $fwrite(R_chan, "\n");
            end

            for (int i = 7; i >= 0; i = i - 1) begin
                for (int j = 7; j >= 0; j = j - 1) begin
                    $fwrite(G_chan, "%d ", g[i][j]);
                end
                $fwrite(G_chan, "\n");
            end

            for (int i = 7; i >= 0; i = i - 1) begin
                for (int j = 7; j >= 0; j = j - 1) begin
                    $fwrite(B_chan, "%d ", b[i][j]);
                end
                $fwrite(B_chan, "\n");
            end
        end
    end

endmodule