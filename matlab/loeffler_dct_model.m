%% Clear any data before runnning to avoid erros
clear;

%% Comparing Matlab's DCT/IDCT vs Loeffler's DCT/IDCT implementation
test_data = [50; 60; 70; 80; 90; 100; 110; 120];

% Matlab
matlab_dct  = dct(test_data);
matlab_idct = idct(test_data);

% Loeffler's implementation (must normalize to match matlab output)
improved_loeffler_dct = loefflersDCT(test_data)/sqrt(8);
improved_loeffler_idct = loefflersIDCT(test_data)/sqrt(8);

%% Loeffler's Original DCT (Works correctly)
function dct_out = loefflerDCT(dct_in)

    stage1_output = zeros(1,8);

    constant_b = cos(pi/16); 
    constant_c = sqrt(2) * cos(pi/8); 
    constant_d = cos(3*pi/16); 
    constant_e = cos(5*pi/16); 
    constant_f = sqrt(2) * cos(3*pi/8); 
    constant_g = cos(7*pi/16); 
    constant_h = sqrt(2);

    % Stage 1
    stage1_output(1) = dct_in(1) + dct_in(8);
    stage1_output(2) = dct_in(2) + dct_in(7);
    stage1_output(3) = dct_in(3) + dct_in(6);
    stage1_output(4) = dct_in(4) + dct_in(5);
    stage1_output(5) = dct_in(4) - dct_in(5);
    stage1_output(6) = dct_in(3) - dct_in(6);
    stage1_output(7) = dct_in(2) - dct_in(7);
    stage1_output(8) = dct_in(1) - dct_in(8);

    stage2_output = zeros(1,8);

    % Stage 2
    stage2_output(1) = stage1_output(1) + stage1_output(4);
    stage2_output(2) = stage1_output(2) + stage1_output(3);
    stage2_output(3) = stage1_output(2) - stage1_output(3);
    stage2_output(4) = stage1_output(1) - stage1_output(4);
    stage2_output(5) = (stage1_output(5) + stage1_output(8))*constant_d+(constant_e-constant_d)*stage1_output(8);
    stage2_output(6) = (stage1_output(6) + stage1_output(7))*constant_b+(constant_g-constant_b)*stage1_output(7);
    stage2_output(7) = (stage1_output(6) + stage1_output(7))*constant_b-(constant_g+constant_b)*stage1_output(6);
    stage2_output(8) = (stage1_output(5) + stage1_output(8))*constant_d-(constant_e+constant_d)*stage1_output(5);

    stage3_output = zeros(1,8);

    % Stage 3
    stage3_output(1) = stage2_output(1) + stage2_output(2);
    stage3_output(2) = stage2_output(1) - stage2_output(2);
    stage3_output(3) = (stage2_output(3) + stage2_output(4))*constant_f+(constant_c-constant_f)*stage2_output(4);
    stage3_output(4) = (stage2_output(3) + stage2_output(4))*constant_f-(constant_c+constant_f)*stage2_output(3);
    stage3_output(5) = stage2_output(5) + stage2_output(7);
    stage3_output(6) = stage2_output(8) - stage2_output(6);
    stage3_output(7) = stage2_output(5) - stage2_output(7);
    stage3_output(8) = stage2_output(8) + stage2_output(6);

    dct_out = zeros(1,8);

    % Stage 4
    dct_out(1) = stage3_output(1);
    dct_out(5) = stage3_output(2);
    dct_out(3) = stage3_output(3);
    dct_out(7) = stage3_output(4);
    dct_out(8) = stage3_output(8) - stage3_output(5);
    dct_out(4) = stage3_output(6) * constant_h;
    dct_out(6) = stage3_output(7) * constant_h;
    dct_out(2) = stage3_output(8) + stage3_output(5);

end

