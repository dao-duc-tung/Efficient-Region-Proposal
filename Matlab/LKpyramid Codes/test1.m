%% init image
% p1 = '001.png';
% p2 = '002.png';
p1 = 'car1.png';
p2 = 'car2.png';
I1 = impyramid( imInit(p1), 'reduce' );
I2 = impyramid( imInit(p2), 'reduce' );
% I1 = impyramid( imInit(p1), 'reduce' );
% I2 = impyramid( imInit(p2), 'reduce' );

% I1 = impyramid( im2double( edgeSobel(imread(p1),120)), 'reduce' );
% I2 = impyramid( im2double( edgeSobel(imread(p2),120)), 'reduce' );

%% calculate OF for the whole image
winSize = 5;
ITER_NO = 5;
PYRE_NO = 5;
[flowHor flowVer] = pyramidFlow(I1, I2, winSize, ITER_NO, PYRE_NO);  %pyramidFlow( I1, I2, winSize, ITER_NO, PYRE_NO )

%% choose 3 features
oriI = imread(p2);
If = double(rgb2gray(oriI));
threshold = 0.25;
sigma=2; k = 0.04;
dx = [-1 0 1; -1 0 1; -1 0 1]/6;%derivative mask
dy = dx';
Ix = conv2(If, dx, 'same');   
Iy = conv2(If, dy, 'same');
g = fspecial('gaussian',fix(6*sigma), sigma); %Gaussien Filter
Ix2 = conv2(Ix.^2, g, 'same');  
Iy2 = conv2(Iy.^2, g, 'same');
Ixy = conv2(Ix.*Iy, g,'same');
R= (Ix2.*Iy2 - Ixy.^2) - k*(Ix2 + Iy2).^2;
%normalize R so threshold can be a value between 0 and 1 
minr = min(min(R));
maxr = max(max(R));
R = (R - minr) / (maxr - minr);
%compute the local maxima of R above a threshold 5-by-5 windows
maxima = ordfilt2(R, 25, ones(5));
mask = (R == maxima) & (R > threshold);
maxima = mask.*R;
% plot feature on image
figure(3) 
colormap('gray');
imagesc(oriI);
hold on;
[r,c] = find(maxima>0);


[l ~ ]=size(c);
corners = cell(1,l);
tempI = 1;
for i=1:l
%     if (i == 61 || i == 68)
%         corners{tempI} = [r(i) c(i)];
%         tempI = tempI+1;
%     end
    % get corner 108th and 104th
    if (i == 33 || i == 80 || i == 92)
        corners{tempI} = round([r(i) c(i)]/2);
        tempI = tempI+1;
        plot(c(i),r(i),'*');
    end
end

hold off;

%% get egomotion
us=0;vs=0;
for i=1:tempI-1
    us=us+flowHor(corners{i}(1), corners{i}(2));
    vs=vs+flowVer(corners{i}(1), corners{i}(2));
end
us=us/(tempI-1);vs=vs/(tempI-1);

%% compensate egomotion
[rows, cols, ~] = size(I2);
Iw1 = zeros(rows, cols);
for a=1:rows
    for b=1:cols
        y=round(a+vs);
        x=round(b+us);
        if(y>=1&&x>=1&&y<=rows&&x<=cols)
            Iw1(a,b) = I1(y,x);
        end
    end
end
imS(Iw1,10);
imS((Iw1-I2)>0.4,11);
