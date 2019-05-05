% version 2: affine transformation (rotation, translation, resize)
function [dr,dc] = pyramidTung_v2(I, J, ITER_NO, PYRA_NO, corners, winSize)
%% build pyramid of I1 & I2
% PYRA_NO = PYRA_NO+1;
% [PyraI,PyraJ] = buildPyramid(I,J,PYRA_NO);

%% for each corner in corners
% u is a point(corner) in I1
% find its corresponding location v on I2
windowSize = winSize;
wx = windowSize; wy = windowSize;
new_corners = zeros(size(corners));

%Make derivatives kernels
Threshold = 0.01;
delta_p = 7;
sigma = 3;
[xder,yder]=ndgrid(floor(-3*sigma):ceil(3*sigma),floor(-3*sigma):ceil(3*sigma));
DGaussx=-(xder./(2*pi*sigma^4)).*exp(-(xder.^2+yder.^2)/(2*sigma^2));
DGaussy=-(yder./(2*pi*sigma^4)).*exp(-(xder.^2+yder.^2)/(2*sigma^2));

for t=1:size(corners,1)
    p = [0 0 0 0 corners(t,1) corners(t,2)];
    T = I(corners(t,1)-windowSize:corners(t,1)+windowSize,corners(t,2)-windowSize:corners(t,2)+windowSize);
    T= double(T);
    [x,y]=ndgrid(0:size(T,1)-1,0:size(T,2)-1);
    TemplateCenter=size(T)/2;
    x=x-TemplateCenter(1); y=y-TemplateCenter(2);
   
    NextFrame = J;
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

dr = 0; dc = 0;
counter = 0;
for t=1:size(corners,1)
    if isnan(new_corners(t,1)) || isnan(new_corners(t,2))
        continue;
    end
    counter = counter+1;
    dr = dr + new_corners(t,1)-corners(t,1);
    dc = dc + new_corners(t,2)-corners(t,2);
end
dr = round(dr/counter);
dc = round(dc/counter);

%% draw
tempI = drawSubWin(corners, winSize, I, 'red');
imS(tempI, 10);
tempI = drawSubWin(new_corners, winSize, J, 'green');
imS(tempI, 11);
tempI = drawSubWin(corners, winSize, J, 'red');
tempI = drawSubWin(new_corners, winSize, tempI, 'green');
imS(tempI, 12);

end