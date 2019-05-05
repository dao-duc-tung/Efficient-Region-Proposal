% version 2: find harris corner
function corners = initCorners(I1,dis_fr_bound)
if size(I1,3)>=3
    I1 = rgb2gray(I1);
end
im = I1;
[rows,cols,~]=size(I1);

num_sub_win = 4;
sol = 2;
sigma = 1;
radius = 2;
score = (2*radius+1);
thres1 = 10000;
thres2 = 0.1;

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
Ix2 = conv2(double(Ix.^2), g, 'same');
Iy2 = conv2(double(Iy.^2), g, 'same');
Ixy = conv2(double(Ix.*Iy), g, 'same');
% Ix2 = Ix.^2;
% Iy2 = Iy.^2;
% Ixy = Ix.*Iy;

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
% if num_sub_win > size(r,1)
%     num_sub_win = size(r,1);
% end

x1 = round(dis_fr_bound);
x5 = cols-x1;
x3 = round(cols/2);
x2 = round((x1+x3)/2);
x4 = round((x3+x5)/2);
y1 = x1; y2 = rows/3;
% [l ~ ]=size(c);
temp_corners = zeros(num_sub_win,2);
max_R = zeros(num_sub_win,1);

% for r=y1:y2
%     for c=x1:x5
%         tempR = R(r,c);
%         if(tempR > thres)
%             area = 0;
%             if c<x2
%                 area = 1;
%             elseif c>=x2 && c<x3
%                 area = 2;
%             elseif c>=x3 && c<x4
%                 area = 3;
%             elseif c>=x4
%                 area = 4;
%             end
%             if area > 0 && max_R(area,1) < tempR
%                 max_R(area,1) = tempR;
%                 temp_corners(area,1) = r;            
%                 temp_corners(area,2) = c;
%             end
%         end
%     end
% end

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
            temp_corners(area,1) = r(i);            
            temp_corners(area,2) = c(i);
        end
    end
end

corners = [];
for i=1:num_sub_win
    if temp_corners(i,2)>=x1
        corners = [corners; temp_corners(i,:)];
    end
end

end