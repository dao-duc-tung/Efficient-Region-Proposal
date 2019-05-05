%% init
clear; warning off;
p1 = 'image_00005439_0.png';
p2 = 'image_00005440_0.png';
fig = 2;

oriI1 = imread(p1);
oriI2 = imread(p2);

%% divide image into 14x14 grid-image
gridSize = 0;
if gridSize > 1
    gImg1 = getGridImage(oriI1, gridSize);
    gImg2 = getGridImage(oriI2, gridSize);
else
    gImg1 = oriI1;
    gImg2 = oriI2;
end
% imS(gImg1, fig+1);
% imS(gImg2, fig+2);

%% define good features to track (Harris Corners)
tempImg = gImg1;
[gR,gC,~] = size(tempImg);
dis_fr_bound = floor(gC/128)+1;
sub_size = floor(gC/32)+1;
search_size = sub_size*3;
corners = initCorners(tempImg,dis_fr_bound+search_size/2);
corners(size(corners,1),:) = [];

%% estimate local motion
I1 = gImg1;
I2 = gImg2;
winSize = floor(gC/32)+1;
% iter = 2or3, pyra=3 for ver1
% iter = 80, pyra=0 for ver1
ITER_NO = 2;
PYRA_NO = 3;
[dr,dc] = pyramidTung_v2(I1, I2, ITER_NO, PYRA_NO, corners, winSize);

%% translate image
% oriI1t = translateImage(oriI1, -dr, -dc);
% imS(oriI2, fig+3);
% imS(oriI1t, fig+4); 

