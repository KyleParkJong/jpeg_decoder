module top_tb;
    //Inputs
    logic clk, rst;
    logic [`IN_BUS_WIDTH-1:0] data_in;
    logic valid_in;
    HUFF_PACKET hp;
    QUANT_PACKET qp;
    //Outputs
    logic request;
    logic unsigned [7:0] r [7:0][7:0];
    logic unsigned [7:0] g [7:0][7:0];
    logic unsigned [7:0] b [7:0][7:0];
    logic valid_out_Color;

    //Set which image to load
    string imgname = "smallCat";

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
        .r,
        .g,
        .b,
        .valid_out_Color
    );

    import displays::*;

    integer finput, line_len, index;
    integer row;
    integer blocksProccessed = 0;
    integer R_chan, G_chan, B_chan;
    real height, width; 
    integer blocksTall, blocksWide;

    always #(`PERIOD/2) clk = ~clk;

    initial begin
        //Load Header info
        finput = $fopen({"../python/",imgname,"/HeaderInfo.txt"}, "r");
        line_len = $fscanf(finput, "%d,%d\n",height,width);
        blocksWide = $ceil(width/16.0)*2;
        blocksTall = $ceil(height/16.0)*2;
        $display(blocksWide);
        $display(blocksTall);

        //Load quantization tables into quant packet
        qp.map[0] = 0;
        qp.map[1] = 1;
        qp.map[2] = 1;

        finput = $fopen({"../python/",imgname,"/QuantTable0.txt"}, "r");
        row = 0;
        while(!$feof(finput)) begin
            line_len = $fscanf(finput, "%d, %d, %d, %d, %d, %d, %d, %d\n",
            qp.tabs[0].tab[row][0],qp.tabs[0].tab[row][1],
            qp.tabs[0].tab[row][2],qp.tabs[0].tab[row][3],
            qp.tabs[0].tab[row][4],qp.tabs[0].tab[row][5],
            qp.tabs[0].tab[row][6],qp.tabs[0].tab[row][7]);
            row = row + 1;
        end

        finput = $fopen({"../python/",imgname,"/QuantTable1.txt"}, "r");
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

        finput = $fopen({"../python/",imgname,"/DC_HuffTable_Index0Flipped.txt"}, "r");
        line_len = -1;
        hp.tabs[0].dc_tab = 0;
        index = 0;
        $fscanf(finput, "%d\n", hp.tabs[0].dc_size);
        while(!$feof(finput)) begin
           line_len = $fscanf(finput, "%b %d %d\n", hp.tabs[0].dc_tab[index].code,
                    hp.tabs[0].dc_tab[index].symbol, hp.tabs[0].dc_tab[index].size);
            index = index + 1;
        end

        finput = $fopen({"../python/",imgname,"/DC_HuffTable_Index1Flipped.txt"}, "r");
        line_len = -1;
        hp.tabs[1].dc_tab = 0;
        index = 0;
        $fscanf(finput, "%d\n", hp.tabs[1].dc_size);
        while(!$feof(finput)) begin
           line_len = $fscanf(finput, "%b %d %d\n", hp.tabs[1].dc_tab[index].code,
                    hp.tabs[1].dc_tab[index].symbol, hp.tabs[1].dc_tab[index].size);
            index = index + 1;
        end

        finput = $fopen({"../python/",imgname,"/AC_HuffTable_Index0Flipped.txt"}, "r");
        line_len = -1;
        hp.tabs[0].ac_tab = 0;
        index = 0;
        $fscanf(finput, "%d\n",hp.tabs[0].ac_size);
        while(!$feof(finput)) begin
           line_len = $fscanf(finput, "%b %d %d\n", hp.tabs[0].ac_tab[index].code,
                    hp.tabs[0].ac_tab[index].symbol, hp.tabs[0].ac_tab[index].size);
            index = index + 1;
        end

        finput = $fopen({"../python/",imgname,"/AC_HuffTable_Index1Flipped.txt"}, "r");
        line_len = -1;
        hp.tabs[1].ac_tab = 0;
        index = 0;
        $fscanf(finput, "%d\n",hp.tabs[1].ac_size);
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

        R_chan = $fopen({"out/",imgname,"_R.txt"}, "w");
        G_chan = $fopen({"out/",imgname,"_G.txt"}, "w");
        B_chan = $fopen({"out/",imgname,"_B.txt"}, "w");

        finput = $fopen({"../python/",imgname,"/bitStreamFlipped.txt"}, "r");
        line_len = -1;
        while(!$feof(finput)) begin
            @(negedge clk);
            if (request) begin
                line_len = $fscanf(finput, "%b\n", data_in);
                valid_in = 1;
            end else begin
                valid_in = 0;
            end
            if (valid_out_Color) begin
                write_block;
                blocksProccessed +=1;
            end
        end

        while (blocksProccessed < blocksTall*blocksWide) begin
            @(negedge clk);
            if (request) begin
                valid_in = 1;
            end else begin
                valid_in = 0;
            end
            if (valid_out_Color) begin
                write_block;
                blocksProccessed += 1;
            end
        end

        $fclose(R_chan);
        $fclose(G_chan);
        $fclose(B_chan);

        $finish; 
    end

    task write_block;
        for (int i = 0; i < 8; i++) begin
            for (int j = 0; j < 8; j++) begin
                $fwrite(R_chan, "%d ", r[i][j]);
            end
            $fwrite(R_chan, "\n");
        end

        for (int i = 0; i < 8; i++) begin
            for (int j = 0; j < 8; j++) begin
                $fwrite(G_chan, "%d ", g[i][j]);
            end
            $fwrite(G_chan, "\n");
        end

        for (int i = 0; i < 8; i++) begin
            for (int j = 0; j < 8; j++) begin
                $fwrite(B_chan, "%d ", b[i][j]);
            end
            $fwrite(B_chan, "\n");
        end
    endtask


endmodule