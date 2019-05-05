function [tp,fp,fn,num_ped]=evaluateROIwHOG_TUNG(pIn,pOut,name,rect)
tp=0; fp=0; fn=0; num_ped=0;
%% save rect to file
tempROIPath = fullfile(pOut,'tempROI.txt');
fileID = fopen(tempROIPath,'w');
for i=1:size(rect,1)
    fprintf(fileID, '%d %d %d %d\n',...
        rect(i,1),rect(i,2),rect(i,3),rect(i,4));
end
fclose(fileID);
%% call C++ function to evaluate rect set by HOG
% C++ function return miss_ped, save the outImg
program = 'E:\DAO DUC TUNG\Google Drive\IT\working\ImageProcessing\NTU Internship\share Workspace\C-C++\HOG_Fw_ver3\Debug\HOG_OpenCV.exe';
cmd = ['"' program '" "' pIn '" "' pOut '" "' name '" "' tempROIPath '"'];
[status result] = system(cmd);
%% get result
tempS = strsplit(result, ' ');
tp = str2num(tempS{1});
fp = str2num(tempS{2});
fn = str2num(tempS{3});
num_ped = str2num(tempS{4});

end