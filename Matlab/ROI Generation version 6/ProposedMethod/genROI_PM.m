function [pROI,nROI] = genROI_PM(name2,pIn,pLabel,MovingArea,NUM_ROI)
NMS_THRES = 0.4;
MIN_PIXEL_ROI = 50;
MIN_PIXEL_LEG = 30;
I2 = rgb2gray(imread(fullfile(pIn,name2)));
[rows,cols,~] = size(I2);
[I2_Ver_Grad,~] = gradient(double(I2));
I2_Ver_Grad = 2*abs(I2_Ver_Grad);
vanishing_line = getVanishingLine(pLabel);
ROI=[]; pROI=[]; nROI=[];
%% gen ROI
MIN_WIDTH = 88; MIN_HEIGHT = 176;
% MAX_WIDTH = 96; MAX_HEIGHT = 192;
% MIN_WIDTH = 80; MIN_HEIGHT = 160;
MAX_WIDTH = 120; MAX_HEIGHT = 240;
% MAX_WIDTH = 128; MAX_HEIGHT = 256;

STEP_WIDTH = 8; STEP_HEIGHT = 16;
ROW_STEP_WINDOW = 8; COL_STEP_WINDOW = 4;
WIDTH_ROI = MIN_WIDTH; HEIGHT_ROI = MIN_HEIGHT;

while WIDTH_ROI<=MAX_WIDTH && HEIGHT_ROI<=MAX_HEIGHT
    x1_sliding = 1; x2_sliding = cols;
    y1_sliding = round(vanishing_line-HEIGHT_ROI/2);
    y2_sliding = vanishing_line+HEIGHT_ROI;
    for r=y1_sliding:ROW_STEP_WINDOW:y2_sliding-HEIGHT_ROI
        for c=x1_sliding:COL_STEP_WINDOW:x2_sliding-WIDTH_ROI
            %% get the sliding window
            y1 = r; x1 = c;
            y2 = r+HEIGHT_ROI-1; x2 = c+WIDTH_ROI-1;
            %% Moving Window & Leg Window
            MovingWindow = MovingArea(y1:y2, x1:x2);
            MovingPixel = sum(MovingWindow(:));
            MovingPixel_Nmz = double(MovingPixel)/size(MovingWindow,1)/size(MovingWindow,2);
            %% VER
%             ver_grad_win = I2_Ver_Grad(y1:y2, x1:x2);
%             VER = sum(ver_grad_win(:))/size(ver_grad_win,1)/size(ver_grad_win,2);

            ver_grad_win = I2_Ver_Grad(y1:y2, x1:x2);
            avg=sum(ver_grad_win(:))/size(ver_grad_win,1)/size(ver_grad_win,2);
            ver_grad_win(ver_grad_win<avg)=0;
            ver_grad_win(ver_grad_win>=avg)=1;
            VER = sum(ver_grad_win(:));
            VER_Nmz = double(VER)/size(ver_grad_win,1)/size(ver_grad_win,2);
            %% LEG_PART
%             leg_win = MovingWindow(round(4*HEIGHT_ROI/8):HEIGHT_ROI,1:WIDTH_ROI);
            leg_win = MovingWindow(round(4*HEIGHT_ROI/8):round(7*HEIGHT_ROI/8),round(WIDTH_ROI/4):round(3*WIDTH_ROI/4));
            LEG_PIXEL = sum(leg_win(:));
            LEG_PIXEL_Nmz = double(LEG_PIXEL)/size(leg_win,1)/size(leg_win,2);
            %% calculate score of ROI
%             PROB = VER*VER*LEG_PIXEL*MovingPixel/size(MovingWindow,1)/size(MovingWindow,2);
%             PROB = VER/size(MovingWindow,1)/size(MovingWindow,2);
            PROB = VER_Nmz*VER_Nmz*LEG_PIXEL_Nmz*MovingPixel_Nmz;

            %% save
            if MovingPixel<MIN_PIXEL_ROI || LEG_PIXEL<(MIN_PIXEL_LEG*size(MovingWindow,1)*size(MovingWindow,2)/8192)
                nROI = [nROI; [x1 y1 x2 y2 PROB]];
            else
                ROI = [ROI; [x1 y1 x2 y2 PROB]];
            end
        end
    end
    WIDTH_ROI=WIDTH_ROI+STEP_WIDTH;
    HEIGHT_ROI=HEIGHT_ROI+STEP_HEIGHT;
end
%% NMS
[filteredROI, removedROI] = nms_v2(ROI, NMS_THRES);
nROI = [nROI; removedROI];

%% get the first NUM_ROI ROIs
if NUM_ROI == 0
    pROI = [pROI; filteredROI];
else
    for i=1:size(filteredROI,1)
        if i<=NUM_ROI
            pROI = [pROI; filteredROI(i,:)];
        else
            nROI = [nROI; filteredROI(i,:)];
        end
    end
end

end