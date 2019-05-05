%% initialize
clear; warning off;
pIn = 'E:\DAO DUC TUNG\TestBMS\src_ETHZ';
pOut = 'E:\DAO DUC TUNG\TestBMS\output_ROI_MODE_6';
pLabel = 'E:\DAO DUC TUNG\TestBMS\src_ETHZ\lp-annot.idl';
%% get file list
D = dir(fullfile(pIn,'*.png'));
file_list = {D.name};
%%
NUM_ROI = 20;
TP=[]; FP=[]; TN=[]; FN=[]; NUM_PED=[]; ROI_SET=[];
%% run
for t = 37:4:(numel(file_list))-105
    %% get name
    name1 = file_list{t-1};
    name2 = file_list{t};
    %% read image
    I1 = rgb2gray(imread(fullfile(pIn,name1)));
    I2 = rgb2gray(imread(fullfile(pIn,name2)));
    %% get Translation Vector
    [dr,dc,ItransVector] = getTransVector_PM(I1,I2);
    %% get moving area
    MovingArea = getMovingArea_PM(I1,I2,dr,dc);
    %% generate ROI
    [pROI,nROI] = genROI_PM(name2,pIn,pLabel,MovingArea,NUM_ROI);
    %% evaluate ROI
    [evalImg,tp,fp,tn,fn,num_ped] = evaluateROI_v3(pIn,pLabel,name2,pROI,nROI);
    %% save evaluated result
    TP = [TP; tp]; FP = [FP; fp];
    TN = [TN; tn]; FN = [FN; fn];
    NUM_PED = [NUM_PED; num_ped];
    ROI_SET = [ROI_SET; pROI];
    %% save evalImg and CSPArea Image
    imwrite(evalImg,fullfile(pOut,name2));
    imwrite(MovingArea,fullfile(pOut,strcat(name2(1:end-4),'-Move',name2(end-3:end))));
    imwrite(ItransVector,fullfile(pOut,strcat(name2(1:end-4),'-Trans',name2(end-3:end))));
    name2
end
%% evaluate
[RECALL,PREC,FPR,NUM_PED_SUM,TP_SUM,FP_SUM,TN_SUM,FN_SUM,AVG_TEMPLATE] = evaluateDataset_v3(TP,FP,TN,FN,NUM_PED,ROI_SET);
saveEvaluation;