%% Loeffler's Original IDCT (Works correctly)
function idct_out = loefflerIDCT(idct_in)

    stage1_output = zeros(1,8);

    constant_b = cos(pi/16); 
    constant_c = sqrt(2) * cos(pi/8); 
    constant_d = cos(3*pi/16); 
    constant_e = cos(5*pi/16); 
    constant_f = sqrt(2) * cos(3*pi/8); 
    constant_g = cos(7*pi/16); 
    constant_h = sqrt(2);

    idct_in_rearranged = zeros(1,8);

    idct_in_rearranged(1) = idct_in(1);
    idct_in_rearranged(2) = idct_in(5);
    idct_in_rearranged(3) = idct_in(3);
    idct_in_rearranged(4) = idct_in(7);
    idct_in_rearranged(5) = idct_in(8);
    idct_in_rearranged(6) = idct_in(4);
    idct_in_rearranged(7) = idct_in(6);
    idct_in_rearranged(8) = idct_in(2);


    % Stage 1
    stage1_output(1) = idct_in_rearranged(1);
    stage1_output(2) = idct_in_rearranged(2);
    stage1_output(3) = idct_in_rearranged(3);
    stage1_output(4) = idct_in_rearranged(4);
    stage1_output(5) = idct_in_rearranged(8) - idct_in_rearranged(5);
    stage1_output(6) = idct_in_rearranged(6) * constant_h;
    stage1_output(7) = idct_in_rearranged(7) * constant_h;
    stage1_output(8) = idct_in_rearranged(8) + idct_in_rearranged(5);

    stage2_output = zeros(1,8);

    % Stage 2
    stage2_output(1) = stage1_output(1) + stage1_output(2);
    stage2_output(2) = stage1_output(1) - stage1_output(2);
    stage2_output(3) = (stage1_output(3) + stage1_output(4))*constant_f-(constant_c+constant_f)*stage1_output(4);
    stage2_output(4) = (stage1_output(3) + stage1_output(4))*constant_f+(constant_c-constant_f)*stage1_output(3);
    stage2_output(5) = stage1_output(5) + stage1_output(7);
    stage2_output(6) = stage1_output(8) - stage1_output(6);
    stage2_output(7) = stage1_output(5) - stage1_output(7);
    stage2_output(8) = stage1_output(8) + stage1_output(6);

    stage3_output = zeros(1,8);

    % Stage 3
    stage3_output(1) = stage2_output(1) + stage2_output(4);
    stage3_output(2) = stage2_output(2) + stage2_output(3);
    stage3_output(3) = stage2_output(2) - stage2_output(3);
    stage3_output(4) = stage2_output(1) - stage2_output(4);
    stage3_output(5) = (stage2_output(5) + stage2_output(8))*constant_d-(constant_e+constant_d)*stage2_output(8);
    stage3_output(6) = (stage2_output(6) + stage2_output(7))*constant_b-(constant_g+constant_b)*stage2_output(7);
    stage3_output(7) = (stage2_output(6) + stage2_output(7))*constant_b+(constant_g-constant_b)*stage2_output(6);
    stage3_output(8) = (stage2_output(5) + stage2_output(8))*constant_d+(constant_e-constant_d)*stage2_output(5);

    idct_out = zeros(1,8);

    % Stage 4
    idct_out(1) = stage3_output(1) + stage3_output(8);
    idct_out(2) = stage3_output(2) + stage3_output(7);
    idct_out(3) = stage3_output(3) + stage3_output(6);
    idct_out(4) = stage3_output(4) + stage3_output(5);
    idct_out(5) = stage3_output(4) - stage3_output(5);
    idct_out(6) = stage3_output(3) - stage3_output(6);
    idct_out(7) = stage3_output(2) - stage3_output(7);
    idct_out(8) = stage3_output(1) - stage3_output(8);

end

