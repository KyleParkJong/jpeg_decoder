`include "sys_defs.svh"

module input_buffer_tb;

    logic clk, rst;
    logic [`IN_BUS_WIDTH-1:0] data_in;
    logic [3:0] huff_size, vli_size;
    logic wr_en, rd_en;

    logic [15:0] top_bits;
    logic [10:0] vli_symbol;
    logic request, valid_out;

    task check;
        begin

            $write("=======================================================\n");
            $write("Data In: %x, Huff Size: %d, VLI Size: %d \n", data_in, 
                huff_size, vli_size,
                "Write En: %b, Read En: %b, Top Bits: %x, VLI Symbol: %x\n",
                wr_en, rd_en, top_bits, vli_symbol,
                "Request: %b, Valid Out: %b\n",request, valid_out);
            /*assert(ideal == value) else begin
                disp_fail();
                $finish;
            end
            */
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

    input_buffer dut (
        // in
        clk, rst,
        data_in,
        huff_size, 
        vli_size,
        wr_en, 
        rd_en,
        // out
        top_bits,
        vli_symbol,
        request,
        valid_out
    );

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        
        #`PERIOD
        rst = 1'b0;

        data_in = 32'hF;
        wr_en = 1'b1;
        rd_en = 1'b0;
        huff_size = 4'd2;
        vli_size = 4'd2;
        @(posedge clk) check();
        #`PERIOD
        wr_en = 1'b0;
        rd_en = 1'b1;
        @(posedge clk) check();
        #`PERIOD
        $finish;
    end

    always #(`PERIOD/2) clk = ~clk;

endmodule



