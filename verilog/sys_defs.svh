`ifndef __SYS_DEFS_SVH__
`define __SYS_DEFS_SVH__

`timescale 1ns/100ps

`define Q  8        // Precision (bits)
`define H  3        // Size of Huffman table (number of entries)
`define IN 32       // Int to decoder (bits per cycle)
`define PERIOD 20   // Clock period (ns)

typedef struct packed {
    logic [3:0]  size;
    logic [15:0] code;
    logic [7:0]  symbol;
} HUFF_TABLE_ENTRY;

`endif
