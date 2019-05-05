function [filteredROI,removedROI] = nms_v2(boxes, overlap)
% top = nms(boxes, overlap)
% Non-maximum suppression. (FAST VERSION)
% Greedily select high-scoring detections and skip detections
% that are significantly covered by a previously selected
% detection.
%
% NOTE: This is adapted from Pedro Felzenszwalb's version (nms.m),
% but an inner loop has been eliminated to significantly speed it
% up in the case of a large number of boxes

% Copyright (C) 2011-12 by Tomasz Malisiewicz
% All rights reserved.
% 
% This file is part of the Exemplar-SVM library and is made
% available under the terms of the MIT license (see COPYING file).
% Project homepage: https://github.com/quantombone/exemplarsvm

filteredROI=[]; removedROI=[];
if isempty(boxes)
  pick = [];
  return;
end

x1 = boxes(:,1);
y1 = boxes(:,2);
x2 = boxes(:,3);
y2 = boxes(:,4);
s = boxes(:,end);

area = (x2-x1+1) .* (y2-y1+1);

[~, idxs] = sort(s);
unpick = [];
pick = s*0;
counter = 1;
while ~isempty(idxs)
  last = length(idxs);
  i = idxs(last);  
  pick(counter) = i;
  counter = counter + 1;
  
  xx1 = max(x1(i), x1(idxs(1:last-1)));
  yy1 = max(y1(i), y1(idxs(1:last-1)));
  xx2 = min(x2(i), x2(idxs(1:last-1)));
  yy2 = min(y2(i), y2(idxs(1:last-1)));
  
  w = max(0.0, xx2-xx1+1);
  h = max(0.0, yy2-yy1+1);
  
  inter = w.*h;
  o = inter ./ (area(i) + area(idxs(1:last-1)) - inter);
  
  unpick = [unpick; idxs(o>=overlap)];
  idxs = idxs(o<overlap);
end

pick = pick(1:(counter-1));
for i=1:length(pick)
    filteredROI=[filteredROI; boxes(pick(i),:)];
end
for i=1:size(unpick,1)
    removedROI=[removedROI; boxes(unpick(i,1),:)];
end