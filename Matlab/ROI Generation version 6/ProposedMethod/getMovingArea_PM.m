function MovingArea = getMovingArea_PM(I1,I2,dr,dc)
%% solution 1: apply on vertical gradient
    I1VerGrad=2*abs(gradient(double(I1)));
    I2VerGrad=2*abs(gradient(double(I2)));
    It = translateImage(I1VerGrad,dr,dc);
%     MovingArea = It-I2VerGrad;
    MovingArea = I2VerGrad-It;
    
    thres=20; % BEST 20
    MovingArea=MovingArea>thres;
    MovingArea = imerode(MovingArea, strel('square', 2));
    MovingArea = imdilate(MovingArea, strel('square', 3));

%     I1 = double(I1);I2 = double(I2);
%     It = translateImage(I1,dr,dc);
%     MovingArea = It - I2;
% 
%     thres = 40; % BEST 40
%     MovingArea=MovingArea>thres;
%     MovingArea = imerode(MovingArea, strel('square', 2));
%     MovingArea = imdilate(MovingArea, strel('square', 3));

end