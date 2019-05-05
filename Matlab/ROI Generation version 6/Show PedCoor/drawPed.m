function outImg = drawPed(pIn,pLabel,nameImage,MODE)
%% get pedcoor
PedCoor = [];
if MODE == 0
    PedCoor = getPedCoor_v0(pLabel, nameImage);
elseif MODE == 1
    PedCoor = getPedCoor_v1(pLabel, nameImage);
elseif MODE == 2
    PedCoor = getPedCoor_v2(pLabel, nameImage);
end

%% draw ped
I = imread(fullfile(pIn,nameImage));
for k=1:size(PedCoor,1)
    I = insertShape(I, 'rectangle',...
        [PedCoor(k,1) PedCoor(k,2) (PedCoor(k,3)-PedCoor(k,1)) (PedCoor(k,4)-PedCoor(k,2))],...
        'Color', 'green', 'LineWidth', 1);
end
%% output
outImg = I;

end