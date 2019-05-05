% version 2: find sub-wins contain harris corner
function sub_win = initSubWin(I1,dis_fr_bound,...
    search_size,sub_size,num_sub_win)
sub_win = [];
im = I1;
[rows,cols,~]=size(I1);

num_sub_win = 4;
sol = 2;
sigma = 1;
radius = 2;
score = (2*radius+1);
thres1 = 10000;
thres2 = 0.4;

% derivative in x and y direction
[dx, dy] = meshgrid(-1:1, -1:1);
Ix = conv2(double(im), dx, 'same');
Iy = conv2(double(im), dy, 'same');

%% implementing the gaussian filter
dim = max(1, fix(6*sigma));
m=dim;n=dim;
[h1,h2] = meshgrid(-(m-1)/2:(m-1)/2, -(n-1)/2:(n-1)/2);
hg = exp(-h1.^2+h2.^2)/(2*sigma^2);
[a,b]=size(hg);
sum=0;
for i=1:a
    for j=1:b
        sum=sum+hg(i,j);
    end
end
g=hg./sum;
% calc entries of the M matrix
% Ix2 = conv2(double(Ix.^2), g, 'same');
% Iy2 = conv2(double(Iy.^2), g, 'same');
% Ixy = conv2(double(Ix.*Iy), g, 'same');
Ix2 = Ix.^2;
Iy2 = Iy.^2;
Ixy = Ix.*Iy;

% Harris measure
if(sol == 1)
    % sol 1
    R = (Ix2.*Iy2 - Ixy.^2)./(Ix2+Iy2+eps);
    thres = thres1;
elseif (sol == 2)
    % sol 2
    k=0.04;
    R= (Ix2.*Iy2 - Ixy.^2) - k*(Ix2 + Iy2).^2;
    %normalize R so threshold can be a value between 0 and 1 
    minr = min(min(R));
    maxr = max(max(R));
    R = (R - minr) / (maxr - minr);
    thres = thres2;
end

% find local maxima
maxima = ordfilt2(R, score^2, ones(score));
harrisP = (R == maxima) & (R > thres);
[r, c] = find(harrisP);

%% take features
if num_sub_win > size(r,1)
    num_sub_win = size(r,1);
end

x1 = round(dis_fr_bound+search_size/2);
x5 = cols-x1;
x3 = round(cols/2);
x2 = round((x1+x3)/2);
x4 = round((x3+x5)/2);
y1 = x1; y2 = rows/3;
[l ~ ]=size(c);
corners = zeros(num_sub_win,2);
max_R = zeros(num_sub_win,1);
for i=1:size(r,1)
    if r(i)>=y1 && r(i)<=y2 && r(i)~=0 && c(i)~=0
        area = 0;
        if c(i)>=x1 && c(i)<x2
            area = 1;
        elseif c(i)>=x2 && c(i)<x3
            area = 2;
        elseif c(i)>=x3 && c(i)<x4
            area = 3;
        elseif c(i)>=x4 && c(i)<=x5
            area = 4;
        end
        if area > 0 && max_R(area,1) < R(r(i),c(i))
            max_R(area,1) = R(r(i),c(i));
            corners(area,1) = r(i);            
            corners(area,2) = c(i);
        end
    end
end

for i=1:4
    if corners(i,2)>=x1
        sub_win = [sub_win; corners(i,1) corners(i,2)];
    end
end

% for i=1:l
%     if (c(i)>=x1 && c(i)<=x2 && r(i)>=y1 && r(i)<=y2)
%         rT = r(i); cT = c(i);
%         corner_r = [corner_r; [rT cT R(i)]];
%     end
% end

% score = corner_r(:, 3);
% [~, order_score] = sort(score, 'descend');

% for i=1:num_sub_win
%     sub_win = [sub_win; corner_r(order_score(i),1) corner_r(order_score(i),2)];
% end
end

% version 1: fix sub wins
% function sub_win = initSubWin(rows, cols,...
%     dis_fr_bound,search_size,sub_size,num_sub_win)
% sub_win = [];
% if num_sub_win == 8
%     r1 = round(dis_fr_bound+search_size/2);c1 = r1;
%     sub_win = [sub_win; r1 c1];
%     r2 = r1;c2 = round(cols/2);
%     sub_win = [sub_win; r2 c2];
%     r3 = r1;c3 = cols-c1;
%     sub_win = [sub_win; r3 c3];
%     r4 = round(rows/2);c4 = c1;
%     sub_win = [sub_win; r4 c4];
%     r5 = r4;c5 = c3;
%     sub_win = [sub_win; r5 c5];
%     r6 = rows-r1;c6 = c1;
%     sub_win = [sub_win; r6 c6];
%     r7 = r6;c7 = c2;
%     sub_win = [sub_win; r7 c7];
%     r8 = r6;c8 = c3;
%     sub_win = [sub_win; r8 c8];
% else
%     if num_sub_win == 6
%         r1 = round(dis_fr_bound+search_size/2);c1 = r1;
%         sub_win = [sub_win; r1 c1];
%         r2 = r1;c2 = round(cols/2);
%         sub_win = [sub_win; r2 c2];
%         r3 = r1;c3 = cols-c1;
%         sub_win = [sub_win; r3 c3];
%         r6 = rows-r1;c6 = c1;
%         sub_win = [sub_win; r6 c6];
%         r7 = r6;c7 = c2;
%         sub_win = [sub_win; r7 c7];
%         r8 = r6;c8 = c3;
%         sub_win = [sub_win; r8 c8];
%     else
%         if num_sub_win == 5
%             r1 = round(dis_fr_bound+search_size/2);c1 = r1;
%             sub_win = [sub_win; r1 c1];
%             r2 = r1;c2 = round(cols/2);
%             sub_win = [sub_win; r2 c2];
%             r3 = r1;c3 = cols-c1;
%             sub_win = [sub_win; r3 c3];
%             r4 = r1;c4 = round((c1+c2)/2);
%             sub_win = [sub_win; r4 c4];
%             r5 = r1;c5 = cols-c4;
%             sub_win = [sub_win; r5 c5];
%         end
%     end
% end
% end