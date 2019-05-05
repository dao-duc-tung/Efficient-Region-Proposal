% p = 'car1.png';
p = 'E:\DAO DUC TUNG\TestBMS\src_Caltech\V000_frame_0383.bmp';
im = imread(p);
im = rgb2gray(im);

sol = 2;
sigma = 1;
radius = 2;
order = (2*radius+1);
thres1 = 10000;
thres2 = 0.48;

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
maxima = ordfilt2(R, order^2, ones(order));
harrisP = (R == maxima) & (R > thres);
[rows, cols] = find(harrisP);

figure(5), imshow(im),hold on,
plot(cols, rows,'gs'), title('harris corners');
hold off;