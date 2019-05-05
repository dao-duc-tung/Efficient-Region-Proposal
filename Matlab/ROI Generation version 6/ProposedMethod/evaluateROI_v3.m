function [outImg,TP,FP,TN,FN,NUM_PED] = evaluateROI_v3(pIn,pLabel,name2,pROI,nROI)
%% get PedCoor
OVERLAP_ROI = 0.75;
PedCoor = getPedCoor_v2(pLabel, name2);
NUM_PED = size(PedCoor, 1);
% GIVEN_ROI = size(pROI,1)+size(nROI,1);
TP=0; FP=0; TN=0; FN=0;
I = imread(fullfile(pIn,name2));

%% check TP & FP
pedIsDetected = zeros(1,size(PedCoor,1));
for i=1:size(pROI,1)
    % check true roi
    true_roi = 0;
    for k=1:NUM_PED
        if pedIsDetected(k)==1
            continue;
        end
        if(evaluateRoiVsPed(pROI(i,:),PedCoor(k,:),OVERLAP_ROI) == 1)
            true_roi = 1;
            pedIsDetected(k) = 1;
        end
    end
    x1 = int32(pROI(i, 1)); y1 = int32(pROI(i, 2));
    x2 = int32(pROI(i, 3)); y2 = int32(pROI(i, 4));
    if(true_roi == 1)
        TP=TP+1;
        I = insertShape(I, 'rectangle',...
        [x1 y1 (x2-x1) (y2-y1)],'Color', 'green', 'LineWidth', 2);
    else
        FP=FP+1;
        I = insertShape(I, 'rectangle',...
            [x1 y1 (x2-x1) (y2-y1)],'Color', 'magenta', 'LineWidth', 1);
    end
end

%% check TN & FN
tempDetectedPed = pedIsDetected; % for drawing miss ped
for i=1:size(nROI,1)
    % check true roi
    true_roi = 0;
    for k=1:NUM_PED
        if pedIsDetected(k)==1
            continue;
        end
        if(evaluateRoiVsPed(nROI(i,:),PedCoor(k,:),OVERLAP_ROI) == 1)
            true_roi = 1;
            pedIsDetected(k) = 1;
        end
    end
    if(true_roi == 1)
        FN=FN+1;
    else
        TN=TN+1;
    end
end

%% draw ped
miss_ped = 0;
for k=1:NUM_PED
    if(tempDetectedPed(k)==0)
        miss_ped=miss_ped+1;
        I = insertShape(I, 'rectangle',...
        [PedCoor(k,1) PedCoor(k,2) (PedCoor(k,3)-PedCoor(k,1)) (PedCoor(k,4)-PedCoor(k,2))],'Color', 'red', 'LineWidth', 1);
    else
        I = insertShape(I, 'rectangle',...
        [PedCoor(k,1) PedCoor(k,2) (PedCoor(k,3)-PedCoor(k,1)) (PedCoor(k,4)-PedCoor(k,2))],'Color', 'blue', 'LineWidth', 1);
    end
end

I = insertText(I, [10 10],...
    strcat('missPed=',num2str(miss_ped),',FP=',num2str(FP),'/',num2str(size(pROI,1))),...
    'FontSize', 20);

%% output
outImg = I;
% outImg=[];

end