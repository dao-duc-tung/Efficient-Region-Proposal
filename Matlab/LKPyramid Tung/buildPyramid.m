function [Pyra1,Pyra2]=buildPyramid(I1,I2,PYRA_NO)
%% init the first level of Pyramid
if size(I1,3)>=3
    I1 = rgb2gray(I1);
end
if size(I2,3)>=3
    I2 = rgb2gray(I2);
end
G=fspecial('gaussian',[3 3],1);
Pyra1{1} = conv2(I1,G,'same');
Pyra2{1} = conv2(I2,G,'same');

%% init the next levels
if PYRA_NO <= 1
    return;
end
for k=2:PYRA_NO
    [r,c,~] = size(Pyra1{k-1});
    if(r<=30 || c<=40), break, end;
    Pyra1{k} = impyramid(Pyra1{k-1}, 'reduce');
    Pyra2{k} = impyramid(Pyra2{k-1}, 'reduce');
end

end