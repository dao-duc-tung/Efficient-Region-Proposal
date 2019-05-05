function isTrue = evaluateRoiVsPed(roi, ped, IoU)
x1 = int32(roi(1, 1)); y1 = int32(roi(1, 2));
x2 = int32(roi(1, 3)); y2 = int32(roi(1, 4));
x1ped=ped(1,1); y1ped=ped(1,2);
x2ped=ped(1,3); y2ped=ped(1,4);

if(x1<=x1ped && y1<=y1ped && x2>=x2ped && y2>=y2ped)
    isTrue=1;
    return;
end
        
xx1 = max(x1, x1ped);
yy1 = max(y1, y1ped);
xx2 = min(x2, x2ped);
yy2 = min(y2, y2ped);
w = max(xx2-xx1+1, 0);
h = max(yy2-yy1+1, 0);
roiArea = (x2-x1)*(y2-y1);
pedArea = (x2ped-x1ped)*(y2ped-y1ped);
overlap = (w*h)/(roiArea+pedArea-(w*h));

if overlap > IoU
    isTrue=1;
    return;
else
    isTrue=0;
    return;
end

end