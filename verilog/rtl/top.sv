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
    output logic signed [11:0] blockOut_QuantTest [7:0][7:0],
    output logic valid_out_QuantTest,
    output logic [$clog2(`CH+1)-1:0] ch_QuantTest
    //Final: output [7:0] rbgOut [7:0][7:0][`CH-1:0] 
);

//Internal connections
logic signed [11:0] blockOut_Entropy [7:0][7:0];
logic valid_out_Entropy;
logic [$clog2(`CH+1)-1:0] ch_Entropy;
logic signed [11:0] blockOut_Quant [7:0][7:0];
logic valid_out_Quant;
logic [$clog2(`CH+1)-1:0] ch_Quant;

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

//Temporary
assign blockOut_QuantTest = blockOut_Quant;
assign valid_out_QuantTest = valid_out_Quant;
assign ch_QuantTest = ch_Quant;

endmodule