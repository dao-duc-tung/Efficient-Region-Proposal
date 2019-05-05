function gImg = getGridImage(I, gSize)
[rows,cols,~] = size(I);
new_r = round(rows/gSize);
new_c = round(cols/gSize);
if mod(rows,gSize)~=0
    new_r=new_r+1;
end
if mod(cols,gSize)~=0
    new_c=new_c+1;
end
gImg = zeros(new_r, new_c);
for r=1:rows
    for c=1:cols
        tR = floor(r/gSize)+1;
        tC = floor(c/gSize)+1;
        if mod(r,gSize)==0
            tR=tR-1;
        end
        if mod(c,gSize)==0
            tC=tC-1;
        end
        gImg(tR,tC)=gImg(tR,tC)+I(r,c);
    end
end
gImg = gImg/(gSize*gSize);

end