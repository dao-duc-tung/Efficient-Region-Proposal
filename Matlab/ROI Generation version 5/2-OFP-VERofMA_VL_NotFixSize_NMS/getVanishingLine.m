function row_VanishingLine = getVanishingLine(pLabel)
label_TUD_Crossing = 'E:\DAO DUC TUNG\TestBMS\src_TUD_Crossing\tud-crossing-sequence.idl';
label_ETHZ = 'E:\DAO DUC TUNG\TestBMS\src_ETHZ\lp-annot.idl';

row_VanishingLine = 1;
if strcmp(pLabel, label_ETHZ) == 1
    row_VanishingLine = 186;
elseif strcmp(pLabel, label_TUD_Crossing) == 1
    row_VanishingLine = 202;
end

% %test
% p='E:\DAO DUC TUNG\TestBMS\src_TUD_Crossing\DaSide0811-seq7-002.png';
% [rows,cols,~] = size(imread(p));
% figure(10),imshow(imread(p)),hold on
% line([1 cols],[row_VanishingLine row_VanishingLine],'Color','yellow','LineStyle','-');
% hold off;

end