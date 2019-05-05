function M = edgeSobel(I,thres)
[rows cols depth] = size(I);
if(depth > 1)
    I = rgb2gray(I);
end
k = [-1 -2 -1; 0 0 0; 1 2 1];
H = conv2(double(I),k, 'same');
V = conv2(double(I),k','same');
M = sqrt(H.*H + V.*V);
% H=uint8(H);
% H=H>thres;
% V=uint8(V);
% V=V>thres;
M=uint8(M);
M=M>thres;
