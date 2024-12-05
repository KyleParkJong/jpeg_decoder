module loeffler2d_idct (

    input  logic clk,
    input  logic rst,
    input  logic valid_in,
    input  logic signed [11:0] idct_in  [7:0][7:0],
    output logic signed [7:0]  idct_out [7:0][7:0],
    output logic valid_out

);

logic clk_array                     [7:0];
logic rst_array                     [7:0];
logic valid_in_array                [7:0];
logic first_valid_out_array         [7:0];
logic [7:0] second_valid_out_array;

logic signed [63:0] idct_in_fixed_point   [7:0][7:0];
logic signed [63:0] transposed_block      [7:0][7:0];
logic signed [63:0] first_idct_out_array  [7:0][7:0];
logic signed [63:0] second_idct_out_array [7:0][7:0];
logic signed [7:0]  idct_out_normalized   [7:0][7:0];

always_comb begin
    for(int i = 0; i < 8; i++) begin
        clk_array[i]      = clk;
        rst_array[i]      = rst;
        valid_in_array[i] = valid_in;
    end
end

// Sign extend input and convert to fixed point notation (38,14)
always_comb begin
    for(int row = 0; row < 8; row++) begin
        for(int col = 0; col < 8; col++) begin
            idct_in_fixed_point[row][col] = idct_in[row][col] << 14;
        end
    end
end

loeffler_idct row0_idct (
    .clk(clk),
    .rst(rst),
    .valid_in(valid_in),
    .idct_in(idct_in_fixed_point[0]),
    .idct_out(first_idct_out_array[0]),
    .valid_out(first_valid_out_array[0])
);

loeffler_idct row1_idct (
    .clk(clk),
    .rst(rst),
    .valid_in(valid_in),
    .idct_in(idct_in_fixed_point[1]),
    .idct_out(first_idct_out_array[1]),
    .valid_out(first_valid_out_array[1])
);

loeffler_idct row2_idct (
    .clk(clk),
    .rst(rst),
    .valid_in(valid_in),
    .idct_in(idct_in_fixed_point[2]),
    .idct_out(first_idct_out_array[2]),
    .valid_out(first_valid_out_array[2])
);

loeffler_idct row3_idct (
    .clk(clk),
    .rst(rst),
    .valid_in(valid_in),
    .idct_in(idct_in_fixed_point[3]),
    .idct_out(first_idct_out_array[3]),
    .valid_out(first_valid_out_array[3])
);

loeffler_idct row4_idct (
    .clk(clk),
    .rst(rst),
    .valid_in(valid_in),
    .idct_in(idct_in_fixed_point[4]),
    .idct_out(first_idct_out_array[4]),
    .valid_out(first_valid_out_array[4])
);

loeffler_idct row5_idct (
    .clk(clk),
    .rst(rst),
    .valid_in(valid_in),
    .idct_in(idct_in_fixed_point[5]),
    .idct_out(first_idct_out_array[5]),
    .valid_out(first_valid_out_array[5])
);

loeffler_idct row6_idct (
    .clk(clk),
    .rst(rst),
    .valid_in(valid_in),
    .idct_in(idct_in_fixed_point[6]),
    .idct_out(first_idct_out_array[6]),
    .valid_out(first_valid_out_array[6])
);

loeffler_idct row7_idct (
    .clk(clk),
    .rst(rst),
    .valid_in(valid_in),
    .idct_in(idct_in_fixed_point[7]),
    .idct_out(first_idct_out_array[7]),
    .valid_out(first_valid_out_array[7])
);

// Transpose output of first IDCT
always_comb begin
    for(int row = 0; row < 8; row++) begin
        for(int col = 0; col < 8; col++) begin
            transposed_block[row][col] = first_idct_out_array[col][row];
        end
    end
end

loeffler_idct col0_idct (
    .clk(clk),
    .rst(rst),
    .valid_in(first_valid_out_array[0]),
    .idct_in(transposed_block[0]),
    .idct_out(second_idct_out_array[0]),
    .valid_out(second_valid_out_array[0])
);

loeffler_idct col1_idct (
    .clk(clk),
    .rst(rst),
    .valid_in(first_valid_out_array[1]),
    .idct_in(transposed_block[1]),
    .idct_out(second_idct_out_array[1]),
    .valid_out(second_valid_out_array[1])
);

loeffler_idct col2_idct (
    .clk(clk),
    .rst(rst),
    .valid_in(first_valid_out_array[2]),
    .idct_in(transposed_block[2]),
    .idct_out(second_idct_out_array[2]),
    .valid_out(second_valid_out_array[2])
);

loeffler_idct col3_idct (
    .clk(clk),
    .rst(rst),
    .valid_in(first_valid_out_array[3]),
    .idct_in(transposed_block[3]),
    .idct_out(second_idct_out_array[3]),
    .valid_out(second_valid_out_array[3])
);

loeffler_idct col4_idct (
    .clk(clk),
    .rst(rst),
    .valid_in(first_valid_out_array[4]),
    .idct_in(transposed_block[4]),
    .idct_out(second_idct_out_array[4]),
    .valid_out(second_valid_out_array[4])
);

loeffler_idct col5_idct (
    .clk(clk),
    .rst(rst),
    .valid_in(first_valid_out_array[5]),
    .idct_in(transposed_block[5]),
    .idct_out(second_idct_out_array[5]),
    .valid_out(second_valid_out_array[5])
);

loeffler_idct col6_idct (
    .clk(clk),
    .rst(rst),
    .valid_in(first_valid_out_array[6]),
    .idct_in(transposed_block[6]),
    .idct_out(second_idct_out_array[6]),
    .valid_out(second_valid_out_array[6])
);

loeffler_idct col7_idct (
    .clk(clk),
    .rst(rst),
    .valid_in(first_valid_out_array[7]),
    .idct_in(transposed_block[7]),
    .idct_out(second_idct_out_array[7]),
    .valid_out(second_valid_out_array[7])
);

// Instantiate 8 1D IDCTs in parallel
/*loeffler_idct column_idct_array [7:0]
(
    .clk(clk_array),
    .rst(rst_array),
    .valid_in(first_valid_out_array),
    .idct_in({
                first_idct_out_array[7],
                first_idct_out_array[6],
                first_idct_out_array[5],
                first_idct_out_array[4],
                first_idct_out_array[3],
                first_idct_out_array[2],
                first_idct_out_array[1],
                first_idct_out_array[0]
            }),
    .idct_out({
                second_idct_out_array[7],
                second_idct_out_array[6],
                second_idct_out_array[5],
                second_idct_out_array[4],
                second_idct_out_array[3],
                second_idct_out_array[2],
                second_idct_out_array[1],
                second_idct_out_array[0]
            }),
    .valid_out(second_valid_out_array)
);*/

// Truncate for final output
always_comb begin
    for(int row = 0; row < 8; row++) begin
        for(int col = 0; col < 8; col++) begin
            idct_out[row][col] = second_idct_out_array[row][col] >> 14;
        end
    end
end

assign valid_out = &second_valid_out_array;

endmodule: loeffler2d_idct