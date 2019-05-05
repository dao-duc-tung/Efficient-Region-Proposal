%% init
clear; warning off;
I = imread('image_00005439_0.png');
J = imread('image_00005440_0.png');

%% divide image into 14x14 grid-image
gridSize = 0;
if gridSize > 1
    gImg1 = getGridImage(I, gridSize);
    gImg2 = getGridImage(J, gridSize);
else
    gImg1 = I;
    gImg2 = J;
end

%% define good features to track (Harris Corners)
tempImg = gImg1;
[gR,gC,~] = size(tempImg);
dis_fr_bound = floor(gC/128)+1;
sub_size = floor(gC/32)+1;
search_size = sub_size*3;
corners = initCorners(tempImg,dis_fr_bound+search_size/2);
% corners(size(corners,1),:) = [];

new_corners = zeros(size(corners));

%% Start KLT Tracker %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
windowSize = 21;
delta_p = 7;
sigma = 3;
[xder,yder]=ndgrid(floor(-3*sigma):ceil(3*sigma),floor(-3*sigma):ceil(3*sigma));
DGaussx=-(xder./(2*pi*sigma^4)).*exp(-(xder.^2+yder.^2)/(2*sigma^2));
DGaussy=-(yder./(2*pi*sigma^4)).*exp(-(xder.^2+yder.^2)/(2*sigma^2));
Threshold = 0.01;
for t = 1:size(corners,1)
    p = [0 0 0 0 corners(t,1) corners(t,2)];
    T = gImg1(corners(t,1)-windowSize:corners(t,1)+windowSize,corners(t,2)-windowSize:corners(t,2)+windowSize);
    T= double(T);
    [x,y]=ndgrid(0:size(T,1)-1,0:size(T,2)-1);
    TemplateCenter=size(T)/2;
    x=x-TemplateCenter(1); y=y-TemplateCenter(2);
   
    NextFrame = gImg2;
    if size(NextFrame,3)>=3
        NextFrame=rgb2gray(NextFrame);
    end
    I_nextFrame= double(NextFrame); 
    Ix_grad = imfilter(I_nextFrame,DGaussx,'conv');
    Iy_grad = imfilter(I_nextFrame,DGaussy,'conv');
    counter = 0;
    while ( norm(delta_p) > Threshold)
        counter= counter + 1;
        if(counter > 80)
            break;
        end
        W_p = [ 1+p(1) p(3) p(5); p(2) 1+p(4) p(6)];
        I_warped = warpping(I_nextFrame,x,y,W_p);
        I_error= T - I_warped;
        if((p(5)>(size(I_nextFrame,1))-1)||(p(6)>(size(I_nextFrame,2)-1))||(p(5)<0)||(p(6)<0)), break; end
        Ix =  warpping(Ix_grad,x,y,W_p);   
        Iy = warpping(Iy_grad,x,y,W_p); 
        W_Jacobian_x=[x(:) zeros(size(x(:))) y(:) zeros(size(x(:))) ones(size(x(:))) zeros(size(x(:)))];
        W_Jacobian_y=[zeros(size(x(:))) x(:) zeros(size(x(:))) y(:) zeros(size(x(:))) ones(size(x(:)))];
        I_steepest=zeros(numel(x),6);
        for j1=1:numel(x),
            W_Jacobian=[W_Jacobian_x(j1,:); W_Jacobian_y(j1,:)];
            Gradient=[Ix(j1) Iy(j1)];
            I_steepest(j1,1:6)=Gradient*W_Jacobian;
        end
        H=zeros(6,6);
        for j2=1:numel(x), H=H+ I_steepest(j2,:)'*I_steepest(j2,:); end
        total=zeros(6,1);
        for j3=1:numel(x), total=total+I_steepest(j3,:)'*I_error(j3); end
        delta_p=H\total;
        p = p + delta_p';  
    end
    new_corners(t,:) = [p(5) p(6)];
end
%% Draw and Save all output frames (tracked frames)
rateR = size(I,1)/size(gImg1,1);
rateC = size(I,2)/size(gImg1,2);
corners(:,1) = corners(:,1) * rateR;
new_corners(:,1) = new_corners(:,1) * rateR;
corners(:,2) = corners(:,2) * rateC;
new_corners(:,2) = new_corners(:,2) * rateC;
windowSize = windowSize * rateR * 2;
tempI = drawSubWin(corners, windowSize, I, 'red');
imS(tempI, 10);
tempI = drawSubWin(new_corners, windowSize, J, 'green');
imS(tempI, 11);
tempI = drawSubWin(corners, windowSize, J, 'red');
tempI = drawSubWin(new_corners, windowSize, tempI, 'green');
imS(tempI, 12);
