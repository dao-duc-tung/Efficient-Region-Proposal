% version 1: fix sub wins
function sub_win = initFixSubWins(I,...
    dis_fr_bound,search_size,num_sub_win)
[rows,cols,~] = size(I);
sub_win = [];
if num_sub_win == 8
    r1 = round(dis_fr_bound+search_size/2);c1 = r1;
    sub_win = [sub_win; r1 c1];
    r2 = r1;c2 = round(cols/2);
    sub_win = [sub_win; r2 c2];
    r3 = r1;c3 = cols-c1;
    sub_win = [sub_win; r3 c3];
    r4 = round(rows/2);c4 = c1;
    sub_win = [sub_win; r4 c4];
    r5 = r4;c5 = c3;
    sub_win = [sub_win; r5 c5];
    r6 = rows-r1;c6 = c1;
    sub_win = [sub_win; r6 c6];
    r7 = r6;c7 = c2;
    sub_win = [sub_win; r7 c7];
    r8 = r6;c8 = c3;
    sub_win = [sub_win; r8 c8];
else
    if num_sub_win == 6
        r1 = round(dis_fr_bound+search_size/2);c1 = r1;
        sub_win = [sub_win; r1 c1];
        r2 = r1;c2 = round(cols/2);
        sub_win = [sub_win; r2 c2];
        r3 = r1;c3 = cols-c1;
        sub_win = [sub_win; r3 c3];
        r6 = rows-r1;c6 = c1;
        sub_win = [sub_win; r6 c6];
        r7 = r6;c7 = c2;
        sub_win = [sub_win; r7 c7];
        r8 = r6;c8 = c3;
        sub_win = [sub_win; r8 c8];
    else
        if num_sub_win == 5
            r1 = round(dis_fr_bound+search_size/2);c1 = r1;
            sub_win = [sub_win; r1 c1];
            r2 = r1;c2 = round(cols/2);
            sub_win = [sub_win; r2 c2];
            r3 = r1;c3 = cols-c1;
            sub_win = [sub_win; r3 c3];
            r4 = r1;c4 = round((c1+c2)/2);
            sub_win = [sub_win; r4 c4];
            r5 = r1;c5 = cols-c4;
            sub_win = [sub_win; r5 c5];
        end
    end
end
end