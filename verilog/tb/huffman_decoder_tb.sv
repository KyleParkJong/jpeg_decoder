`include "sys_defs.svh"

module huffman_decoder_tb;

    logic clk, reset;
    HUFF_TABLE_ENTRY [`H-1:0] table;
    logic [15:0] code;
    logic [3:0] run;
    logic [3:0] size;
    logic valid;

    huffman_decoder dut (
        // in
        table,
        code,
        // out
        run,
        size,
        valid
    );

    task write_symbol;
        begin
            $write("Valid: %b, Code: %x, Run: %d, Size: %d\n", 
                valid, code, run, size);
        end
    endtask

    initial begin

        table[0].size = 4'h5;
        table[0].code = 16'h15;
        table[0].symbol = 8'h69;

        table[1].size = 4'h2;
        table[1].code = 16'h3;
        table[1].symbol = 8'h01;

        table[2].size = 4'h9;
        table[2].code = 16'h23;
        table[2].symbol = 8'h34;

        code = 16'h15;
        #`PERIOD
        write_symbol();
        code = 16'h3;
        #`PERIOD
        write_symbol();
        code = 16'h23;
        #`PERIOD
        write_symbol();
        code = 16'h69;
        #`PERIOD
        write_symbol();
        
        $finish;
    end

endmodule



