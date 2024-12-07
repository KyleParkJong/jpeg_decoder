# JPEG Decoder Hardware Accelerator

To use our hardware decoder there are three basic steps:
1. Use extractImgStream.py to extract the jpeg bit stream and supporting info from a JFIF file.
2. Run the SystemVerilog simulation to convert the bitsream into R,G, and B pixel channels.
3. Use verilog_rgb_plot.m to display the RGB channels as an image.

We expect on an actual device, step 1 would be handled by the CPU since there are many JPEG file 
standards such as JFIF and EXIF, and they are constantly evolving. Step 3 would likely be handled 
by the display driver, as after our hardware in step 2 the RGB channels are extracted and in memory.


Detailed info on each step:

Step 0: Download a <filename>.jpg file and put it in the ./images directory. Shorter may be helpful 
as you might have to enter name manually in later steps. Note: Our python script only supports 
extracting information from baseline sequential encoded JFIF files that have been 
4:2:0 subsampled (chroma quartered). Progressive jpgs, 4:2:2 & 4:4:4 subsampling, EXIFs, multi-scan,
10bit color, and reset blocks are all unsupported.

Step 1: Move into the ./python directory and use "python3 extractImgStream.py <filename>"
This will extract the bit-stream, huffman tables, quantization tables, and other info from the file
and write the information to individual .txt files in a new folder called <filename>. If the script
does not report that it has recovered the bitstream, 4 Huffman Tables, 2 Quantization tables, and 
header info, then the image is likely using unsupported features mentioned above.

Step2: Move into the ./verilog directory. Make sure you have the following modules loaded:
   module load eecs598-002/f23
   module load verdi
   module load vcs
Use the command "make" to build the systemVerilog simulator and run the simulation. The testbench
will automatically attempt to run on the image most recently extracted with the python script. If you
would like to set the simulator to run on a different image that was previously extracted, you can 
edit ./verilog/tb/top_tb.sv and find this comment near the top of the file:
   /* Or set image name manually */
   //string imgname = "smallCat";
Un-comment the line and replace "smallCat" with the <filename>. (Note that filename has to be the name 
of a folder in ./python that contains .txt files with all of the image info such as bitstream, 
quantization tables, etc. see step 1 for generating these folders).
The simulation will output the RGB channels to individual <filename>_<ch>.txt files in .verilog/out where
<ch> is R, G, and B for the three channels. 
You can use "make verdi" to run the simulation with verdi, or "make clean" to cleanup the .verilog directory.

Step3: Open ./matlab/verilog_rgb_plot.m in MATLAB. Run the script to view the RGB image output by step 2.
The matlab script will automatically attempt to show the image most recently extracted with the python
script. If you would like to display a different image that was previously run through the systemVerilog
simulation, you can un-comment the line 
   %imageName = 'smallCat';
and replace "smallCat" with the <filename>. (Note that filename has to be the name of <filename>_R.txt,
<filename>_G.txt, and <filename>_B.txt files in ./verilog/out. See step 2 for generating these files).


Other important files:
matlab/entropy_decoding_eli.m - matlab version of the decoder, outputs used to validate Verilog
matlab/loeffler_model.m - matlab version of loeffler DCT algorithm hardware
python/functions.py - helper functions for extractImgStream.py
python/huffman.py - helperfunctions for extractImgStream.py
verilog/rtl/top.sv - top module, instantiates other subblocks in rtl folder
verilog/tb/top_tb.sv - top module testbench, generates RGB channels
verilog/sys_defs.svh - contains parameters used by other verilog modules
verilog/tb - contains testbenches used to validate individual submodules


