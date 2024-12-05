`include "sys_defs.svh"

module supersample_top (
    input logic clk,
    input logic rst,
    input logic valid_in,
    input logic [$clog2(`CH+1)-1:0] ch,     // 0=Y, 1=Cb, 2=Cr
    input logic signed [7:0] block_in [7:0][7:0],
    output logic signed [7:0] y_block_out [7:0][7:0],
    output logic signed [7:0] cb_block_out [7:0][7:0],
    output logic signed [7:0] cr_block_out [7:0][7:0],
    output logic [$clog2(`CH+1)-1:0] ch,
    output logic valid_out
);

logic [7:0] block [7:0][7:0];

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        for (int i = 0; i < 8; i = i + 1) begin
            for (int j = 0; j < 8; j = j + 1) begin
                block_out[i][j] <= 0; 
            end
        end
        valid_out <= 0;
    end else begin
        if (valid_in) begin
            block_out <= block;
            valid_out <= 1;
        end
    end
end

always_comb begin
    
    /* Y channel */
    if (ch == 0) begin
        for (int i = 0; i < 8; i = i + 1) begin
            for (int j = 0; j < 8; j = j + 1) begin
                block[i][j] <= block_in[i][j];
            end
        end
    end else if (ch == 1) begin  // Cb channel
        

    end
end


endmodule


module supersample_8x8 (
    input logic clk,
    input logic rst,
    input logic [$clog2(`CH+1)-1:0] ch_in,      // Cb: 2'b01, Cr: 2'b10
    input logic valid_in,
    input logic signed [7:0] block_in [7:0][7:0],       // input: 4x4 block
    output logic signed [7:0] block_out [7:0][7:0],     // output: 8x8 block
    output logic valid_out
);

    logic [7:0] block_1 [3:0][3:0];
    logic [7:0] block_2 [3:0][3:0];
    logic [7:0] block_3 [3:0][3:0];
    logic [7:0] block_4 [3:0][3:0];

    always_comb begin

        block_1[3][3] = block_in[7][7];
        block_1[3][2] = block_in[7][6];
        block_1[3][1] = block_in[7][5];
        block_1[3][0] = block_in[7][4];

        block_1[2][3] = block_in[6][7];
        block_1[2][2] = block_in[6][6];
        block_1[2][1] = block_in[6][5];
        block_1[2][0] = block_in[6][4];

        block_1[1][3] = block_in[5][7];
        block_1[1][2] = block_in[5][6];
        block_1[1][1] = block_in[5][5];
        block_1[1][0] = block_in[5][4];

        block_1[0][3] = block_in[4][7];
        block_1[0][2] = block_in[4][6];
        block_1[0][1] = block_in[4][5];
        block_1[0][0] = block_in[4][4];

    end

    supersample_4x4 

endmodule

// For Cb, Cr block
// 4x4 sub-block -> 8x8 block
module supersample_4x4 (
    input logic clk,
    input logic rst,
    input logic [$clog2(`CH+1)-1:0] ch_in,      // Cb: 2'b01, Cr: 2'b10
    input logic valid_in,
    input logic signed [7:0] block_in [3:0][3:0],       // input: 4x4 block
    output logic signed [7:0] block_out [7:0][7:0],     // output: 8x8 block
    output logic valid_out
);

logic signed [7:0] block [7:0][7:0];
logic valid;

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        for (int i = 0; i < 8; i = i + 1) begin
            for (int j = 0; j < 8; j = j + 1) begin
                block_out[i][j] <= 0;
            end
        end
        valid_out <= 0;
    end else begin
        block_out <= block;
        valid_out <= valid;
    end
end 

always_comb begin
    // Initialize block to zero by default
    for (int i = 0; i < 8; i++) begin
        for (int j = 0; j < 8; j++) begin
            block[i][j] = 0;
        end
    end
    valid = 0;

    if (valid_in && (ch_in == 2'b01 || ch_in == 2'b10)) begin
        for (int i = 0; i < 4; i++) begin
            for (int j = 0; j < 4; j++) begin
                int row_offset = 6 - (i * 2);
                int col_offset = 6 - (j * 2);

                // Assign values to corresponding block regions
                block[row_offset + 1][col_offset + 1] = block_in[3 - i][3 - j];
                block[row_offset + 1][col_offset    ] = block_in[3 - i][3 - j];
                block[row_offset    ][col_offset + 1] = block_in[3 - i][3 - j];
                block[row_offset    ][col_offset    ] = block_in[3 - i][3 - j];
            end
        end
        valid = 1;
    end
end

endmodule