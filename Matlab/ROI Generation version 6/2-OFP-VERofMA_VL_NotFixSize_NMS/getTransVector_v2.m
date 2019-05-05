% version 2: LK Pyramids based Translation Transformation
function [dr,dc] = getTransVector_v2(oriI1,oriI2)
%% define good features to track (Harris Corners)
dis_fr_bound = 5;
sub_size = 20;
search_size = sub_size*3;
corners = initCorners(oriI1,dis_fr_bound,search_size);
corners(size(corners,1),:) = [];

winSize = 21;
ITER_NO = 2;
PYRA_NO = 3;
[dr,dc] = pyramidTung_v1(oriI1,oriI2,ITER_NO,PYRA_NO,corners,winSize);
dr=-dr; dc=-dc;
end