%% Improved Loeffler's DCT (Works correctly)
function dct_out = loefflersDCT(dct_in)

    % Stage 1 % Checked
    stage1_out = zeros(8,1);

    stage1_out(1) = dct_in(1) + dct_in(8);
    stage1_out(2) = dct_in(2) + dct_in(7);
    stage1_out(3) = dct_in(3) + dct_in(6);
    stage1_out(4) = dct_in(4) + dct_in(5);
    stage1_out(5) = dct_in(4) - dct_in(5);
    stage1_out(6) = dct_in(3) - dct_in(6);
    stage1_out(7) = dct_in(2) - dct_in(7);
    stage1_out(8) = dct_in(1) - dct_in(8);

    % Stage 2 % Checked
    stage2_out = zeros(10,1);

    stage2_out(1)  = stage1_out(1) + stage1_out(4);
    stage2_out(2)  = stage1_out(2) + stage1_out(3);
    stage2_out(3)  = stage1_out(2) - stage1_out(3);
    stage2_out(4)  = stage1_out(1) - stage1_out(4);
    stage2_out(5)  = stage1_out(8) * (-71);
    stage2_out(6)  = stage1_out(7);
    stage2_out(7)  = stage1_out(6);
    stage2_out(8)  = stage1_out(5) * (355);
    stage2_out(9)  = stage1_out(5) + stage1_out(8);
    stage2_out(10) = stage1_out(6) + stage1_out(7);

    % Stage 3 % Checked
    stage3_out = zeros(10,1);

    stage3_out(1)  = stage2_out(1) + stage2_out(2);
    stage3_out(2)  = stage2_out(1) - stage2_out(2);
    stage3_out(3)  = stage2_out(3);
    stage3_out(4)  = stage2_out(4);
    stage3_out(5)  = stage2_out(5);
    stage3_out(6)  = stage2_out(6);
    stage3_out(7)  = stage2_out(7);
    stage3_out(8)  = stage2_out(8);
    stage3_out(9)  = stage2_out(9)  * (213);
    stage3_out(10) = stage2_out(10) * (251);

    % Stage 4 % Checked
    stage4_out = zeros(10,1);

    stage4_out(1)  = stage3_out(1);
    stage4_out(2)  = stage3_out(2);
    stage4_out(3)  = stage3_out(3);
    stage4_out(4)  = stage3_out(4);
    stage4_out(5)  = stage3_out(5);
    stage4_out(6)  = stage3_out(6) * (-201);
    stage4_out(7)  = stage3_out(7) * (301);
    stage4_out(8)  = stage3_out(8);
    stage4_out(9)  = stage3_out(9);
    stage4_out(10) = stage3_out(10);

    % Stage 5 % Checked
    stage5_out = zeros(9,1);

    stage5_out(1) = stage4_out(1);
    stage5_out(2) = stage4_out(2);
    stage5_out(3) = stage4_out(4);
    stage5_out(4) = stage4_out(3);
    stage5_out(5) = stage4_out(9) + stage4_out(5);
    stage5_out(6) = stage4_out(10) + stage4_out(6);
    stage5_out(7) = stage4_out(10) - stage4_out(7);
    stage5_out(8) = stage4_out(9) - stage4_out(8);
    stage5_out(9) = stage4_out(3) + stage4_out(4);

    % Stage 6 % Checked
    stage6_out = zeros(9,1);

    stage6_out(1) = stage5_out(1);
    stage6_out(2) = stage5_out(2);
    stage6_out(3) = stage5_out(3);
    stage6_out(4) = stage5_out(4);
    stage6_out(5) = stage5_out(5) + stage5_out(7);
    stage6_out(6) = stage5_out(8) - stage5_out(6);
    stage6_out(7) = stage5_out(5) - stage5_out(7);
    stage6_out(8) = stage5_out(8) + stage5_out(6);
    stage6_out(9) = stage5_out(9) * (139);

    % Stage 7 % Checked
    stage7_out = zeros(9,1);

    stage7_out(1) = stage6_out(1);
    stage7_out(2) = stage6_out(2);
    stage7_out(3) = stage6_out(3) * (196);
    stage7_out(4) = stage6_out(4) * (473);
    stage7_out(5) = stage6_out(8) - stage6_out(5);
    stage7_out(6) = stage6_out(6);
    stage7_out(7) = stage6_out(7);
    stage7_out(8) = stage6_out(8) + stage6_out(5);
    stage7_out(9) = stage6_out(9);

    % Stage 8 % Checked
    % Outputs are assign in reverse bit order
    stage8_out = zeros(8,1);

    stage8_out(1) = stage7_out(1);
    stage8_out(5) = stage7_out(2);
    stage8_out(3) = (stage7_out(9) + stage7_out(3)) * 2^(-8);
    stage8_out(7) = (stage7_out(9) - stage7_out(4)) * 2^(-8);
    stage8_out(8) = stage7_out(5) * 2^(-8);
    stage8_out(4) = (stage7_out(6) * (362)) * 2^(-16);
    stage8_out(6) = (stage7_out(7) * (362)) * 2^(-16);
    stage8_out(2) = stage7_out(8) * 2^(-8);

    dct_out = stage8_out;

