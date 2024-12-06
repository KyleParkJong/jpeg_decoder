module deQuant_tb;
    //Inputs
    logic clk, rst;
    logic [`IN_BUS_WIDTH-1:0] data_in;
    logic valid_in;
    HUFF_PACKET hp;
    QUANT_PACKET qp;
    //Outputs
    logic request;
    //Temporary
    logic unsigned [7:0] idct_outTest [7:0][7:0];
    logic [$clog2(`CH+1)-1:0] ch_IdctTest;
    logic valid_out_IdctTest;

    //Instantiate Top module
    top dut (
        //Inputs
        .clk, .rst,
        .data_in,
        .valid_in,
        .hp,
        .qp,
        //Outputs
        .request,
        //Temporary
        .idct_outTest,
        .valid_out_IdctTest,
        .ch_IdctTest
    );

    import displays::*;

    integer finput, line_len, index;
    integer row;
    integer blocksProccessed = 0;

    always #(`PERIOD/2) clk = ~clk;

    initial begin
        //Load quantization tables into quant packet
        qp.map[0] = 0;
        qp.map[1] = 1;
        qp.map[2] = 1;

        finput = $fopen("../python/tiny/QuantTable0.txt", "r");
        row = 0;
        while(!$feof(finput)) begin
            line_len = $fscanf(finput, "%d, %d, %d, %d, %d, %d, %d, %d\n",
            qp.tabs[0].tab[row][0],qp.tabs[0].tab[row][1],
            qp.tabs[0].tab[row][2],qp.tabs[0].tab[row][3],
            qp.tabs[0].tab[row][4],qp.tabs[0].tab[row][5],
            qp.tabs[0].tab[row][6],qp.tabs[0].tab[row][7]);
            row = row + 1;
        end

        finput = $fopen("../python/tiny/QuantTable1.txt", "r");
        row = 0;
        while(!$feof(finput)) begin
            line_len = $fscanf(finput, "%d, %d, %d, %d, %d, %d, %d, %d\n",
            qp.tabs[1].tab[row][0],qp.tabs[1].tab[row][1],
            qp.tabs[1].tab[row][2],qp.tabs[1].tab[row][3],
            qp.tabs[1].tab[row][4],qp.tabs[1].tab[row][5],
            qp.tabs[1].tab[row][6],qp.tabs[1].tab[row][7]);
            row = row + 1;
        end

        //Load huffman tables into huff packet
        hp.map[0] = 0;
        hp.map[1] = 1;
        hp.map[2] = 1;

        finput = $fopen("../python/tiny/DC_HuffTable_Index0Flipped.txt", "r");
        line_len = -1;
        hp.tabs[0].dc_tab = 0;
        hp.tabs[0].dc_size = 12;
        index = 0;
        while(!$feof(finput)) begin
           line_len = $fscanf(finput, "%b %d %d\n", hp.tabs[0].dc_tab[index].code,
                    hp.tabs[0].dc_tab[index].symbol, hp.tabs[0].dc_tab[index].size);
            index = index + 1;
        end

        finput = $fopen("../python/tiny/DC_HuffTable_Index1Flipped.txt", "r");
        line_len = -1;
        hp.tabs[1].dc_tab = 0;
        hp.tabs[1].dc_size = 12;
        index = 0;
        while(!$feof(finput)) begin
           line_len = $fscanf(finput, "%b %d %d\n", hp.tabs[1].dc_tab[index].code,
                    hp.tabs[1].dc_tab[index].symbol, hp.tabs[1].dc_tab[index].size);
            index = index + 1;
        end

        finput = $fopen("../python/tiny/AC_HuffTable_Index0Flipped.txt", "r");
        line_len = -1;
        hp.tabs[0].ac_tab = 0;
        hp.tabs[0].ac_size= 162;
        index = 0;
        while(!$feof(finput)) begin
           line_len = $fscanf(finput, "%b %d %d\n", hp.tabs[0].ac_tab[index].code,
                    hp.tabs[0].ac_tab[index].symbol, hp.tabs[0].ac_tab[index].size);
            index = index + 1;
        end

        finput = $fopen("../python/tiny/AC_HuffTable_Index1Flipped.txt", "r");
        line_len = -1;
        hp.tabs[1].ac_tab = 0;
        hp.tabs[1].ac_size = 162;
        index = 0;
        while(!$feof(finput)) begin
           line_len = $fscanf(finput, "%b %d %d\n", hp.tabs[1].ac_tab[index].code,
                    hp.tabs[1].ac_tab[index].symbol, hp.tabs[1].ac_tab[index].size);
            index = index + 1;
        end

        // initial values
        clk = 0;
        rst = 1;
        valid_in = 0;
        data_in = 0;
        @(posedge clk);
        @(posedge clk);
        rst = 0;

        finput = $fopen("../python/tiny/bitStreamFlipped.txt", "r");
        line_len = -1;
        while(!$feof(finput)) begin
            @(negedge clk);
            if (request) begin
                line_len = $fscanf(finput, "%b\n", data_in);
                valid_in = 1;
            end else begin
                valid_in = 0;
            end
            if (valid_out_IdctTest) begin
                disp_block;
                blocksProccessed +=1;
            end
        end
        @(negedge clk);
        valid_in = 0;

        while (blocksProccessed < 6) begin
            @(negedge clk);
            if (valid_out_IdctTest) begin
                disp_block;
                blocksProccessed += 1;
            end
        end

        $finish; 
    end

    task disp_block;
        $write("Output Block: ");
        $write("Ch: %d\n", ch_IdctTest);
        for (int r = 0; r < 8; ++r) begin
            for (int c = 0; c < 8; ++c) begin
                $write("%4d ", idct_outTest[r][c]);
            end
            $write("\n");
        end
    endtask


endmodule