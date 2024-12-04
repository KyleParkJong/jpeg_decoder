`include "sys_defs.svh"

module entropy_decoding (
    input logic clk, rst,
    input logic [`IN_BUS_WIDTH-1:0] data_in, // from input mem
    input logic valid_in, // from input mem
    input HUFF_TABLE_ENTRY [`H-1:0] tab, // from huff table (loaded in testbench)

    output logic signed [11:0] block [7:0][7:0], // to qunat/IDCT
    output logic valid_out, // to quant/IDCT
    output logic request // to input mem
);

logic [3:0] huff_size, vli_size;
logic [15:0] top_bits;
logic [10:0] vli_symbol;
logic ibuff_valid;
logic signed [11:0] vli_value;
logic [3:0] run;
logic huff_valid;
logic signed [`BLOCK_BUFF_SIZE-1:0][11:0] line;

input_buffer ibuff (
    // in
    clk, rst,
    data_in, // from input mem
    huff_size, // from huff
    vli_size, // from huff
    valid_in, // from input mem
    1'b1, // rd_en from ?
    // out
    top_bits, // to huff
    vli_symbol, // to VLI
    request, // to input mem
    ibuff_valid // to ?
);

vli_decoder vli (
    // in
    vli_size, // from huff
    vli_symbol, // from ibuff
    // out
    vli_value // to pixel buff
);

huffman_decoder huff (
    // in
    tab, // from huff tab
    top_bits, // from ibuff
    ibuff_valid, // from ibuff
    // out
    run, // to pixel buff
    vli_size, // to vli and ibuff
    huff_size, // to ibuff
    huff_valid // to pixel buff
);

block_buffer block_buff (
    // in
    clk, rst,
    vli_value, 
    run, huff_valid,
    // out
    line, 
    valid_out
);

unzigzag unzig (
    // in
    line,
    // out
    block
);

endmodule



