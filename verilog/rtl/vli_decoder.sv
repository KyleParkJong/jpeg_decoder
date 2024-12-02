`include "sys_defs.svh"

module vli_decoder (
    input logic [3:0] size,
    input logic [10:0] symbol,
    output logic signed [11:0] value
);

always_comb begin
    if (size == 0) begin
        value = 0;
    end else if (!symbol[size-1]) begin
        case (size)
            4'd1: value = {{11{1'b1}}, 1'(symbol+1)};
            4'd2: value = {{10{1'b1}}, 2'(symbol+1)};
            4'd3: value = {{9{1'b1}}, 3'(symbol+1)};
            4'd4: value = {{8{1'b1}}, 4'(symbol+1)};
            4'd5: value = {{7{1'b1}}, 5'(symbol+1)};
            4'd6: value = {{6{1'b1}}, 6'(symbol+1)};
            4'd7: value = {{5{1'b1}}, 7'(symbol+1)};
            4'd8: value = {{4{1'b1}}, 8'(symbol+1)};
            4'd9: value = {{3{1'b1}}, 9'(symbol+1)};
            4'd10: value = {{2{1'b1}}, 10'(symbol+1)};
            4'd11: value = {1'b1, 11'(symbol+1)};
            default: value = 12'b0;
        endcase
    end else begin
        value = symbol;
    end
end

endmodule
