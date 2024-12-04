clc;
clear;
close all;

%Image Dimensions in pixels
width = 16;
height = 16;

blocksWide = ceil(width/16)*2;
blocksTall = ceil(height/16)*2;

% Read Huffman DC, AC table and encoded values %
file_DCHuff0 = fopen('./tiny/DC_HuffTable_Index0.txt', 'r');
file_ACHuff0 = fopen('./tiny/AC_HuffTable_Index0.txt', 'r');
file_DCHuff1 = fopen('./tiny/DC_HuffTable_Index1.txt', 'r');
file_ACHuff1 = fopen('./tiny/AC_HuffTable_Index1.txt', 'r');
file_bitstream = fopen('./tiny/bitStream.txt', 'r');
formatSpec = '%s %d';
DC0 = textscan(file_DCHuff0, formatSpec);
AC0 = textscan(file_ACHuff0, formatSpec);
DC1 = textscan(file_DCHuff1, formatSpec);
AC1 = textscan(file_ACHuff1, formatSpec);
 
huff_dc0_codes  = DC0{1};
huff_dc0_values = DC0{2};
huff_ac0_codes  = AC0{1};
huff_ac0_values = AC0{2};
huff_dc1_codes  = DC1{1};
huff_dc1_values = DC1{2};
huff_ac1_codes  = AC1{1};
huff_ac1_values = AC1{2};

huffman_dc0_map = containers.Map(huff_dc0_codes, huff_dc0_values);
huffman_ac0_map = containers.Map(huff_ac0_codes, huff_ac0_values);
huffman_dc1_map = containers.Map(huff_dc1_codes, huff_dc1_values);
huffman_ac1_map = containers.Map(huff_ac1_codes, huff_ac1_values);

dcHuffTables = {huffman_dc0_map,huffman_dc1_map};
acHuffTables = {huffman_ac0_map,huffman_ac1_map};

values_in = fscanf(file_bitstream, '%s');

encoded_values = [];
dc_flag = 1;
cnt = 0;
lastDc = 0;
decodingOrder = [1,1,1,1,2,2];
orderTracker = 0;

while (~isempty(values_in))
    if dc_flag == 1 % DC
        [values_out, b_size] = decode_huffman_dc(values_in, dcHuffTables{decodingOrder(orderTracker+1)});
        if (b_size == 0) %DC val is 0
            encoded_values = [encoded_values, lastDc];
        else
            newDc = lastDc + vli(values_out(1:b_size));
            lastDc = newDc;
            encoded_values = [encoded_values, newDc];
        end
        values_in = values_out(b_size+1:end);
        dc_flag = 0;
        cnt = cnt + 1;
    else % AC
        [values_out, run_length, b_size] = decode_huffman_ac(values_in, acHuffTables{decodingOrder(orderTracker+1)});
        if run_length == 0 && b_size == 0  % EOB
            zeros_to_append = zeros(1, 64-cnt);
            encoded_values = [encoded_values, zeros_to_append];
            if(isempty(values_out))%Check if at end of bitstream
                break
            end
            values_in = values_out(b_size+1:end);
            dc_flag = 1;
            cnt = 0;
            orderTracker = mod(orderTracker + 1,length(decodingOrder));
        else
            zeros_to_append = zeros(1, run_length);
            encoded_values = [encoded_values, zeros_to_append];   % adding zeros
            if (b_size == 0)
                encoded_values = [encoded_values, 0];
            else
                encoded_values = [encoded_values, vli(values_out(1:b_size))];
            end 
            values_in = values_out(b_size+1:end);
            cnt = cnt + size(zeros_to_append,2) + 1;
        end
    end
    display(cnt)
end
disp("Finished Dehuff Process")

%Inverse Zigzag scan
blocks = zeros(8,1.5*blocksTall*blocksWide*8);
pos = 1;
for i = 1:64:length(encoded_values)
    blocks(1:8,pos:pos+7) = inv_zigzag(encoded_values(i:i+63), 8);
    pos = pos+8;
