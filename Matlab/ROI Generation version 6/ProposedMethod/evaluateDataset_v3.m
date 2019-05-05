function [RECALL,PREC,FPR,NUM_PED_SUM,TP_SUM,FP_SUM,TN_SUM,FN_SUM,AVG_TEMPLATE]=evaluateDataset_v3(TP,FP,TN,FN,NUM_PED,ROI_SET)
TP_SUM = sum(TP(:));
FP_SUM = sum(FP(:));
TN_SUM = sum(TN(:));
FN_SUM = sum(FN(:));
NUM_PED_SUM = sum(NUM_PED(:));

RECALL = TP_SUM/NUM_PED_SUM*100;
PREC = TP_SUM/(TP_SUM+FP_SUM)*100;
FPR = FP_SUM/(FP_SUM+TN_SUM)*100;

%% calculate the average number of template in each image
NUM_TEMPLATE_PER_TYPE=[1 9 32 61 123 221 321 472 637];
% 1: 64x128, 2:72x144, 3:80x160, 4:88x176, 5:96x192
% 6: 104x208, 7:112x224, 8:120x240, 9:128x256
type = 0; 
total_template = 0;
for i=1:size(ROI_SET,1)
    x1 = int32(ROI_SET(i, 1)); y1 = int32(ROI_SET(i, 2));
    x2 = int32(ROI_SET(i, 3)); y2 = int32(ROI_SET(i, 4));
    w = x2-x1+1; h = y2-y1+1;
    switch w
        case 64, type=1;
        case 72, type=2;
        case 80, type=3;
        case 88, type=4;
        case 96, type=5;
        case 104, type=6; 
        case 112, type=7;
        case 120, type=8;
        case 128, type=9;
        otherwise, type=1;
    end
    total_template=total_template + NUM_TEMPLATE_PER_TYPE(type);
end

AVG_TEMPLATE=total_template/size(TP,1);

end