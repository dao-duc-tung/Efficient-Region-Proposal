%% initialize
clear; warning off;
pIn = 'E:\DAO DUC TUNG\TestBMS\src_ETHZ';
pOut = 'E:\DAO DUC TUNG\TestBMS\output_ROI_MODE_3';
pLabel = 'E:\DAO DUC TUNG\TestBMS\src_ETHZ\lp-annot.idl';
%% solutions used to get moving area
% 0: Edge Map (for Cross Correlation)
% 1: Vertical Gradient
% 2: Magnitude Gradient
% 3: Gray Image
MOVING_AREA_SOLUTION = 1;
%% FIX_SIZE_MODE
% 1: fix size of ROI (96x192)
% 0: fluctuate size of ROI (scanning based on vanishing line) % BEST 0
FIX_SIZE_MODE = 0;
%% PROB_FUNC
% 0: PROB = MovingPixel*MATCH*MATCH/(HOR*VER);
% 1: PROB = VER;
% 2: PROB = VER*VER*LegPart; % BEST 2
% 3: PROB = VER*LEG_PART;
PROB_FUNC = 2;
%% BINARY THRESHOLD & NMS_THRESHOLD & MAX_NUM_ROI
NMS_THRES = 0.4; % BEST 0.4
CUTOFF = 0;
SCORE_THRESH = [0];
NUM_PART_SCORE_THRESH = 10;
%% get file list
D = dir(fullfile(pIn,'*.png'));
file_list = {D.name};
%% init RECALL_ALL, FPR_ALL, PREC_ALL
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
        name1 = file_list{t-1};
        name2 = file_list{t};
        %% read image
        I1 = rgb2gray(imread(fullfile(pIn,name1)));
        I2 = rgb2gray(imread(fullfile(pIn,name2)));
        %% get Translation Vector
        [dr,dc] = getTransVector_v3(I1,I2);
        %% get moving area
        MovingArea = getMovingArea_v2(I1,I2,dr,dc,MOVING_AREA_SOLUTION);
        %% generate ROI
        [pROI,nROI] = genROI_Moving(name1,name2,pIn,pOut,pLabel,...
            MovingArea,NMS_THRES,CUTOFF,FIX_SIZE_MODE,PROB_FUNC);
        %% evaluate ROI
        [~,tp,fp,tn,fn,num_ped] = evaluateROI_v2(pIn,pLabel,name2,pROI,nROI);
        %% save evaluated result
        TP = [TP; tp]; FP = [FP; fp];
        TN = [TN; tn]; FN = [FN; fn];
        NUM_PED = [NUM_PED; num_ped];
        ROI_SET = [ROI_SET; pROI];
        %% save evalImg and CSPArea Image
%         imwrite(evalImg,fullfile(pOut,name2));
%         imwrite(MovingArea,fullfile(pOut,strcat(name2(1:end-4),'-Move',name2(end-3:end))));
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

%% save and draw ROC curve
saveROCCurve_Moving
% drawROC(RECALL_ALL,PREC_ALL,FPR_ALL);