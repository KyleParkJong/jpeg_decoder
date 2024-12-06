clc;
clear;
close all;

load '../verilog/tb/tiny_R.txt'; 
load '../verilog/tb/tiny_G.txt'; 
load '../verilog/tb/tiny_B.txt';

R = [];
G = [];
B = [];

for i = 1:8:length(tiny_R) 
    R = [R, tiny_R(i:i+7,1:8)];
    G = [G, tiny_G(i:i+7,1:8)];
    B = [B, tiny_B(i:i+7,1:8)];
end

RGB = uint8(cat(3, R, G, B));

figure;
imshow(RGB)