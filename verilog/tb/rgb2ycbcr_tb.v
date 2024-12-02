`include "define.vh"
`timescale 1ns/1ps
module rgb2ycbcr_tb;
    reg clk;
    reg rstn;
    reg signed [`RGB_N-1:0] r, g, b;  // Input ports: signed (16,7) format
    reg vld_i;
    wire [`RGB_N-1:0] y, cb, cr;      // Output ports: unsigned (20,14) format
    wire vld_o;

    // Instantiate the module under test
    rgb2ycbcr_v2 uut (
        .clk(clk),
        .rstn(rstn),
        .r(r),
        .g(g),
        .b(b),
        .vld_i(vld_i),
        .y(y),
        .cb(cb),
        .cr(cr),
        .vld_o(vld_o)
    );

    // Clock generation
    always #5 clk = ~clk;  // 100 MHz clock

    // File handles
    integer file_r, file_g, file_b;
    integer file_y, file_cb, file_cr;
    integer status_r, status_g, status_b;

    initial begin
        // Initialize signals
        clk = 0;
        rstn = 0;
        vld_i = 0;
        r = 0;
        g = 0;
        b = 0;

        // Reset the module
        #10 rstn = 1;

        // Open R, G, B text files
        file_r = $fopen("R_values.txt", "r");
        file_g = $fopen("G_values.txt", "r");
        file_b = $fopen("B_values.txt", "r");

        // Open Y, Cb, Cr output files
        file_y = $fopen("Y_values.txt", "w");
        file_cb = $fopen("Cb_values.txt", "w");
        file_cr = $fopen("Cr_values.txt", "w");

        if (file_r == 0 || file_g == 0 || file_b == 0) begin
            $display("Error: Could not open input files.");
            $finish;
        end

        // Read values from the files and apply to inputs
        while (!$feof(file_r) && !$feof(file_g) && !$feof(file_b)) begin
            status_r = $fscanf(file_r, "%d\n", r);
            status_g = $fscanf(file_g, "%d\n", g);
            status_b = $fscanf(file_b, "%d\n", b);
            
            vld_i = 1;
            #10;  // Wait for one clock cycle
            
            // Save Y, Cb, Cr values when vld_o is high
            if (vld_o) begin
                $fwrite(file_y, "%d\n", y);
                $fwrite(file_cb, "%d\n", cb);
                $fwrite(file_cr, "%d\n", cr);
            end
        end

        vld_i = 0;

        // Close files
        $fclose(file_r);
        $fclose(file_g);
        $fclose(file_b);
        $fclose(file_y);
        $fclose(file_cb);
        $fclose(file_cr);

        // Finish the simulation
        #50;
        $finish;
    end
endmodule