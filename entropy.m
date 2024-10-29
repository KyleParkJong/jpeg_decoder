clear; close all;
x1 = [
     32.5 3.0 1.0 0.0 0.0 0.0;
     17.0 5.0 2.0 0.0 0.0 0.0; 
     4.0 3.0 1.0 0.0 0.0 0.0;
     1.0 0.0 0.0 0.0 0.0 0.0;
     0.0 0.0 0.0 0.0 0.0 0.0;
     0.0 0.0 0.0 0.0 0.0 0.0;
     ];

x2 = magic(8);
x = x2;

flip = false;
count = 1;

% Zig Zag 
% Very complicated. Store indices in lookup tables r_lut and c_lut

N = length(x);
r_lut = zeros(1, N);
c_lut = zeros(1, N); 

out = zeros(1, N*N);
out(1) = x(1, 1);
h = 1;

for i=1:2*N-1
    if i <= N
        if mod(i, 2) == 0
            j = i;
            for k = 1:i
                out(h) = x(k,j);
                r_lut(h) = k;
                c_lut(h) = j;
                h = h + 1;
                j = j - 1;
            end
        else
            k = i;
            for j = 1:i
                out(h) = x(k, j);
                r_lut(h) = k;
                c_lut(h) = j;
                h = h + 1;
                k = k - 1;
            end
        end
    else
        if mod(i, 2) == 0
            j = N;
            for k = mod(i, N) + 1 : N
                out(h) = x(k, j);
                r_lut(h) = k;
                c_lut(h) = j;
                h = h + 1;
                j = j - 1;
            end
        else
            k = N;
            for j = mod(i, N) + 1 : N
                out(h) = x(k, j);
                r_lut(h) = k;
                c_lut(h) = j;
                h = h + 1;
                k = k - 1;
            end
        end
    end
end


disp(x);
disp(out);
disp(r_lut);
disp(c_lut);
