%% initialize
clear; warning off;
pIn = 'E:\DAO DUC TUNG\TestBMS\src_ETHZ';
pOut = 'E:\DAO DUC TUNG\TestBMS\output_ROI_MODE_10';
pLabel = 'E:\DAO DUC TUNG\TestBMS\src_ETHZ\lp-annot.idl';
%% MODE
% 0: full annotated ped
% 1: remove far and near boundary ped
% 2: remove far, near boundary ped and deviate all
MODE = 2;
%% get file list
D = dir(fullfile(pIn,'*.png'));
file_list = {D.name};
%% run
for t = 5:4:(numel(file_list))-105
    name2 = file_list{t};
    annImg = drawPed(pIn,pLabel,name2,MODE);
    imwrite(annImg,fullfile(pOut,name2));
    name2
end