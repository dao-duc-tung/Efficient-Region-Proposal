% version 1: translation model
function [dr,dc] = pyramidTung_v1(I, J, ITER_NO, PYRA_NO, corners, winSize)
%% build pyramid of I1 & I2
PYRA_NO = PYRA_NO+1;
[PyraI,PyraJ] = buildPyramid(I,J,PYRA_NO);

%% for each corner in corners
% u is a point(corner) in I1
% find its corresponding location v on I2
% winSize = winSize;
wx = winSize; wy = winSize;
new_corners = zeros(size(corners));

for t=1:size(corners,1)
    %% Initialization of pyramidal guess
    u = corners(t,:); % u = [x y]
    gx = 0; gy = 0;
    dx = 0; dy = 0;

    %% for L=PYRA_NO down to 0 with step of -1
    PYRA_NO = numel(PyraI);
    for L=PYRA_NO:-1:1
        IL = PyraI{L};
        [r,c,~] = size(IL);
        uL = round(u/2^(L-1));
        px = uL(1,2); py = uL(1,1);
        G = zeros(2,2);
        for x=px-wx:px+wx
            for y=py-wy:py+wy
                if(x<2 || y<2 || x>=c || y>=r) continue; end
                Ix = (IL(y,x+1)-IL(y,x-1))/2;
                Iy = (IL(y+1,x)-IL(y-1,x))/2;
                G = G + [Ix^2 Ix*Iy; Ix*Iy Iy^2];
            end
        end
        vx = 0; vy = 0;
        
        %% for k=1 to ITER_NO with step of 1
        first_loop = 1;
        JL = PyraJ{L};
        for k=1:ITER_NO
            if first_loop == 1
                first_loop = 0;
            else
                JL = translateImage(JL, gy+vy, gx+vx);
            end
            
            dI = IL - JL;
            b = zeros(2,1);
            for x=px-wx:px+wx
                for y=py-wy:py+wy
                    if(x<2 || y<2 || x>=c || y>=r) continue; end
                    Ix = (IL(y,x+1)-IL(y,x-1))/2;
                    Iy = (IL(y+1,x)-IL(y-1,x))/2;
                    b = b + [dI(y,x)*Ix; dI(y,x)*Iy];
                end
            end
            
            n = G\b;
            vx = vx + n(1,1);
            vy = vy + n(2,1);
        end
        
        dx = vx; dy = vy;
        if L>=2
            gx = 2*(gx + dx);
            gy = 2*(gy + dy);
        end
    end
    
    %% Final OF, location v of point on J
    dx = gx + dx;
    dy = gy + dy;
    vx = u(1,2) + dx;
    vy = u(1,1) + dy;
    
    new_corners(t,:) = [vy vx];
end

dr = 0; dc = 0;
for t=1:size(corners,1)
    dr = dr + new_corners(t,1)-corners(t,1);
    dc = dc + new_corners(t,2)-corners(t,2);
end
dr = round(dr/size(corners,1));
dc = round(dc/size(corners,1));

%% draw
tempI = drawSubWin(corners, winSize, I, 'red');
imS(tempI, 10);
tempI = drawSubWin(new_corners, winSize, J, 'green');
imS(tempI, 11);
tempI = drawSubWin(corners, winSize, J, 'red');
tempI = drawSubWin(new_corners, winSize, tempI, 'green');
imS(tempI, 12);
end