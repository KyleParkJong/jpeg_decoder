`include "sys_defs.svh"

module deQuant_tb;
    logic signed [11:0] blockIn [7:0][7:0]; // from entropy decoder
    logic valid_in; // from entropy decoder
    logic [$clog2(`CH+1)-1:0] ch; //channel of the block from the entropy decoder (y,cb,cr)
    QUANT_PACKET quant_packet; // from quant table (loaded in testbench)

    logic signed [11:0] blockOut [7:0][7:0]; // to quant/IDCT
    logic valid_out; // to quant/IDCT
    logic [$clog2(`CH+1)-1:0] chOut; // To huff and dequant

    import displays::*;

    integer finput, line_len;
    integer row;

    deQuant dut (
        // in
        .blockIn, .valid_in, .ch, .quant_packet,
        // out
        .blockOut, .valid_out, .chOut
    );

	initial begin
        //Load quantization tables into quant packet
        quant_packet.map[0] = 0;
        quant_packet.map[1] = 1;
        quant_packet.map[2] = 1;

        finput = $fopen("../python/tiny/QuantTable0.txt", "r");
        row = 0;
        while(!$feof(finput)) begin
            line_len = $fscanf(finput, "%d, %d, %d, %d, %d, %d, %d, %d\n",
            quant_packet.tabs[0].tab[row][0],quant_packet.tabs[0].tab[row][1],
            quant_packet.tabs[0].tab[row][2],quant_packet.tabs[0].tab[row][3],
            quant_packet.tabs[0].tab[row][4],quant_packet.tabs[0].tab[row][5],
            quant_packet.tabs[0].tab[row][6],quant_packet.tabs[0].tab[row][7]);
            row = row + 1;
        end

        finput = $fopen("../python/tiny/QuantTable1.txt", "r");
        row = 0;
        while(!$feof(finput)) begin
            line_len = $fscanf(finput, "%d, %d, %d, %d, %d, %d, %d, %d\n",
            quant_packet.tabs[1].tab[row][0],quant_packet.tabs[1].tab[row][1],
            quant_packet.tabs[1].tab[row][2],quant_packet.tabs[1].tab[row][3],
            quant_packet.tabs[1].tab[row][4],quant_packet.tabs[1].tab[row][5],
            quant_packet.tabs[1].tab[row][6],quant_packet.tabs[1].tab[row][7]);
            row = row + 1;
        end

        // initial values
        for (int i = 0; i < 8; ++i) begin
            for (int j = 0; j < 8; ++j) begin
                blockIn[i][j] = i+j;
            end
        end
        disp_blockIn;
        valid_in = 1;
        //Try each channel
        ch = 0;
        #`PERIOD;
        disp_blockOut;
        ch = 1;
        #`PERIOD;
        disp_blockOut;
        ch = 2;
        valid_in = 0;
        #`PERIOD;
        disp_blockOut;

        $finish; 
    end

    task disp_blockOut;
        $write("Output Block\n");
        for (int r = 0; r < 8; ++r) begin
            for (int c = 0; c < 8; ++c) begin
                $write("%4d ", blockOut[r][c]);
            end
            $write("\n");
        end
    endtask

    task disp_blockIn;
        $write("Input Block\n");
        for (int r = 0; r < 8; ++r) begin
            for (int c = 0; c < 8; ++c) begin
                $write("%4d ", blockIn[r][c]);
            end
            $write("\n");
        end
    endtask

endmodule
