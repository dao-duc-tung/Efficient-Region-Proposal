%% get result
% newCorners1{1}(1) = 107; newCorners1{1}(2) = 249;
% newCorners1{2}(1) = 107; newCorners1{2}(2) = 262;
% 
% newCorners2{1}(1) = 110; newCorners2{1}(2) = 227;
% newCorners2{2}(1) = 110; newCorners2{2}(2) = 238;

%% get egomotion
c=round((newCorners1{2}(1)-newCorners1{1}(1) + newCorners2{2}(1)-newCorners2{1}(1))/2);
r=round((newCorners1{2}(2)-newCorners1{1}(2) + newCorners2{2}(2)-newCorners2{1}(2))/2);

%% compensate egomotion
I1=edgeSobel(imread('car1.png'), 225);
I2=edgeSobel(imread('car2.png'), 225);
[rows, cols, ~] = size(I2);
Iw = zeros(rows, cols);
for a=1:rows
    for b=1:cols
        y=a-r;
        x=b-c;
        if(y>=1&&x>=1&&y<=rows&&x<=cols)
            Iw(a,b) = I1(y,x);
        end
    end
end
% Iw = uint8(Iw);
Iw = Iw>0;
imS(I1,8);
imS(I2,9);
imS(Iw,10);
thres = 0;
moveI = (I2-Iw)>thres;
imS(moveI, 11);
se_dilation = strel('square', 2);
moveI = imerode(moveI, se_dilation);
% se_dilation = strel('square', 5);
% moveI = imdilate(moveI, se_dilation);
imS(moveI, 11);