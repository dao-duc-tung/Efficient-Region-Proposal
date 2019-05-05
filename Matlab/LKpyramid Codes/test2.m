clear all;
p1 = '5441.png';
p2 = '5442.png';
% p1 = 'E:\DAO DUC TUNG\TestBMS\src_Caltech\V000_frame_0383.bmp';
% p2 = 'E:\DAO DUC TUNG\TestBMS\src_Caltech\V000_frame_0384.bmp';
% I1 = impyramid( imInit(p1), 'reduce' );
% I2 = impyramid( imInit(p2), 'reduce' );
I1 = rgb2gray(imread(p1)); 
I2 = rgb2gray(imread(p2));
% I1 = edgeSobel(rgb2gray(imread(p1)),100); 
% I2 = edgeSobel(rgb2gray(imread(p2)),100);

windowSize = 31;
num_features = 25;
NO_ITER = 24;
num_figure = 5;

%% choose (num_features) features
orgI = I1;
If = double(orgI);
[rows, cols, ~] = size(If);
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
[r,c] = find(maxima>0);

% take num_features features
x1 = windowSize; x2 = cols-windowSize;
y1 = windowSize; y2 = rows/5; y3 = rows-y2; y4=rows-windowSize;
[l ~ ]=size(c);
corner_r = [];
for i=1:l
    if (c(i)>=x1 && c(i)<=x2 &&...
            (r(i)>=y1 &&r(i)<=y2)||(r(i)>=y3&&r(i)<=y4))
        rT = r(i); cT = c(i);
        corner_r = [corner_r; [rT cT R(i)]];
    end
end

temp = corner_r(:, 3);
[~, temp_I] = sort(temp, 'descend');
figure(num_figure), imshow(orgI),hold on,
if num_features > size(temp_I,1)
    num_features = size(temp_I,1);
end
corners = cell(1,num_features);
new_corners = cell(1,num_features);
for i=1:num_features
    corners{i} = [corner_r(temp_I(i),1) corner_r(temp_I(i),2)];
    plot(corner_r(temp_I(i),2), corner_r(temp_I(i),1),'rs');
end
hold off;


%% KLT Tracker
delta_p = 7;
sigma = 3;
%Make derivatives kernels
[xder,yder]=ndgrid(floor(-3*sigma):ceil(3*sigma),floor(-3*sigma):ceil(3*sigma));
DGaussx=-(xder./(2*pi*sigma^4)).*exp(-(xder.^2+yder.^2)/(2*sigma^2));
DGaussy=-(yder./(2*pi*sigma^4)).*exp(-(xder.^2+yder.^2)/(2*sigma^2));

for corner_i=1:num_features
    if (corners{corner_i}(1)-windowSize > 0 && corners{corner_i}(1)+windowSize <= rows && corners{corner_i}(2)-windowSize > 0 && corners{corner_i}(2)+windowSize < cols)
        % No rotation with initial postion
        p = [0 0 0 0 corners{corner_i}(1) corners{corner_i}(2)];
        % cut the window
        T = orgI(corners{corner_i}(1)-windowSize:corners{corner_i}(1)+windowSize,corners{corner_i}(2)-windowSize:corners{corner_i}(2)+windowSize);
        T= double(T);
        %Make all x,y indices
        [x,y]=ndgrid(0:size(T,1)-1,0:size(T,2)-1);
        %Calculate center of the template image
        TemplateCenter=size(T)/2;
        %Make center of the template image coordinates 0,0
        x=x-TemplateCenter(1); y=y-TemplateCenter(2);
        
        NextFrame = I2;
        NextFrameCopy = NextFrame;
        I_nextFrame= double(NextFrame); 
        % Filter the images to get the derivatives
        Ix_grad = imfilter(I_nextFrame,DGaussx,'conv');
        Iy_grad = imfilter(I_nextFrame,DGaussy,'conv');
        loop = 0;    
        %Threshold
        Threshold = 0.01;
        while ( norm(delta_p) > Threshold)
            loop= loop + 1;
            if(loop > NO_ITER) break; end
            %norm(delta_p)
            %The affine matrix for template rotation and translation
            W_p = [ 1+p(1) p(3) p(5); p(2) 1+p(4) p(6)];
            %1 Warp I with w
            I_warped = warpping(I_nextFrame,x,y,W_p);
            %2 Subtract I from T
            I_error= T - I_warped;
            % Break if outside image
            if((p(5)>(size(I_nextFrame,1))-1)||(p(6)>(size(I_nextFrame,2)-1))||(p(5)<0)||(p(6)<0)), break; end
            %3 Warp the gradient
            Ix = warpping(Ix_grad,x,y,W_p);   
            Iy = warpping(Iy_grad,x,y,W_p); 
            %4 Evaluate the Jacobian
            W_Jacobian_x=[x(:) zeros(size(x(:))) y(:) zeros(size(x(:))) ones(size(x(:))) zeros(size(x(:)))];
            W_Jacobian_y=[zeros(size(x(:))) x(:) zeros(size(x(:))) y(:) zeros(size(x(:))) ones(size(x(:)))];
            %5 Compute steepest descent
            I_steepest=zeros(numel(x),6);
            for j1=1:numel(x),
                W_Jacobian=[W_Jacobian_x(j1,:); W_Jacobian_y(j1,:)];
                Gradient=[Ix(j1) Iy(j1)];
                I_steepest(j1,1:6)=Gradient*W_Jacobian;
            end
            %6 Compute Hessian
            H=zeros(6,6);
            for j2=1:numel(x), H=H+ I_steepest(j2,:)'*I_steepest(j2,:); end
            %7 Multiply steepest descend with error
            total=zeros(6,1);
            for j3=1:numel(x), total=total+I_steepest(j3,:)'*I_error(j3); end
            %8 Computer delta_p
            delta_p=H\total;
            %9 Update the parameters p <- p + delta_p
             p = p + delta_p';  
        end
        new_corners{corner_i} = [p(5) p(6)];
    end
end

corners=cell2mat(corners);
new_corners=cell2mat(new_corners);
r_mean = 0; c_mean = 0;
figure(num_figure), imshow(I2),hold on,
to = num_features;
for i=1:2:to*2
    r1=corners(1,i);c1=corners(1,i+1);
    r2=new_corners(1,i);c2=new_corners(1,i+1);
    r_mean = r_mean + r2-r1;
    c_mean = c_mean + c2-c1;
    plot(c1,r1, 'rs');
    plot(c2,r2, 'gs');
    line([c1 c2],[r1 r2],'Color','green','LineStyle','-');
end
hold off;

%% match 2 image
r_mean = r_mean / num_features;
c_mean = c_mean / num_features;
I1 = edgeSobel(rgb2gray(imread(p1)),100); 
I2 = edgeSobel(rgb2gray(imread(p2)),100);
I1 = imdilate(I1, strel('square', 3));
Iw = imWarp(-c_mean, -r_mean, double(I1));
% Iw=uint8(Iw);
imS(Iw, num_figure+2);

% Idif = double(Iw)-I2;
% Idif = Idif > 0.1;
% Idif = imerode(Idif, strel('square', 3));
% Idif = imerode(Idif, strel('square', 2));

I2 = I2 - Iw&I2;

imS(I2, num_figure+3);
