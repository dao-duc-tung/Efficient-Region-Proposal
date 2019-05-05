%% init
pIn = 'E:\DAO DUC TUNG\TestBMS\src_ETHZ';
s1 = 'image_00005439_0.png';
s2 = 'image_00005440_0.png';
p1 = fullfile(pIn, s1);
p2 = fullfile(pIn, s2);


%% convert images to double and grayscale
I1 = impyramid( imInit(p1), 'reduce' );
I2 = impyramid( imInit(p2), 'reduce' );

%%

[flowHor flowVer] = pyramidFlow(I1, I2, 5, 3, 3);  %pyramidFlow( I1, I2, winSize, ITER_NO, PYRE_NO )

%show the output flows 
% imS(flowHor,1,[-10 10]) 
% imS(flowVer,2,[-10 10])

%%
%show the warped image to check the quality of registration
Iw = imWarp(flowHor, flowVer, I2);
% imS(I1,10)
% imS(Iw,11)
% imS(I2,12)

%% define good features to track (Harris Corner)
tempI = imread(p1);
dis_fr_bound = 5;
sub_size = 20;
search_size = sub_size*3;
corners = initCorners(I1,dis_fr_bound,search_size);

%% get flow
dr=0; dc=0;
num_corners = size(corners,1);
for i=1:num_corners
    dr=dr+flowVer(corners(i,1),corners(i,2));
    dc=dc+flowHor(corners(i,1),corners(i,2));
end
dr = -round(dr/num_corners);
dc = -round(dc/num_corners);

%% get moving area
getMovingArea(I1,I2,dr,dc,MOVING_AREA_SOLUTION);