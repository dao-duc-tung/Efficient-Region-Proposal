%% save evaluated result to file
fileID = fopen(fullfile(pOut,'evaluation.txt'),'w'); 

fprintf(fileID, 'RECALL=%.2f PREC=%.2f FPR=%.2f AVG_TEMPLATE=%.2f\n',...
    RECALL,PREC,FPR,AVG_TEMPLATE);
fprintf(fileID, 'TP=%d FP=%d TN=%d FN=%d NUM_PED_SUM=%d\n',...
    TP_SUM,FP_SUM,TN_SUM,FN_SUM,NUM_PED_SUM);

fclose(fileID);