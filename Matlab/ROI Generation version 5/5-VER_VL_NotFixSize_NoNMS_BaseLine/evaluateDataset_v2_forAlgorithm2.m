function [RECALL,PREC,FPR,NUM_PED_SUM,TP_SUM,FP_SUM,TN_SUM,FN_SUM,AVG_TEMPLATE]=evaluateDataset_v2(TP,FP,TN,FN,NUM_PED,ROI_SET)
TP_SUM = sum(TP(:));
FP_SUM = sum(FP(:));
TN_SUM = sum(TN(:));
FN_SUM = sum(FN(:));
NUM_PED_SUM = sum(NUM_PED(:));

RECALL = TP_SUM/(TP_SUM+FN_SUM)*100;
PREC = TP_SUM/(TP_SUM+FP_SUM)*100;
FPR = FP_SUM/(FP_SUM+TN_SUM)*100;

%% calculate the average number of template in each image
NUM_TEMPLATE_PER_TYPE=[3 7 14 22];
% 1: 72x144, 2: 80x160, 3: 88x176, 4: 96x192
type = 0; 
total_template = 0;
for i=1:size(ROI_SET,1)
    x1 = int32(ROI_SET(i, 1)); y1 = int32(ROI_SET(i, 2));
    x2 = int32(ROI_SET(i, 3)); y2 = int32(ROI_SET(i, 4));
    w = x2-x1; h = y2-y1;
    if w>70 && w<74
        type=1;
    elseif w>78 && w<82
        type=2;
    elseif w>86 && w<90
        type=3;
    elseif w>94 && w<98
        type=4;
    end
    total_template=total_template + NUM_TEMPLATE_PER_TYPE(type);
end

AVG_TEMPLATE=total_template/size(TP,1);

% AVG_TEMPLATE=size(ROI_SET,1)/size(TP,1);

end