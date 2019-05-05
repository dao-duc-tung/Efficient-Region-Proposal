%convert images to double and grayscale
p1 = '5441.png';
p2 = '5442.png';
I1 = impyramid( imInit(p1), 'reduce' );
I2 = impyramid( imInit(p2), 'reduce' );
% I1 = impyramid( imInit('5110.png'), 'reduce' );
% I2 = impyramid( imInit('5111.png'), 'reduce' );

% I1 = impyramid( im2double( edgeSobel(imread(p1),120)), 'reduce' );
% I2 = impyramid( im2double( edgeSobel(imread(p2),120)), 'reduce' );

%%
winSize = 15;
ITER_NO = 1;
PYRE_NO = 1;
[flowHor flowVer] = pyramidFlow(I1, I2, winSize, ITER_NO, PYRE_NO);  %pyramidFlow( I1, I2, winSize, ITER_NO, PYRE_NO )

%show the output flows 
% imS(flowHor,1,[-10 10]) 
% imS(flowVer,2,[-10 10])

%% warp by Tung
[rows, cols, ~] = size(I1);
Iw = zeros(rows, cols);

figure(9)
imagesc(I2);
hold on;
step=round(winSize/8);
for a=1:step:rows
    for b=1:step:cols
        y=round(a+flowVer(a,b));
        x=round(b+flowHor(a,b));
        if(y>=1&&x>=1&&y<=rows&&x<=cols)
%             Iw1(a,b) = I1(y,x);
            plot(b,a,'.');
            line([b x],[a y],'Color','blue','LineStyle','-');
        end 
    end
end
hold off;
imS(Iw1,10);

% Iw2 = imWarp(flowHor, flowVer, I2);
% imS(Iw2,11);
% imS(Iw1-Iw2,12);


%%
%show the warped image to check the quality of registration
% thres = 0.5;
% corners=round([29 99;224 112]/2);
% % solution 1: [Ix Iy] = gradient( B );
% r = corners(2,2); c = corners(2,1);
% Iw = imWarp(flowHor(r,c), flowVer(r,c), I1);
% % imS(I1,10);
% imS(I2,11);
% imS(Iw,12);
% movingI = (Iw-I2)>thres;
% imS(movingI, 13);

% se_dilation = strel('square', 2);
% movingI = imerode(movingI, se_dilation);
% se_dilation = strel('square', 15);
% movingI = imdilate(movingI, se_dilation);
% imS(movingI,15);
% imS(movingI.*I2, 16);

% solution 2
% Iw = imWarp(flowHor, flowVer, I1);
% imS(Iw,13);
% movingI = (Iw-I1);
% se_dilation = strel('square', 2);
% movingI = imerode(movingI, se_dilation);
% se_dilation = strel('square', 8);
% movingI = imdilate(movingI, se_dilation);
% imS(movingI,14);
% imS(movingI.*I2, 15);



