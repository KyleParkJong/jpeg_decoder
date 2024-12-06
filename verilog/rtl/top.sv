`include "sys_defs.svh"

module top (
    //Inputs
    input logic clk, rst,
    input logic [`IN_BUS_WIDTH-1:0] data_in,
    input logic valid_in,
    input HUFF_PACKET hp,
    input QUANT_PACKET qp,
    //Outputs
    output logic request,
    //Temporary
    output logic unsigned [7:0] idct_outTest [7:0][7:0],
    output logic [$clog2(`CH+1)-1:0] ch_IdctTest,
    output logic valid_out_IdctTest
    //Final: output [7:0] rbgOut [7:0][7:0][`CH-1:0] 
);

//Internal connections
logic signed [11:0] blockOut_Entropy [7:0][7:0];
logic valid_out_Entropy;
logic [$clog2(`CH+1)-1:0] ch_Entropy;
logic signed [11:0] blockOut_Quant [7:0][7:0];
logic valid_out_Quant;
logic [$clog2(`CH+1)-1:0] ch_Quant;
logic unsigned [7:0] idct_out [7:0][7:0];
logic [$clog2(`CH+1)-1:0] ch_Idct;
logic valid_out_Idct;


//Block instances
entropy_decoding deHuffer(
    // in
    .clk(clk), .rst(rst),
    .data_in(data_in), .valid_in(valid_in),
    .huff_packet(hp),
    // out
    .block(blockOut_Entropy), 
    .valid_out(valid_out_Entropy),
    .request(request),
    .ch_out(ch_Entropy)
);

deQuant deQuantizer (
    // in
    .blockIn(blockOut_Entropy), .valid_in(valid_out_Entropy), .ch(ch_Entropy), .quant_packet(qp),
    // out
    .blockOut(blockOut_Quant), .valid_out(valid_out_Quant), .chOut(ch_Quant)
);

loeffler2d_idct idct(
    //in
    .clk(clk), .rst(rst), .valid_in(valid_out_Quant), .channel_in(ch_Quant), .idct_in(blockOut_Quant),
    //out
    .idct_out(idct_out), .channel_out(ch_Idct), .valid_out(valid_out_Idct)
);

//Temporary
assign idct_outTest = idct_out;
assign ch_IdctTest = ch_Idct;
assign valid_out_IdctTest = valid_out_Idct;

endmodule