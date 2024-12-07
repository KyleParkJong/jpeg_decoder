`include "sys_defs.svh"

module input_system_tb;

    logic clk, rst;
    logic [`IN_BUS_WIDTH-1:0] data_in;
    logic [3:0] huff_size, vli_size;
    logic wr_en, rd_en;
    logic [15:0] top_bits;
    logic [10:0] vli_symbol;
    logic request, ibuff_valid;
    logic signed [11:0] vli_value;
    HUFF_TABLE_ENTRY [`H-1:0] tab;
    logic [3:0] run;
    logic huff_valid;

    logic fail = 0;

    input_buffer ibuff (
        // in
        clk, rst,
        data_in, // from input mem
        huff_size, // from huff
        vli_size, // from huff
        wr_en, // from input mem
        rd_en, // from ?
        // out
        top_bits, // to huff
        vli_symbol, // to VLI
        request, // to input mem
        ibuff_valid // to ?
    );

    vli_decoder vli (
        // in
        vli_size, // from huff
        vli_symbol, // from ibuff
        // out
        vli_value // to pixel buff
    );

    huffman_decoder huff (
        // in
        tab, // from huff tab
        top_bits, // from ibuff
        ibuff_valid, // from ibuff
        // out
        run, // to pixel buff
        vli_size, // to vli and ibuff
        huff_size, // to ibuff
        huff_valid // to ?
    );

    initial begin
        // huff table def 
        tab[0].size = 4'h5;
        tab[0].code = 16'h15;
        tab[0].symbol = 8'h69;
        tab[1].size = 4'h2;
        tab[1].code = 16'h3;
        tab[1].symbol = 8'h01;
        tab[2].size = 4'h9;
        tab[2].code = 16'h23;
        tab[2].symbol = 8'hF0;


        // initial values
        clk = 0;
        rst = 1;
        wr_en = 0;
        rd_en = 0;
        #`PERIOD
        @(posedge clk);
        @(negedge clk);
        rst = 0;
        // start of (6,9)(-511); (15,0)(); (0,1)(-1); (6, 9)(511); 
        data_in = 32'b0_10101_000100011_0_11_111111111_10101; 
        wr_en = 1;
        @(posedge clk);
        wr_en = 0;
        rd_en = 1;
        @(posedge clk);
        // (6,9)(-511)
        assert(vli_value == 12'd511) else $finish;
        assert(run == 4'd6) else $finish;
        assert(huff_valid == 1) else $finish;
        @(posedge clk);
        // (0,1)(-1)
        assert(vli_value == -12'sd1) else $finish;
        assert(run == 4'b0) else $finish;
        assert(huff_valid == 1) else $finish;
        // (not enough); (0,1)(-1); (6,9)(511); end of (6,9)(-511);
        data_in = 32'b0100011_0_11_111111111_10101_00000000;
        @(posedge clk);
        // (15,0)();
        assert(vli_value == 12'd0) else $finish;
        assert(run == 4'd15) else $finish;
        assert(huff_valid == 1) else $finish;
        @(negedge clk);
        wr_en = 1;
        @(posedge clk);
        // (6,9)(-511);
        assert(vli_value == -12'sd511) else $finish;
        assert(run == 4'd6) else $finish;
        assert(huff_valid == 1) else $finish;
        @(negedge clk);
        wr_en = 0;
        @(posedge clk);
        // (6,9)(511);
        assert(vli_value == 12'd511) else disp_fail;
        assert(run == 4'd6) else disp_fail;
        assert(huff_valid == 1) else disp_fail;
        @(posedge clk);
        // (0,1)(-1);
        assert(vli_value == -12'sd1) else disp_fail;
        assert(run == 4'd0) else disp_fail;
        assert(huff_valid == 1) else disp_fail;
        disp_pass;
        $finish; 
    end

    always #(`PERIOD/2) clk = ~clk;

    task disp_pass;
        begin
           if (!fail) $write("\033[32;1mPass\033[0;22m\n"); 
        end
    endtask

    task disp_fail;
        begin
           $write("\033[31;1mFail\033[0;22m\n"); 
           fail = 1;
        end
    endtask
endmodule
