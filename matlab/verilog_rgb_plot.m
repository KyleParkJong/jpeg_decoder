clc;
clear;
close all;

imageName = 'smallCat'; 

%%%%%%%%%% USER: DO NOT EDIT BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Read Header Info
Header = readmatrix(['../python/',imageName,'/HeaderInfo.txt']);

height = Header(1,1);
width = Header(1,2);
blocksWide = ceil(width/16)*2;
blocksTall = ceil(height/16)*2;

Rch = load (['../verilog/out/',imageName,'_R.txt']);
Gch = load (['../verilog/out/',imageName,'_G.txt']);
Bch = load (['../verilog/out/',imageName,'_B.txt']);

RGB = uint8(cat(3, Rch, Gch, Bch));

%Assemble BlockStream into Correct Image Dimensions
finalImg = uint8(zeros(blocksTall*8,blocksWide*8,3));
lrudTracker = 0; %UpperLeft, UppperRight, LowerLeft, LowerRight
xpos = 1;
ypos = 1;
for i = 1:8:length(RGB)
    finalImg(ypos:ypos+7,xpos:xpos+7,1:3) = RGB(i:i+7,1:8,1:3);
    if lrudTracker == 0
        xpos = xpos + 8;
        lrudTracker = 1;
    elseif lrudTracker == 1
        xpos = xpos - 8;
        ypos = ypos + 8;
        lrudTracker = 2;
    elseif lrudTracker == 2
        xpos = xpos + 8;
        lrudTracker = 3;
    else %lrudTracker == 3;
        if(xpos == blocksWide*8-7) %Reached end of row
            xpos = 1;
            ypos = ypos + 8;
        else
            xpos = xpos + 8;
            ypos = ypos - 8;
        end
        lrudTracker = 0;
    end
end

figure;
imshow(finalImg)