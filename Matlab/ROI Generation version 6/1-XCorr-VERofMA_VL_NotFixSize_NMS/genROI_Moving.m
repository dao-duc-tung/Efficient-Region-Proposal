function [pROI,nROI] = genROI_Moving(name1,name2,pIn,pOut,pLabel,...
    MovingArea,NMS_THRES,CUTOFF,FIX_SIZE_MODE,PROB_FUNC)
MIN_PIXEL_ROI = 20;
MIN_PIXEL_LEG = 5;
I2 = rgb2gray(imread(fullfile(pIn,name2)));
[rows,cols,~] = size(I2);
[I2_Ver_Grad,~] = gradient(double(I2));
I2_Ver_Grad = 2*abs(I2_Ver_Grad);
vanishing_line = getVanishingLine(pLabel);
ROI=[]; pROI=[]; nROI=[];

%% generate ROI with corresponding score
MIN_WIDTH = 72; MIN_HEIGHT = 144;
MAX_WIDTH = 96; MAX_HEIGHT = 192;
STEP_WIDTH = 8; STEP_HEIGHT = 16;
ROW_STEP_WINDOW = 8; COL_STEP_WINDOW = 4;

if FIX_SIZE_MODE==1
    WIDTH_ROI = MAX_WIDTH; HEIGHT_ROI = MAX_HEIGHT;
    x1_center = 1;      y1_center = round(vanishing_line-HEIGHT_ROI/2);
    x2_center = cols;   y2_center = vanishing_line+HEIGHT_ROI;
    for r=y1_center:ROW_STEP_WINDOW:y2_center-HEIGHT_ROI
        for c=x1_center:COL_STEP_WINDOW:x2_center-WIDTH_ROI
            %% get the sliding window
            y1 = r; x1 = c;
            y2 = r+HEIGHT_ROI-1; x2 = c+WIDTH_ROI-1;
            %% Moving Window & Leg Window
            MovingWindow = MovingArea(y1:y2, x1:x2);
            MovingPixel = sum(MovingWindow(:));
            %% VER
            ver_grad_win = I2_Ver_Grad(y1:y2, x1:x2);
            VER = sum(ver_grad_win(:));
            
            %% calculate score of ROI
            LEG_PART=0;
            if PROB_FUNC==1
                PROB = VER;
            elseif PROB_FUNC==2
                % LEG_PART
                leg_win = MovingWindow(round(5*HEIGHT_ROI/8):HEIGHT_ROI,1:WIDTH_ROI);
                LEG_PART = sum(leg_win(:));
                PROB = VER*VER*LEG_PART;
            elseif PROB_FUNC==3
                % LEG_PART
                leg_win = MovingWindow(round(5*HEIGHT_ROI/8):HEIGHT_ROI,1:WIDTH_ROI);
                LEG_PART = sum(leg_win(:));
                PROB = VER*LEG_PART;
            else
                PROB = 0;
            end
            
            %% save
            if MovingPixel<MIN_PIXEL_ROI || ...
                    (LEG_PART<MIN_PIXEL_LEG &&...
                    (PROB_FUNC==2 || PROB_FUNC==3))
                nROI = [nROI; [x1 y1 x2 y2 PROB]];
            else
                ROI = [ROI; [x1 y1 x2 y2 PROB]];
            end
        end
    end
elseif FIX_SIZE_MODE==0
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
                %% VER
                ver_grad_win = I2_Ver_Grad(y1:y2, x1:x2);
                VER = sum(ver_grad_win(:));
                
                %% calculate score of ROI
                LEG_PART=0;
                if PROB_FUNC==1
                    PROB = VER;
                elseif PROB_FUNC==2
                    % LEG_PART
                    leg_win = MovingWindow(round(5*HEIGHT_ROI/8):HEIGHT_ROI,1:WIDTH_ROI);
                    LEG_PART = sum(leg_win(:));
                    PROB = VER*VER*LEG_PART;
                elseif PROB_FUNC==3
                    % LEG_PART
                    leg_win = MovingWindow(round(5*HEIGHT_ROI/8):HEIGHT_ROI,1:WIDTH_ROI);
                    LEG_PART = sum(leg_win(:));
                    PROB = VER*LEG_PART;
                else
                    PROB = 0;
                end
                
                %% save
                if MovingPixel<MIN_PIXEL_ROI || ...
                        (LEG_PART<MIN_PIXEL_LEG &&...
                        (PROB_FUNC==2 || PROB_FUNC==3))
                    nROI = [nROI; [x1 y1 x2 y2 PROB]];
                else
                    ROI = [ROI; [x1 y1 x2 y2 PROB]];
                end
            end
        end
        WIDTH_ROI=WIDTH_ROI+STEP_WIDTH;
        HEIGHT_ROI=HEIGHT_ROI+STEP_HEIGHT;
    end
end

%% NMS
[filteredROI, removedROI] = nms_v2(ROI, NMS_THRES);
num_roi = size(filteredROI,1);
nROI = [nROI; removedROI];
for i=1:num_roi
    if filteredROI(i,5) < CUTOFF
        nROI=[nROI; filteredROI(i,:)];
    else
        pROI=[pROI; filteredROI(i,:)];
    end
end

end