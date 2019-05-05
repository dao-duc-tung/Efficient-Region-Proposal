function R = translateImage(I,dr,dc)
[rows, cols, ~] = size(I);
R=zeros(rows,cols);
for a=1:rows
    for b=1:cols
        y=a-dr;
        x=b-dc;
        if(y>=1&&x>=1&&y<=rows&&x<=cols)
            R(a,b) = I(y,x);
        end
    end
end
end