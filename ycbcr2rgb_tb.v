`include "define.vh"
`timescale 1ns/1ps
module ycbcr2rgb_tb;
    reg clk;
    reg rstn;
    reg signed [7:0] y, cb, cr;  // Input ports: signed (16,7) format
    reg vld_i;
    wire [7:0] r, g, b;      // Output ports: unsigned (20,14) format
    wire vld_o;

    // Instantiate the module under test
    ycbcr2rgb uut (
        .clk(clk),
        .rstn(rstn),
        .y(y),
        .cb(cb),
        .cr(cr),
        .vld_i(vld_i),
        .r(r),
        .g(g),
        .b(b),
        .vld_o(vld_o)
    );

    // Clock generation
    always #5 clk = ~clk;  // 100 MHz clock

    // File handles
    integer file_y, file_cb, file_cr;
    integer file_r, file_g, file_b;
    integer status_y, status_cb, status_cr;

    initial begin
        // Initialize signals
        clk = 0;
        rstn = 0;
        vld_i = 0;
        y = 0;
        cb = 0;
        cr = 0;

        // Reset the module
        #10 rstn = 1;

        // Open R, G, B text files
        file_y  = $fopen("Y_in.txt", "r");
        file_cb = $fopen("Cb_in.txt", "r");
        file_cr = $fopen("Cr_in.txt", "r");

        // Open Y, Cb, Cr output files
        file_r = $fopen("R_out.txt", "w");
        file_g = $fopen("G_out.txt", "w");
        file_b = $fopen("B_out.txt", "w");

        if (file_y == 0 || file_cb == 0 || file_cr == 0) begin
            $display("Error: Could not open input files.");
            $finish;
        end

        // Read values from the files and apply to inputs
        while (!$feof(file_y) && !$feof(file_cb) && !$feof(file_cr)) begin
            status_y = $fscanf(file_y, "%d\n", y);
            status_cb = $fscanf(file_cb, "%d\n", cb);
            status_cr = $fscanf(file_cr, "%d\n", cr);
            
            vld_i = 1;
            #10;  // Wait for one clock cycle
            
            // Save Y, Cb, Cr values when vld_o is high
            if (vld_o) begin
                $fwrite(file_r, "%d\n", r);
                $fwrite(file_g, "%d\n", g);
                $fwrite(file_b, "%d\n", b);
            end
        end

        vld_i = 0;

        // Close files
        $fclose(file_y);
        $fclose(file_cb);
        $fclose(file_cr);
        $fclose(file_r);
        $fclose(file_g);
        $fclose(file_b);

        // Finish the simulation
        #50;
        $finish;
    end
endmodule