end

%% Improved Loeffler's IDCT (Works correctly)
function idct_out = loefflersIDCT(idct_in_reversed)

    constant_b = cos(pi/16); 
    constant_c = sqrt(2) * cos(pi/8); 
    constant_d = cos(3*pi/16); 
    constant_e = cos(5*pi/16); 
    constant_f = sqrt(2) * cos(3*pi/8); 
    constant_g = cos(7*pi/16); 
    constant_h = sqrt(2);

    % Undoing the bit-reverse order of the input
    idct_in = zeros(1,8);

    idct_in(1) = idct_in_reversed(1);
    idct_in(2) = idct_in_reversed(5);
    idct_in(3) = idct_in_reversed(3);
    idct_in(4) = idct_in_reversed(7);
    idct_in(5) = idct_in_reversed(8);
    idct_in(6) = idct_in_reversed(4);
    idct_in(7) = idct_in_reversed(6);
    idct_in(8) = idct_in_reversed(2);

    % Stage 1 Checked
    stage1_out = zeros(8,1);

    stage1_out(1) = idct_in(1);
    stage1_out(2) = idct_in(2);
    stage1_out(3) = idct_in(3);
    stage1_out(4) = idct_in(4);
    stage1_out(5) = idct_in(5);
    stage1_out(6) = idct_in(6) * (362);
    stage1_out(7) = idct_in(7) * (362);
    stage1_out(8) = idct_in(8);

    % Stage 2 Checked
    stage2_out = zeros(9,1);

    stage2_out(1)  = stage1_out(1);
    stage2_out(2)  = stage1_out(2);
    stage2_out(3)  = stage1_out(4) * (473);
    stage2_out(4)  = stage1_out(3) * (196);
    stage2_out(5)  = (stage1_out(8) - stage1_out(5)) * 2^(8);
    stage2_out(6)  = stage1_out(6);
    stage2_out(7)  = stage1_out(7);
    stage2_out(8)  = (stage1_out(8) + stage1_out(5)) * 2^(8);
    stage2_out(9)  = stage1_out(3) + stage1_out(4);

    % Stage 3 Checked
    stage3_out = zeros(9,1);

    stage3_out(1)  = stage2_out(1);
    stage3_out(2)  = stage2_out(2);
    stage3_out(3)  = stage2_out(3);
    stage3_out(4)  = stage2_out(4);
    stage3_out(5)  = stage2_out(5) + stage2_out(7);
    stage3_out(6)  = stage2_out(8) - stage2_out(6);
    stage3_out(7)  = stage2_out(5) - stage2_out(7);
    stage3_out(8)  = stage2_out(8) + stage2_out(6);
    stage3_out(9)  = stage2_out(9)  * (139);

    % Stage 4 Checked
    stage4_out = zeros(9,1);

    stage4_out(1)  = stage3_out(1);
    stage4_out(2)  = stage3_out(2);
    stage4_out(3)  = stage3_out(9) - stage3_out(3);
    stage4_out(4)  = stage3_out(9) + stage3_out(4);
    stage4_out(5)  = stage3_out(8) * (355);
    stage4_out(6)  = stage3_out(6);
    stage4_out(7)  = stage3_out(7);
    stage4_out(8)  = stage3_out(5) * (-71);
    stage4_out(9)  = stage3_out(5) + stage3_out(8);

    % Stage 5 Checked
    stage5_out = zeros(10,1);

    stage5_out(1)  = stage4_out(1);
    stage5_out(2)  = stage4_out(2);
    stage5_out(3)  = stage4_out(3);
    stage5_out(4)  = stage4_out(4);
    stage5_out(5)  = stage4_out(5);
    stage5_out(6)  = stage4_out(7) * (301);
    stage5_out(7)  = stage4_out(6) * (-201);
    stage5_out(8)  = stage4_out(8);
    stage5_out(9)  = stage4_out(9);
    stage5_out(10) = stage4_out(6) + stage4_out(7);

    % Stage 6 Checked
    stage6_out = zeros(10,1);

    stage6_out(1)  = stage5_out(1) + stage5_out(2);
    stage6_out(2)  = stage5_out(1) - stage5_out(2);
    stage6_out(3)  = stage5_out(3) * 2^(-8);
    stage6_out(4)  = stage5_out(4) * 2^(-8);
    stage6_out(5)  = stage5_out(5);
    stage6_out(6)  = stage5_out(6);
    stage6_out(7)  = stage5_out(7);
    stage6_out(8)  = stage5_out(8);
    stage6_out(9)  = stage5_out(9) * (213);
    stage6_out(10) = stage5_out(10) * (251);

    % Stage 7 Checked
    stage7_out = zeros(8,1);

    stage7_out(1) = stage6_out(1) + stage6_out(4);
    stage7_out(2) = stage6_out(2) + stage6_out(3);
    stage7_out(3) = stage6_out(2) - stage6_out(3);
    stage7_out(4) = stage6_out(1) - stage6_out(4);
    stage7_out(5) = (stage6_out(9) - stage6_out(5)) * 2^(-16);
    stage7_out(6) = (stage6_out(10) - stage6_out(6)) * 2^(-16);
    stage7_out(7) = (stage6_out(10) + stage6_out(7)) * 2^(-16);
    stage7_out(8) = (stage6_out(9) + stage6_out(8)) * 2^(-16);

    % Stage 8 Checked
    stage8_out = zeros(8,1);

    stage8_out(1) = stage7_out(1) + stage7_out(8);
    stage8_out(2) = stage7_out(2) + stage7_out(7);
    stage8_out(3) = stage7_out(3) + stage7_out(6);
    stage8_out(4) = stage7_out(4) + stage7_out(5);
    stage8_out(5) = stage7_out(4) - stage7_out(5);
    stage8_out(6) = stage7_out(3) - stage7_out(6);
    stage8_out(7) = stage7_out(2) - stage7_out(7);
    stage8_out(8) = stage7_out(1) - stage7_out(8);

    idct_out = stage8_out;
