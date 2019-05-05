pIn = 'E:\DAO DUC TUNG\TestBMS\src_ETHZ';
% p = 'image_00004900_0.png';
% p = 'image_00004987_0.png';
% p = 'image_00005127_0.png';
p = 'image_00005213_0.png';

% I=imread(fullfile(pIn,p));
I=imread('MovingImageTest.png');

v = 186;
min_w = 72; min_h = 144;
max_w = 96; max_h = 192;
figure(2), imshow(I), hold on
line([1,size(I,2)],[v,v],'LineWidth',2,'Color','g');
rectangle('Position',[1,v-min_h/2,min_w,min_h],'LineWidth',2,'LineStyle','-','EdgeColor','y');
rectangle('Position',[400,v,min_w,min_h],'LineWidth',2,'LineStyle','-','EdgeColor','y');
line([1,size(I,2)],[v-min_h/2,v-min_h/2],'LineWidth',2,'Color','y');
line([1,size(I,2)],[v+min_h,v+min_h],'LineWidth',2,'Color','y');

rectangle('Position',[200,v-max_h/2,max_w,max_h],'LineWidth',2,'LineStyle','-','EdgeColor','b');
rectangle('Position',[500,v,max_w,max_h],'LineWidth',2,'LineStyle','-','EdgeColor','b');

plot(min_w/2, v, '.y', 'MarkerSize',17);
plot(200+max_w/2, v, '.g', 'MarkerSize',17);
plot(400+min_w/2, v+min_h/2, '.y', 'MarkerSize',17);
plot(500+max_w/2, v+max_h/2, '.g', 'MarkerSize',17);

line([1,size(I,2)],[v-max_h/2,v-max_h/2],'LineWidth',2,'Color','b');
line([1,size(I,2)],[v+max_h,v+max_h],'LineWidth',2,'Color','b');

hold off;

