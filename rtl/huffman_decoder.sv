`include "sys_defs.svh"

module huffman_decoder(
    input  HUFF_TABLE_ENTRY [`H-1:0] table,
    input  logic [15:0]     code,
    output logic [3:0]      run,
    output logic [3:0]      size,
    output logic            valid
);

logic signed [$clog2(`H)+1:0] index;
logic [`H-1:0][15:0] mask;

always_comb begin
    index = -1;
    mask = 0;
    for (int i = 0; i < `H; ++i) begin
        for (int j = 0; j < table[i].size; ++j) begin
            mask[i][j] = 1'b1;
        end
        if (table[i].code == (code & mask[i])) begin
            index = i;
        end
    end
    run   = table[index].symbol[7:4];
    size  = table[index].symbol[3:0];
    valid = index >= 0;
end

endmodule