end

%% Loeffler's 2D DCT (Not working correctly due to the 1D)
function dct_out = loefflersDCT_2D(dct_in)

    row_dct = zeros(8,8);
    dct_out = zeros(8,8);

    % DCT of the row
    for row=1:size(dct_in,1)
        row_dct(row,:) = loefflersDCT(dct_in(row,:));
    end

    % Tranpose
    transposed_matrix = transpose(row_dct);

    % In the transpose matrix, the rows contain
    % the values of each column. Compute the DCT
    % of the columns by computing the DCT of each row
    % of the transposed matrix
    for row=1:size(transposed_matrix,1)
        dct_out(row,:) = loefflersDCT(transposed_matrix(row,:));
    end
end

%% Loeffler's 2D IDCT (Works correctly)
function idct_out = loefflersIDCT_2D(idct_in)

    row_idct = zeros(8,8);
    idct_out = zeros(8,8);

    % DCT of the row
    for row=1:size(idct_in,1)
        row_idct(row,:) = loefflersIDCT(idct_in(row,:));
    end

    % Tranpose
    transposed_matrix = transpose(row_idct);

    % In the transpose matrix, the rows contain
    % the values of each column. Compute the DCT
    % of the columns by computing the DCT of each row
    % of the transposed matrix
    for row=1:size(transposed_matrix,1)
        idct_out(row,:) = loefflersIDCT(transposed_matrix(row,:));
    end
