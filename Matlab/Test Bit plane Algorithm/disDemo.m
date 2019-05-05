clear;
p1 = '5441.png';
p2 = '5442.png';
% p1 = 'E:\DAO DUC TUNG\TestBMS\src_Caltech\V000_frame_0383.bmp';
% p2 = 'E:\DAO DUC TUNG\TestBMS\src_Caltech\V000_frame_0384.bmp';
I1 = rgb2gray(imread(p1));
I2 = rgb2gray(imread(p2));
[rows, cols, ~] = size(I1);
fig = 2;

%% to gray code
I1G = getGrayCode(I1);
I2G = getGrayCode(I2);
% I1G = I1;
% I2G = I2;

%% define 8 Matching Sub-Windows
dis_fr_bound = 5;
sub_size = 16;
search_size = sub_size*3;
num_sub_win = 5;
sub_win = initSubWin(I1,dis_fr_bound,search_size,sub_size,num_sub_win);

tempI = drawSubWin(sub_win, sub_size, I1, 'red');
imS(tempI, fig+1);

%% estimate local motion
num_sub_win = size(sub_win,1);
error_coor = []; % save min error of each sub-win
half_subW = round(sub_size/2);
for i=1:num_sub_win
    % get sub-win in frame 1
    r=sub_win(i,1);
    c=sub_win(i,2);
    subW = I1G((r-half_subW):(r+half_subW),(c-half_subW):(c+half_subW));
    % search matching-win in search-win in frame 2
    min_coor = [0 0 256*sub_size*sub_size];
    for r=(round(sub_win(i,1)-search_size/2+half_subW)):(round(sub_win(i,1)+search_size/2-half_subW))
        for c=(round(sub_win(i,2)-search_size/2+half_subW)):(round(sub_win(i,2)+search_size/2-half_subW))
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
    error_coor = [error_coor; min_coor(1,1) min_coor(1,2) min_coor(1,3)];
end

tempI = drawSubWin(sub_win, sub_size, I2, 'red');
tempI = drawSubWin(error_coor, sub_size, tempI, 'green');
imS(tempI, fig+2);

%% calc global motion
dr=0;dc=0;
for i=1:num_sub_win
    dr=dr+error_coor(i,1)-sub_win(i,1);
    dc=dc+error_coor(i,2)-sub_win(i,2);
end
dr=round(dr/num_sub_win);dc=round(dc/num_sub_win);

%% filter random shake of the camera holder using low-pass-filter


%% apply on edge map
I1 = edgeSobel(I1, 80);
I2 = edgeSobel(I2, 80);

%% compensate egomotion
It = translateImage(I1,dr,dc);
imS(It, fig+3);

%% match 2 images
It = imdilate(It, strel('square', 3));
Id = I2 - It&I2;
Id = imerode(Id, strel('square', 3));
imS(Id, fig+4);


