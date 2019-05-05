function I = drawSubWin(sub_win, sub_size, ori, color)
I=ori;
half_sub_size = floor(sub_size/2);
for i=1:size(sub_win,1)
    % draw sub-wins or matching sub-wins
    if isnan(sub_win(i,1)) || isnan(sub_win(i,2))
        continue;
    end
    r=round(sub_win(i,1)-half_sub_size/2);
    c=round(sub_win(i,2)-half_sub_size/2);
    I = insertShape(I, 'rectangle',...
        [c r half_sub_size half_sub_size],'Color', color);
    % draw searching wins
%     search_size = 100;
%     r=round(sub_win(i,1)-search_size/2);
%     c=round(sub_win(i,2)-search_size/2);
%     I = insertShape(I, 'rectangle',...
%         [c r search_size search_size],'Color', 'blue');
end
end