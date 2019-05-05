%% initialize
clear; warning off;
pIn = 'E:\DAO DUC TUNG\TestBMS\src_ETHZ';
pOut = 'E:\DAO DUC TUNG\TestBMS\output_ROI_MODE_5';
pLabel = 'E:\DAO DUC TUNG\TestBMS\src_ETHZ\lp-annot.idl';
%% FIX_SIZE_MODE
% 1: fix size of ROI (96x192)
% 0: fluctuate size of ROI (scanning based on vanishing line)
FIX_SIZE_MODE = 0;
%% PROB_FUNC
% 1: PROB = VER; 
% 2: PROB = MAG; % removed
% PROB_FUNC = 1;
%% BINARY THRESHOLD & NMS_THRESHOLD & MAX_NUM_ROI
NMS_THRES = 1; % No NMS for this version
CUTOFF = 0;
SCORE_THRESH = [0];
NUM_PART_SCORE_THRESH = 20;
%% get file list
D = dir(fullfile(pIn,'*.png'));
file_list = {D.name};
%% RECALL_ALL, FPR_ALL, PREC_ALL
RECALL_ALL=[]; FPR_ALL=[]; PREC_ALL=[]; NUM_PED_ALL=[];
TP_ALL=[]; FP_ALL=[]; TN_ALL=[]; FN_ALL=[]; AVG_TEMPLATE_ALL=[];
%% run for each threshold based on score
num_running = 0;
first_run = 1;
while(num_running < size(SCORE_THRESH,1))
    %% gen ROI
    num_running = num_running+1;
    CUTOFF = SCORE_THRESH(num_running,1);
    num_running
    TP=[]; FP=[]; TN=[]; FN=[]; NUM_PED=[]; ROI_SET=[];
    for t = 5:4:(numel(file_list))-105
        %% get name
        name2 = file_list{t};
        %% generate ROI
        [pROI,nROI] = genROI_NoMoving_v3(name2,pIn,pLabel,...
            NMS_THRES,CUTOFF,FIX_SIZE_MODE);
        %% evaluate ROI
        [~,tp,fp,tn,fn,num_ped] = evaluateROI_v2(pIn,pLabel,name2,pROI,nROI);
        %% save evaluated result
        TP = [TP; tp]; FP = [FP; fp];
        TN = [TN; tn]; FN = [FN; fn];
        NUM_PED = [NUM_PED; num_ped];
        ROI_SET = [ROI_SET; pROI];
        %% save evalImg and CSPArea Image
%         imwrite(evalImg,fullfile(pOut,name2));
        name2
    end
    %% update SCORE_THRESH
    if first_run == 1
        maxS = max(ROI_SET(:,5)); minS = min(ROI_SET(:,5));
        unit = (maxS-minS)/NUM_PART_SCORE_THRESH;
        for k=1:NUM_PART_SCORE_THRESH
            SCORE_THRESH=[SCORE_THRESH; minS+k*unit];
        end
        first_run = 0;
    end
    %% calculate MISSRATE, RECALL, PRECISION, FPR
    [RECALL,PREC,FPR,NUM_PED_SUM,TP_SUM,FP_SUM,TN_SUM,FN_SUM,AVG_TEMPLATE] = evaluateDataset_v2(TP,FP,TN,FN,NUM_PED,ROI_SET);
    AVG_TEMPLATE_ALL = [AVG_TEMPLATE_ALL; AVG_TEMPLATE];
    RECALL_ALL = [RECALL_ALL; RECALL];
    PREC_ALL = [PREC_ALL; PREC];
    FPR_ALL = [FPR_ALL; FPR];
    NUM_PED_ALL = [NUM_PED_ALL; NUM_PED_SUM];
    TP_ALL = [TP_ALL; TP_SUM];
    FP_ALL = [FP_ALL; FP_SUM];
    TN_ALL = [TN_ALL; TN_SUM];
    FN_ALL = [FN_ALL; FN_SUM];
end
%% draw ROC curve
saveROCCurve_StaticFeature
% drawROC(RECALL_ALL,PREC_ALL,FPR_ALL);