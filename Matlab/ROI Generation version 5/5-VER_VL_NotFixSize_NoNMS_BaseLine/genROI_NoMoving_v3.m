function [pROI,nROI] = genROI_NoMoving_v3(name2,pIn,pLabel,...
        NMS_THRES,CUTOFF,FIX_SIZE_MODE)
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
ROW_STEP_WINDOW = 16; COL_STEP_WINDOW = 8;

if FIX_SIZE_MODE==1
    WIDTH_ROI = MAX_WIDTH; HEIGHT_ROI = MAX_HEIGHT;
    x1_center = 1;      y1_center = round(vanishing_line-HEIGHT_ROI/2);
    x2_center = cols;   y2_center = vanishing_line+HEIGHT_ROI;
    for r=y1_center:ROW_STEP_WINDOW:y2_center-HEIGHT_ROI
        for c=x1_center:COL_STEP_WINDOW:x2_center-WIDTH_ROI
            % get the sliding window
            y1 = r; x1 = c;
            y2 = r+HEIGHT_ROI-1; x2 = c+WIDTH_ROI-1;
            % VER
            ver_grad_win = I2_Ver_Grad(y1:y2, x1:x2);
            VER = sum(ver_grad_win(:));
            % save
            PROB = VER;
            ROI = [ROI; [x1 y1 x2 y2 PROB]];
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
                % get the sliding window which has moving edges
                y1 = r; x1 = c;
                y2 = r+HEIGHT_ROI-1; x2 = c+WIDTH_ROI-1;
                % VER
                ver_grad_win = I2_Ver_Grad(y1:y2, x1:x2);
                VER = sum(ver_grad_win(:));
                % save
                PROB = VER/(WIDTH_ROI*HEIGHT_ROI);
                ROI = [ROI; [x1 y1 x2 y2 PROB]];
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