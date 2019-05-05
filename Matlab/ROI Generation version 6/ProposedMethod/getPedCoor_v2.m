function PedCoor = getPedCoor_v2(pLabel, nameImage)
PedCoor = [];

label_TUD_Crossing = 'E:\DAO DUC TUNG\TestBMS\src_TUD_Crossing\tud-crossing-sequence.idl';
label_ETHZ = 'E:\DAO DUC TUNG\TestBMS\src_ETHZ\lp-annot.idl';

%% get order
order = 0;
if strcmp(pLabel, label_ETHZ) == 1
    order = round(mod(str2num(nameImage(11:14)),4900)/4-0.5)+1;
    if order == 0
        order = 1;
    end
elseif strcmp(pLabel, label_TUD_Crossing) == 1
    order = str2num(nameImage(17:19));
end
rows = 480; cols = 640;

%% read ped coor order-th
fid = fopen(pLabel);
s1 = '';
while true
    thisline = fgetl(fid);
    if ~ischar(thisline); break; end  %end of file
    s1 = strcat(s1, thisline);
end
fclose(fid);
s2 = strsplit(s1, ';');
num_ped = size(s2,2);
if(order > num_ped)
    return;
end
s3 = s2(1, order);
r = regexp(s3, '(?<=\()[^)]*(?=\))', 'match');
r = [r{:}];

for i=1:size(r,2)
    C = str2num(char(strsplit(char(r(1,i)), ', ')));
    C = C';
    x1ped=C(1,1); y1ped=C(1,2);
    x2ped=C(1,3); y2ped=C(1,4);
    if(x1ped > x2ped)
        x1ped=C(1,3); y1ped=C(1,4);
        x2ped=C(1,1); y2ped=C(1,2);
    end
    x1ped = max(x1ped, 1); x2ped = max(x2ped, 1); y1ped = max(y1ped, 1); y2ped = max(y2ped, 1);
    x1ped = min(x1ped, cols); x2ped = min(x2ped, cols); y1ped = min(y1ped, rows); y2ped = min(y2ped, rows);
    C = [x1ped y1ped x2ped y2ped];
    PedCoor = [PedCoor; C];
end

%% allow a deviation of 10% in hor&ver direction
deviate = 0;
ratio = 0;
near = 0;
thresh_pedcoor = 0;
if ratio == 0
    return;
end
temp_PedCoor = [];
for i=1:size(PedCoor,1)
    x1 = PedCoor(i,1); y1 = PedCoor(i,2);
    x2 = PedCoor(i,3); y2 = PedCoor(i,4);
    
    if x1<near || x2>(cols-near)
        continue;
    end
    
    w = x2-x1; h = y2-y1;
    if w*h <= thresh_pedcoor
        continue;
    end
    hD = round(h*deviate/100/2);
    y1=y1+hD; y2=y2-hD;
    
    newH = y2-y1;
    newW = round(newH*ratio);
    center_x = round((x1+x2)/2);
    x1 = round(center_x-newW/2);
    x2 = round(center_x+newW/2);
    
    temp_PedCoor = [temp_PedCoor; x1 y1 x2 y2];
end
PedCoor = temp_PedCoor;

end