function MovingArea = getMovingArea_v2(I1,I2,dr,dc,MOVING_AREA_SOLUTION)
%% solution 1
% match 2 images
% It = translateImage(I1,dr,dc);
% It = imdilate(It, strel('square', 2));
% MovingArea = I2 - It&I2;

% erode portions seperately
% [rows,cols,~]=size(MovingArea);
% c1=1; c2=round(cols/6); c3=round(cols*5/6); c4=cols;
% erode_square = 1;
% if dc > 0
%     MovingArea(1:rows,c1:c3) = imerode(MovingArea(1:rows,c1:c3), strel('square', erode_square));
%     MovingArea(1:rows,c3:c4) = imerode(MovingArea(1:rows,c3:c4), strel('square', erode_square+1));
% else
%     MovingArea(1:rows,c1:c2) = imerode(MovingArea(1:rows,c1:c2), strel('square', erode_square+1));
%     MovingArea(1:rows,c2:c4) = imerode(MovingArea(1:rows,c2:c4), strel('square', erode_square));
% end

if MOVING_AREA_SOLUTION==0
    %% solution 0: apply on edge map
    [~,~,I1Edge] = edgeSobel(I1, 90);
    [~,~,I2Edge] = edgeSobel(I2, 90);
    It = translateImage(I1Edge,dr,dc);
    It = imdilate(It, strel('square', 3));
    Imatch = It&I2Edge;
    MovingArea = I2Edge-Imatch;
    MovingArea = imerode(MovingArea, strel('square', 3));
    MovingArea = imdilate(MovingArea, strel('square', 3));
elseif MOVING_AREA_SOLUTION==1
    %% solution 1: apply on vertical gradient
    I1VerGrad=2*abs(gradient(double(I1)));
    I2VerGrad=2*abs(gradient(double(I2)));
    It = translateImage(I1VerGrad,dr,dc);
    MovingArea = It-I2VerGrad;
    
    thres=20; % BEST 20
    MovingArea=MovingArea>thres;
    MovingArea = imerode(MovingArea, strel('square', 2));
    MovingArea = imdilate(MovingArea, strel('square', 3));
elseif MOVING_AREA_SOLUTION==2
    %% solution 2: apply on magnitude gradient
    [I1MagGrad,~]=imgradient(I1);
    [I2MagGrad,~]=imgradient(I2);
    It = translateImage(I1MagGrad,dr,dc);
    MovingArea = It-I2MagGrad;
    MovingArea = 2*MovingArea;
    
    thres=100;
    MovingArea=MovingArea>thres;
    MovingArea = imerode(MovingArea, strel('square', 2));
    MovingArea = imdilate(MovingArea, strel('square', 3));
elseif MOVING_AREA_SOLUTION==3
    %% solution 3: apply on gray image
    I1 = double(I1);I2 = double(I2);
    It = translateImage(I1,dr,dc);
%     MovingArea = abs(It - I2);
    MovingArea = It - I2;

    thres = 40; % BEST 40
    MovingArea=MovingArea>thres;
    MovingArea = imerode(MovingArea, strel('square', 2));
    MovingArea = imdilate(MovingArea, strel('square', 3));
end

end