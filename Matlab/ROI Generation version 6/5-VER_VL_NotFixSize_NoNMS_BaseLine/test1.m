pIn = 'E:\DAO DUC TUNG\TestBMS\src_ETHZ';
p = 'image_00005008_0.png';

I=rgb2gray(imread(fullfile(pIn,p)));
BWs = edge(I,'sobel',[],'vertical');
figure, imshow(BWs), title('binary gradient mask');