end

%Dequant
QuantTable0 = readmatrix('./tiny/QuantTable0.txt');
QuantTable1 = readmatrix('./tiny/QuantTable1.txt');

quantTables = {QuantTable0,QuantTable1};

orderTracker = 0;
blocksDQ = zeros(8,1.5*blocksTall*blocksWide*8);
for i = 1:8:length(blocks)
    blocksDQ(1:8,i:i+7) = blocks(1:8,i:i+7) .*quantTables{decodingOrder(orderTracker+1)};
    orderTracker = mod(orderTracker + 1,length(decodingOrder));
end

blocksIDCT = zeros(8,1.5*blocksTall*blocksWide*8);
%IDCT
for i = 1:8:length(blocksDQ)
    blocksIDCT(1:8,i:i+7) = idct2(blocksDQ(1:8,i:i+7));
end
imshow(blocksIDCT,[])

% %TODO: Supersample and convert to RGB
% Probably won't use this, but do have to un-interleve
% %Un-Interleave
% Ychan = zeros(8*blocksTall,8*blocksWide);
% Cbchan = zeros(8*blocksTall/2,8*blocksWide/2);
% Crchan = zeros(8*blocksTall/2,8*blocksWide/2);
% i = 1;
% while(i<length(encoded_values))
%     xpos = 0;
%     ypos = 0;
%     for rows = 0:1
%         for cols = 0:1
%             Ychan(position(1)+) = inv_zigzag(encoded_values(i:i+63), 8);
% end

% fileID1 = fclose(fileID1);
% fileID2 = fclose(fileID2);
% fileID3 = fclose(fileID3);

function [values_out, b_size] = decode_huffman_dc(values_in, huffman_dc_map)
    current_str = "";

    for i=1:length(values_in)
        current_str = strcat(current_str, values_in(i));
        if isKey(huffman_dc_map, current_str)
            b_size = huffman_dc_map(current_str);
            break;
        end
    end
    if(i+1 > length(values_in)) %Check if at end of bit stream
        values_out = '';
    else
        values_out = values_in(i+1:end);
    end
end

function [values_out, run_length, b_size] = decode_huffman_ac(values_in, huffman_ac_map)
    current_str = "";

    for i=1:length(values_in)
        current_str = strcat(current_str, values_in(i));
        if isKey(huffman_ac_map, current_str)
            bit8 = dec2bin(huffman_ac_map(current_str), 8);
            run_length = bin2dec(bit8(1:4));
            b_size = bin2dec(bit8(5:8));
            break;
        end
    end
    if(i+1 > length(values_in)) %Check if at end of bit stream
        values_out = '';
    else
        values_out = values_in(i+1:end);
    end
end

% Variable Length Integer (VLI)
function int4 = vli(binStr) 
    if binStr(1) == '1'  % Positive value
        int4 = bin2dec(binStr);
    else  % Negative value
        for i=1:length(binStr)
            if binStr(i) == '0'
                binStr(i) = '1';
            else
                binStr(i) = '0';
            end
        end
        int4 = -1*bin2dec(binStr);
    end 
end

function [A] = inv_zigzag(B,dim)
v = ones(1,dim); k = 1;
A = zeros(dim,dim);
for i = 1:2*dim-1
    C1 = diag(v,dim-i);
    C2 = flip(C1(1:dim,1:dim),2);
    C3 = B(k:k+sum(C2(:))-1);
    k = k + sum(C2(:));
    if mod(i,2) == 0
       C3 = flip(C3);
    end
        C4 = zeros(1,dim-size(C3,2));
    if i >= dim
       C5 = cat(2,C4, C3); 
    else       
        C5 = cat(2,C3,C4);
    end
    C6 = C2*diag(C5);
    A = C6 + A;
end
end