% function saveROCCurve(pOut,SCORE_THRESH,RECALL_ALL,PREC_ALL,FPR_ALL,NUM_PED_ALL)
%% save evaluated result to file
fileID = fopen(fullfile(pOut,'evaluation.txt'),'w'); 

fprintf(fileID, 'SCORE_THRESH\t\tTP\t\tFP\t\tTN\t\tFN\t\tFPR\t\tTPR\t\tPRE\t\tAVG_TEMPLATE\tNUM_PED\n');
for i=1:size(SCORE_THRESH,1)
    fprintf(fileID, '%15.2f\t\t%d\t\t%d\t\t%d\t\t%d\t\t%.4f\t%.4f\t%.4f\t%.4f\t%d;...\n',...
        SCORE_THRESH(i,1),...
        TP_ALL(i,1),FP_ALL(i,1),TN_ALL(i,1),FN_ALL(i,1),...
        FPR_ALL(i,1),RECALL_ALL(i,1),PREC_ALL(i,1),...
        AVG_TEMPLATE_ALL(i,1),NUM_PED_ALL(i,1));
end

fprintf(fileID, 'FIX_SIZE_MODE=%d\n', FIX_SIZE_MODE);
fprintf(fileID, 'PROB_FUNC=VER\n');
fprintf(fileID, 'NMS_THRES=%d\n', NMS_THRES);

fclose(fileID);
% end    