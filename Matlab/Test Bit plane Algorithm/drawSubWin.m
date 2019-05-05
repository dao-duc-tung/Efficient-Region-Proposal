function I = drawSubWin(sub_win, sub_size, ori, color)
I=ori;
for i=1:size(sub_win,1)
    % draw sub-wins or matching sub-wins
    r=round(sub_win(i,1)-sub_size/2);
    c=round(sub_win(i,2)-sub_size/2);
    I = insertShape(I, 'rectangle',...
        [c r sub_size sub_size],'Color', color);
    % draw searching wins
%     search_size = 100;
%     r=round(sub_win(i,1)-search_size/2);
%     c=round(sub_win(i,2)-search_size/2);
%     I = insertShape(I, 'rectangle',...
%         [c r search_size search_size],'Color', 'blue');
end
end