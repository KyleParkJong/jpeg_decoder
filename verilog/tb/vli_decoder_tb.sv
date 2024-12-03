`include "sys_defs.svh"

module vli_decoder_tb;

    logic clk, reset;
    logic [3:0] size;
    logic [10:0] symbol;
    logic signed [11:0] value, ideal;

    vli_decoder dut (
        // inputs
        size, symbol,
        // outputs
        value
    );

    task check;
        begin
            $write("Size: %d, Symbol: %x, Value: %d, Ideal: %d\n",
                size, symbol, value, ideal);
            assert(ideal == value) else begin
                disp_fail();
                $finish;
            end
        end
    endtask

    task disp_pass;
        begin
            $write("\033[32;1mPass\033[0;22m\n");
        end
    endtask

    task disp_fail;
        begin
            $write("\033[31;1mFail\033[0;22m\n");
        end
    endtask
            
    initial begin
        clk = 0;
        reset = 0;

        size = 4'd3;
        symbol = 3'b111;
        ideal = 12'd7;
        #`PERIOD
        check(); 

        size = 4'd0;
        ideal = 12'd0;
        #`PERIOD
        check();

        size = 4'd1;
        symbol = 1'b1;
        ideal = 12'd1;
        #`PERIOD
        check();

        size = 4'd1;
        symbol = 1'b0;
        ideal = -12'sd1;
        #`PERIOD
        check();

        size = 4'd10;
        symbol = 10'd0;
        ideal = -12'sd1023;
        #`PERIOD
        check();

        size = 4'd11;
        symbol = 11'd0;
        ideal = -12'sd2047;
        #`PERIOD
        check();

        /*
        // Robustness of size-symbol mismatch (doesn't work for positive
        // symbols
        size = 4'd3;
        symbol = 5'b11000;
        ideal = -12'sd7;
        #`PERIOD
        check();

        size = 4'd3;
        symbol = 5'b11111;
        ideal = 12'd7;
        #`PERIOD
        check();

        size = 4'd3;
        symbol = 5'b10101;
        ideal = 12'd5;
        #`PERIOD
        check();
        */

        disp_pass();
        $finish;
    end
        
endmodule
