% Generate the grating values for left and right eyes
% KWK - 20201014

function [options] = genFrame(options)

% randomized squiggles
options.sp.frame.frameRect = [-1 -1 1 1] * ceil(options.sp.gratSize);
options.sp.frame.frameRect = CenterRect(options.sp.frame.frameRect, options.rect) + [options.sp.eyeAdjust 0 options.sp.eyeAdjust 0];
options.sp.frame.frameRect = [abs(options.sp.frame.frameRect(1) - options.sp.frame.frameRect(3)), abs(options.sp.frame.frameRect(2) - options.sp.frame.frameRect(4))];
options.sp.frame.frameRect = options.sp.frame.frameRect + 50;

options.sp.frame.frame = zeros(options.sp.frame.frameRect(1),options.sp.frame.frameRect(2));
options.sp.frame.frame_wid = 25;
options.sp.frame.frame_len = length(options.sp.frame.frame);

options.sp.frame.frame(:, [1:options.sp.frame.frame_wid (options.sp.frame.frame_len - (options.sp.frame.frame_wid-1)):options.sp.frame.frame_len]) = 1;
options.sp.frame.frame([1:options.sp.frame.frame_wid (options.sp.frame.frame_len - (options.sp.frame.frame_wid-1)):options.sp.frame.frame_len], :) = 1;

options.sp.frame.frame(options.sp.frame.frame == 0) = options.grayCol(1);
options.sp.frame.frame([1 options.sp.frame.frame_len], :) = 0;
options.sp.frame.frame(:, [1 options.sp.frame.frame_len]) = 0;
options.sp.frame.frame([1 options.sp.frame.frame_wid (options.sp.frame.frame_len-(options.sp.frame.frame_wid-1)) options.sp.frame.frame_len], options.sp.frame.frame_wid:(options.sp.frame.frame_len - (options.sp.frame.frame_wid-1))) = 0;
options.sp.frame.frame(options.sp.frame.frame_wid:(options.sp.frame.frame_len - (options.sp.frame.frame_wid-1)),[1 options.sp.frame.frame_wid (options.sp.frame.frame_len-(options.sp.frame.frame_wid-1)) options.sp.frame.frame_len]) = 0;

rows = 1:length(options.sp.frame.frame);
cols = 1:length(options.sp.frame.frame);

randrow = rows(randi(length(options.sp.frame.frame),1));
randcol = cols(randi(length(options.sp.frame.frame),1));
options.sp.frame.aug_factor = 25;

for j = 1:length(options.sp.frame.frame)*options.sp.frame.aug_factor
    if j < length(options.sp.frame.frame)*options.sp.frame.aug_factor/4
        direction_row = 1;
        direction_col = [-ones(1,randi(2,1)), zeros(1,randi(12,1)), ones(1,randi(2,1))];
        direction_col = direction_col(randi(length(direction_col),1));
    elseif j >= length(options.sp.frame.frame)*options.sp.frame.aug_factor/4 && j < length(options.sp.frame.frame)*options.sp.frame.aug_factor/2
        direction_row = -1;
        direction_col = [-ones(1,randi(2,1)), zeros(1,randi(12,1)), ones(1,randi(2,1))];
        direction_col = direction_col(randi(length(direction_col),1));
    elseif j >= length(options.sp.frame.frame)*options.sp.frame.aug_factor/2 && j < 3*(length(options.sp.frame.frame)*options.sp.frame.aug_factor)/4
        direction_row = [-ones(1,randi(2,1)), zeros(1,randi(12,1)), ones(1,randi(2,1))];
        direction_row = direction_row(randi(length(direction_row),1));
        direction_col = 1;
    else
        direction_row = [-ones(1,randi(2,1)), zeros(1,randi(12,1)), ones(1,randi(2,1))];
        direction_row = direction_row(randi(length(direction_row),1));
        direction_col = -1;
    end
    
    if options.sp.frame.frame(randrow,randcol) == 1
        options.sp.frame.frame(randrow,randcol) = 255;
    end
    
    if randrow + 1 < length(options.sp.frame.frame) && options.sp.frame.frame(randrow+1, randcol) == 1
        options.sp.frame.frame(randrow+1, randcol) = 255;
    end
    
    if randcol + 1 < length(options.sp.frame.frame) && options.sp.frame.frame(randrow, randcol+1) == 1
        options.sp.frame.frame(randrow, randcol+1) = 255;
    end
    
    randrow = randrow + direction_row;
    randcol = randcol + direction_col;
    if randcol <= 0 || randcol > length(options.sp.frame.frame)
        randcol = cols(randi(length(options.sp.frame.frame),1));
        randrow = rows(randi(length(options.sp.frame.frame),1));
    end
    
    if randrow <= 0 || randrow > length(options.sp.frame.frame)
        randcol = cols(randi(length(options.sp.frame.frame),1));
        randrow = rows(randi(length(options.sp.frame.frame),1));
    end
end

options.sp.frame.frame(options.sp.frame.frame==1) = 0;

end