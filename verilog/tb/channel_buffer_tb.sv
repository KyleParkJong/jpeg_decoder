module channel_buffer_tb;
    logic clk, rst;
    logic signed [`Q-1:0] blocks_in [3:0][7:0][7:0];
    logic wr_en;
    logic [$clog2(`CH+1)-1:0] ch;
    logic signed [`Q-1:0] y_out [7:0][7:0];
    logic signed [`Q-1:0] cr_out [7:0][7:0];
    logic signed [`Q-1:0] cb_out [7:0][7:0];
    logic valid_out;

    import displays::*;

    channel_buffer dut (
        // inputs
        clk, rst, blocks_in, wr_en, ch, 
        // outputs 
        y_out, cb_out, cr_out,
        valid_out
    );

    task disp_block(input logic signed [`Q-1:0] in [7:0][7:0]);
        $write("=========================================\n");
        for (int r = 0; r < 8; ++r) begin
            for (int c = 0; c < 8; ++c) begin
                $write("%4d ", in[r][c]);
            end
            $write("\n");
        end
    endtask

    always begin
        @(negedge clk);
        if (valid_out) begin
            $write("Y\n");
            disp_block(y_out);
            $write("Cb\n");
            disp_block(cb_out);
            $write("Cr\n");
            disp_block(cr_out);
        end
    end
    
    initial begin
        clk = 0;
        rst = 1;
        wr_en = 0;
        ch = 0;

        @(posedge clk);
        @(posedge clk);
        rst = 0;

        @(negedge clk);
        wr_en = 1;
        for (int r = 0; r < 8; ++r) begin
            for (int c = 0; c < 8; ++c) begin
                blocks_in[0][r][c] = r+c + 1;
            end
        end
        @(negedge clk);
        wr_en = 0;

        @(negedge clk);
        @(negedge clk);

        @(negedge clk);
        wr_en = 1;
        for (int r = 0; r < 8; ++r) begin
            for (int c = 0; c < 8; ++c) begin
                blocks_in[0][r][c] = r+c + 2;
            end
        end
        @(negedge clk);
        wr_en = 0;

        @(negedge clk);
        @(negedge clk);

        @(negedge clk);
        wr_en = 1;
        for (int r = 0; r < 8; ++r) begin
            for (int c = 0; c < 8; ++c) begin
                blocks_in[0][r][c] = r+c + 3;
            end
        end
        @(negedge clk);
        wr_en = 0;

        @(negedge clk);
        @(negedge clk);

        @(negedge clk);
        wr_en = 1;
        for (int r = 0; r < 8; ++r) begin
            for (int c = 0; c < 8; ++c) begin
                blocks_in[0][r][c] = r+c + 4;
            end
        end
        @(negedge clk);
        wr_en = 0;

        @(negedge clk);
        @(negedge clk);

        @(negedge clk);
        wr_en = 1;
        ch = 1;
        for (int r = 0; r < 8; ++r) begin
            for (int c = 0; c < 8; ++c) begin
                blocks_in[0][r][c] = r+c + 5;
                blocks_in[1][r][c] = r+c + 5;
                blocks_in[2][r][c] = r+c + 5;
                blocks_in[3][r][c] = r+c + 5;
            end
        end
        @(negedge clk);
        wr_en = 0;

        @(negedge clk);
        @(negedge clk);

        @(negedge clk);
        wr_en = 1;
        ch = 2;
        for (int r = 0; r < 8; ++r) begin
            for (int c = 0; c < 8; ++c) begin
                blocks_in[0][r][c] = r+c + 6;
                blocks_in[1][r][c] = r+c + 6;
                blocks_in[2][r][c] = r+c + 6;
                blocks_in[3][r][c] = r+c + 6;
            end
        end
        @(negedge clk);
        wr_en = 0;

        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        $finish;
    end

    always #(`PERIOD/2) clk = ~clk;


endmodule
