function [dr,dc] = getTransVector_v1(im1,im2)
LENGTH_REMOVE_EDGE = 5;
edge1 = edge(im1,'Sobel');
edge2 = edge(im2,'Sobel');
se_dilation = strel('square', 3);
edge1 = imdilate(edge1, se_dilation);
edge2 = bwareaopen(edge2,LENGTH_REMOVE_EDGE, 8);

[y0,x0] = size(edge1);
C = xcorr2(double(edge1), double(edge2));
[y1, x1] = find(ismember(C, max(C(:))));
dr = int32(y1(1))-y0;
dc = int32(x1(1))-x0;

end