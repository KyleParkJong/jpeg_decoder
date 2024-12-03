`include "sys_defs.svh"

module input_buffer (
    input logic clk, rst,
    input logic [`IN_BUS_WIDTH-1:0] data_in,
    input logic [3:0] huff_size, vli_size,
    input logic wr_en, rd_en

    output logic [15:0] top_bits,
    output logic [10:0] vli_symbol,
    output logic request, valid_out
);

logic [`IN_BUFF_SIZE-1:0] buffer, buffer_n;
logic [$clog2(`IN_BUFF_SIZE+1)-1:0] head, head_n, tail, tail_n, count, count_n;

assign request = count < (`IN_BUFF_SIZE - `IN_BUS_WIDTH);
assign valid_out = count > 0;

always_comb begin
    // Writing buffer
    if (wr_en) begin
        for (int i = 0; i < `IN_BUS_WIDTH; ++i) begin
            buffer_n[tail+i % `IN_BUFF_SIZE] = data_in[i];
        end
        tail_n = (tail + `IN_BUS_WIDTH) % `IN_BUFF_SIZE;
        count_n += `IN_BUS_WIDTH;
    end
    
    // Reading buffer
    if (rd_en) begin
        head_n = (head + huff_size + vli_size) % `IN_BUFF_SIZE;
        count_n -= (huff_size + vli_size);
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        buffer <= `IN_BUFF_SIZE'b0;
        head = $clog2(`IN_BUFF_SIZE+1)'b0;
        tail = $clog2(`IN_BUFF_SIZE+1)'b0;
        count = $clog2(`IN_BUFF_SIZE+1)'b0;
    end else begin
        buffer <= buffer_n;
        head <= head_n;
        tail <= tail_n;
        count <= count_n;
    end
end

endmodule