end

%% Testing Loeffler's DCT/IDCT with actual data

N=8;
n=0:N-1;
k=0:N-1;
k=k.';
t=k*(pi()/N*(n+.5));
dct = cos(t);
% dct = zeros(N);
% i = cos(pi()/N*(n+.5)*k);
%plot(cos(t))

A=imread('my_cat.png');
A=mean(A,3);
B=filter2([.3,.3,.3;.3,.3,.3;.3,.3,.3],A);
C=A(1:3:end,1:3:end);
C2=B(1:3:end,1:3:end);
D=filter2([.3,.3,.3;.3,.3,.3;.3,.3,.3],C2);
E=D(1:3:end,1:3:end);
F=E(10:10+31,5:5+31);
F=F/max(max(F))*255;
% figure(1)
% imshow(F,[])
F=A;
imsize=size(F);
cols=imsize(2);
rows=imsize(1);

F=A(1:floor(rows/8)*8,1:floor(cols/8)*8);

qtable=[16 11 10 16 24 40 51 61;
        12 12 14 19 26 58 60 55;
        14 13 16 24 40 57 69 56;
        14 17 22 29 51 87 80 62;
        18 22 37 56 68 109 103 77;
        24 35 55 64 81 104 113 92;
        49 64 78 87 103 121 120 101;
        72 92 95 98 112 100 103 99;
        ];
filter=[1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1;
        ];
X=ones(32);
X_1=ones(32);
for i = 1:N:rows
    for j = 1:N:cols
        %X(i:i+N-1,j:j+N-1)=dct*F(i:i+N-1,j:j+N-1)*dct.';
        X(i:i+N-1,j:j+N-1) = loefflersDCT_2D(F(i:i+N-1,j:j+N-1));
    end
end
Q=ones(32);
Q_1=ones(32);
for i = 1:N:rows
    for j = 1:N:cols
        %Q(i:i+N-1,j:j+N-1)=round(X(i:i+N-1,j:j+N-1)./qtable);
        Q(i:i+N-1,j:j+N-1)=round(X(i:i+N-1,j:j+N-1)./qtable);
    end
end
q=ones(32);
for i = 1:N:rows
    for j = 1:N:cols
        %q(i:i+N-1,j:j+N-1)=inv(dct)*(Q(i:i+N-1,j:j+N-1).*qtable.*filter)*inv(dct.');
        q(i:i+N-1,j:j+N-1) = loefflersIDCT_2D(Q(i:i+N-1,j:j+N-1).*qtable.*filter);
    end
end


%X=dct*F*dct.';
%Q=round(X./qtable);

% figure(4)
% imshow(X,[])
% figure(5)
% imshow(Q,[])
% figure(6)
% imshow(q,[])
subplot(1,3,1)
imshow(F,[])
subplot(1,3,2)
imshow(Q,[])
subplot(1,3,3)
imshow(q,[])
%subplot(1,4,4)
%imshow(q,[])
err=F-q;
% subplot(1,4,4)
% imshow(F-q,[])
%imshow(inv(dct)*(Q*100)*inv(dct.'),[]);


% i = 1:N;
% x=cos(i*2*pi()/20);
% X=dct*x.';
% figure(1)
% plot(x)
% hold
% plot(inv(dct)*X);
% figure(2)
% plot(X)

q_uint8 = uint8((q - min(q(:))) / (max(q(:)) - min(q(:))) * 255);
f_uint8 = uint8(F);
[peaksnr, snr] = psnr(q_uint8,f_uint8); 


