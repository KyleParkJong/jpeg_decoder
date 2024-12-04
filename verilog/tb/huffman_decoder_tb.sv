`include "sys_defs.svh"

module huffman_decoder_tb;

    logic clk, reset;
    HUFF_TABLE_ENTRY [`H-1:0] table;
    logic [15:0] code;
    logic [3:0] run;
    logic [3:0] vli_size;
    logic [3:0] code_size;
    logic valid_in, valid_out;

    huffman_decoder dut (
        // in
        table,
        code,
        valid_in,
        // out
        run,
        vli_size,
        code_size,
        valid_out
    );

    task write_symbol;
        begin
            $write("Valid: %b, Code: %x, Run: %d, VLI Size: %d, Code Size: %d\n", 
                valid, code, run, vli_size, code_size);
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
        assert(code_size == 4'h5) else $finish;
        assert(vli_size == 4'h9) else $finish;
        assert(run == 4'h6) else $finish;
        assert(valid == 1'h1) else $finish;
        code = 16'h3;
        #`PERIOD
        write_symbol();
        assert(code_size == 4'h2) else $finish;
        assert(vli_size == 4'h1) else $finish;
        assert(run == 4'h0) else $finish;
        assert(valid == 1'h1) else $finish;
        code = 16'h23;
        #`PERIOD
        write_symbol();
        assert(code_size == 4'h9) else $finish;
        assert(vli_size == 4'h4) else $finish;
        assert(run == 4'h3) else $finish;
        assert(valid == 1'h1) else $finish;
        code = 16'h69;
        #`PERIOD
        write_symbol();
        assert(valid == 1'h0);
        $write("\033[32;1mPassed\033[0m\n");
        $finish;
    end

endmodule



