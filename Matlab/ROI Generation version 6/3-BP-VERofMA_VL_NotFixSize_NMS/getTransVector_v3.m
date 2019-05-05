% version 4: get trans vector using original bit-plane algorithm
function [dr dc] = getTransVector_v4(I1,I2)
[rows, cols, depth] = size(I1);
if depth > 1
    I1 = rgb2gray(I1);
    I2 = rgb2gray(I2);
end
fig = 2;

%% to gray code
I1G = getGrayCode(I1);
I2G = getGrayCode(I2);
% I1G = I1;
% I2G = I2;

%% define good features to track (Harris Corner)
dis_fr_bound = 5;
sub_size = 20;
search_size = sub_size*3;
num_corners = 8;
corners = initFixSubWins(I1,dis_fr_bound,search_size,num_corners);

% tempI = drawSubWin(sub_win, sub_size, I1, 'red');
% imS(tempI, fig+1);

%% estimate local motion
num_corners = size(corners,1);
new_corners = []; % save min error of each sub-win
half_subW = round(sub_size/2);
for i=1:num_corners
    % get sub-win in frame 1
    r=corners(i,1);
    c=corners(i,2);
    subW = I1G((r-half_subW):(r+half_subW),(c-half_subW):(c+half_subW));
    % search matching-win in search-win in frame 2
    min_coor = [0 0 256*sub_size*sub_size];
    for r=(round(corners(i,1)-search_size/2+half_subW)):(round(corners(i,1)+search_size/2-half_subW))
        for c=(round(corners(i,2)-search_size/2+half_subW)):(round(corners(i,2)+search_size/2-half_subW))
            temp_subW = I2G((r-half_subW):(r+half_subW),(c-half_subW):(c+half_subW));
            error_tempW = bitxor(subW, temp_subW);
            error_temp = sum(error_tempW(:));
            if min_coor(1,3) > error_temp
                min_coor(1,1) = r;
                min_coor(1,2) = c;
                min_coor(1,3) = error_temp;
            end
        end
    end
    new_corners = [new_corners; min_coor(1,1) min_coor(1,2)];
end

%% draw
% tempI = drawSubWin(corners, sub_size, I2, 'red');
% tempI = drawSubWin(new_corners, sub_size, tempI, 'green');
% imS(tempI, fig+1);

%% calc global motion
dr=0;dc=0;
num_corners=size(new_corners,1);
for i=1:num_corners
    dr=dr+new_corners(i,1)-corners(i,1);
    dc=dc+new_corners(i,2)-corners(i,2);
end
dr=-round(dr/num_corners); dc=-round(dc/num_corners);
end