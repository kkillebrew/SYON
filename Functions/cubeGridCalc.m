% Return the index of the cells in an n x n grid that make up a grid that is
% n-m x n-m. In other words, it numbers a square grid, size n, counting
% each cell from left to right, top to bottom (if grid is 4x4, the upper
% left cell being #1 the bottom right being 16) and returns the index
% values for the cells that make up a smaller grid, size n-m, within the
% larger grid (using the cell number from the larger grid; upper left of 
% small grid is cell #6, if the small grid is centered inside the large grid.).

function [oriArray] = cubeGridCalc(minGrid,maxGrid)

% minGrid = 8;   % Minimum size of large grid (or actual size of the cube). minGrid x minGrid
% maxGrid = 12;   % Max size of the large grid

% First check to make sure the size of the small grid is <= the large grid.
if minGrid > maxGrid
    error('Cube grid too large')
end

% Also check that the grid is > the minimum possible size or that the grid 
% is < the max (i.e. can't make a cube w/ only 3x3 grid).
if minGrid <= 4
    error('Grid too small')
end
if maxGrid > 12
    error('Grid too large')
end

% Find how many rows/columns you need to ignore in the large grid to get to
% the start/end of the small grid.
gridDiff = maxGrid-minGrid;
diffEnd = floor(gridDiff/2);
diffBeg = ceil(gridDiff/2);

% Jitter the cube position
diffRange = -diffBeg:diffEnd;
horizShift = diffRange(randi(length(diffRange)));
vertShift = diffRange(randi(length(diffRange)));

% Number the large grid
counter = 0;
for i=1:maxGrid
    for j=1:maxGrid
        counter = counter + 1;
        largeGridIdx(i,j) = counter;
    end
end

counterI = 0;
counterJ = 0;
for i=1+diffBeg+vertShift:maxGrid-(diffEnd-vertShift)
    counterI = counterI+1;
    for j=1+diffBeg+horizShift:maxGrid-(diffEnd-horizShift)
        counterJ = counterJ+1;
        smallGridIdx(counterI,counterJ) = largeGridIdx(i,j);
    end
    counterJ = 0;
end


% Now make a mask grid, using the small grid, showing only cells that
% contain segments from the cube.
% Note:
% In the mask grid all cells not in the small grid == 0.
% The first and last cell of the small grid are always 0.
% The center cells of the front square of the cube are always 0.
% There are only horiz cells in the first, second, and last rows 
% Horiz cell = 1
% There are only vert cells in the first, second to last, and last columns
% Vert cells = 2
% The diagonal cells always fall to the upper/lower right/left of
% horiz/vert intersections
% 45 cells = 3
% 315 cells = 4
maskGrid = zeros(minGrid,minGrid);
numHorizPerRow = minGrid-3;
numVertPerCol = numHorizPerRow;

for i=1:minGrid 
    for j=1:minGrid
        
        if any(i==[1 3 minGrid])   % Horizontal segments
            if i==1    % If the first row,skip the first 3 cells and last cell
                if ~any(j==[1 2 3 minGrid])
                    maskGrid(i,j) = 1;
                end
            elseif i==3    % If 3rd row, skip first cell and last 3 cells
                if ~any(j==[1 minGrid-2 minGrid-1 minGrid])
                   maskGrid(i,j) = 1; 
                end
            elseif i==minGrid
                if ~any(j==[1 minGrid-2 minGrid-1 minGrid])
                   maskGrid(i,j) = 1; 
                end
            end
        end
        
        if any(j==[1 minGrid-2 minGrid])   % Vertical segments
            if j==1
                if ~any(i==[1 2 3 minGrid])
                    maskGrid(i,j) = 2;
                end
            elseif j==minGrid-2    
                if ~any(i==[1 2 3 minGrid])
                   maskGrid(i,j) = 2; 
                end
            elseif j==minGrid
                if ~any(i==[1 minGrid-2 minGrid-1 minGrid])
                   maskGrid(i,j) = 2; 
                end
            end
        end
        
        if any(i==[1 2 3]) && any(j==[1 2 3])   % 45 dg segments
            if i==1 && j==3 || i==2 && j==2 || i==3 && j==1
               maskGrid(i,j) = 3; 
            end
        elseif any(i==[minGrid-2 minGrid-1 minGrid]) && any(j==[minGrid-2 minGrid-1 minGrid])
            if i==minGrid && j==minGrid-2 || i==minGrid-1 && j==minGrid-1 || i==minGrid-2 && j==minGrid
               maskGrid(i,j) = 3; 
            end
        elseif i==2 && j==minGrid-1
            maskGrid(i,j) = 3;
        end
        
        if i==1  && j==minGrid   % 315 dg segments
            maskGrid(i,j) = 4;
        elseif i==3  && j==minGrid-2
            maskGrid(i,j) = 4;
        elseif i==minGrid  && j==1
            maskGrid(i,j) = 4;
        end
        
        if i==3 && j==1   % Surface of the cube
            for k=1:minGrid-4
                for l=1:minGrid-4
                    maskGrid(i+k,j+l) = 5;
                end
            end
        elseif j==2 && i==2
            for k=1:minGrid-4
                maskGrid(i,j+k) = 5;
            end
        elseif j==minGrid-1 && i==2 
            for k=1:minGrid-4
                maskGrid(i+k,j) = 5;
            end
        end
        
    end
end

% Make the orientation array
oriArrayCounter = zeros([6 1]);
for i=1:length(maskGrid)
    for j=1:length(maskGrid)
        % Label cells included in the cube
        if maskGrid(i,j) == 1
            oriArrayCounter(1) = oriArrayCounter(1) + 1;
            oriArray{1}(oriArrayCounter(1)) = smallGridIdx(i,j);
        elseif maskGrid(i,j) == 2
            oriArrayCounter(2) = oriArrayCounter(2) + 1;
            oriArray{2}(oriArrayCounter(2)) = smallGridIdx(i,j);
        elseif maskGrid(i,j) == 3
            oriArrayCounter(3) = oriArrayCounter(3) + 1;
            oriArray{3}(oriArrayCounter(3)) = smallGridIdx(i,j);
        elseif maskGrid(i,j) == 4
            oriArrayCounter(4) = oriArrayCounter(4) + 1;
            oriArray{4}(oriArrayCounter(4)) = smallGridIdx(i,j);
        elseif maskGrid(i,j) == 5
            oriArrayCounter(5) = oriArrayCounter(5) + 1;
            oriArray{5}(oriArrayCounter(5)) = smallGridIdx(i,j);
        end
    end
end

% Label cells surrounding the cube
% First identify where inside the larg grid the small grid is placed and
% label the large grid cells that aren't contained in the small grid. 
counter = 0;
for i=1:length(largeGridIdx)
    for j=1:length(largeGridIdx)
        counter = counter+1;
        if sum(sum(counter==smallGridIdx))
            smallInBigGridIdx(i,j) = smallGridIdx(counter==smallGridIdx);
        else
            smallInBigGridIdx(i,j) = 0;
        end
    end
end

% Now use that grid to insert the maskGrid into the largeGrid. This will
% help more accurately ID the cells that contain the cube (because the
% upper left and lower right corners contain non cube cells). 
newSmallInBigGridIdx = zeros([maxGrid maxGrid]);
newSmallInBigGridIdx(smallInBigGridIdx~=0) = maskGrid;

% Next, identify the cell indices that are adjacent to the actual cube
counter = 0;
for i=1:length(newSmallInBigGridIdx)
    for j=1:length(newSmallInBigGridIdx)
        counter = counter+1;
        if  newSmallInBigGridIdx(i,j) == 0  % Make sure it is an acutal cell outside the cube
            % Check to make sure you aren't on the edge or in the corner of
            % the large grid, otherwise it will error out b/c i-1 when i=1 
            % doesn't exist as an index. 
            if i~=1 && i~=length(newSmallInBigGridIdx) && j~=1 && j~=length(newSmallInBigGridIdx)
                if newSmallInBigGridIdx(i+1,j) ~= 0 || newSmallInBigGridIdx(i-1,j) ~= 0 ||...
                        newSmallInBigGridIdx(i,j+1) ~= 0 || newSmallInBigGridIdx(i,j-1) ~= 0
                    oriArrayCounter(6) = oriArrayCounter(6) + 1;
                    oriArray{6}(oriArrayCounter(6)) = counter;
                end
            elseif i==1 && j==1
                if newSmallInBigGridIdx(i+1,j) ~= 0 || newSmallInBigGridIdx(i,j+1) ~= 0
                    oriArrayCounter(6) = oriArrayCounter(6) + 1;
                    oriArray{6}(oriArrayCounter(6)) = counter;
                end
            elseif i==1 && j==length(newSmallInBigGridIdx)
                if newSmallInBigGridIdx(i+1,j) ~= 0 || newSmallInBigGridIdx(i,j-1) ~= 0
                    oriArrayCounter(6) = oriArrayCounter(6) + 1;
                    oriArray{6}(oriArrayCounter(6)) = counter;
                end
            elseif i==length(newSmallInBigGridIdx) && j==1
                if newSmallInBigGridIdx(i-1,j) ~= 0 || newSmallInBigGridIdx(i,j+1) ~= 0
                    oriArrayCounter(6) = oriArrayCounter(6) + 1;
                    oriArray{6}(oriArrayCounter(6)) = counter;
                end
            elseif i==length(newSmallInBigGridIdx) && j==length(newSmallInBigGridIdx)
                if newSmallInBigGridIdx(i-1,j) ~= 0 || newSmallInBigGridIdx(i,j-1) ~= 0
                    oriArrayCounter(6) = oriArrayCounter(6) + 1;
                    oriArray{6}(oriArrayCounter(6)) = counter;
                end
            elseif i==1 && j~=1 && j~=length(newSmallInBigGridIdx)
                if newSmallInBigGridIdx(i+1,j) ~= 0 ||...
                        newSmallInBigGridIdx(i,j+1) ~= 0 || newSmallInBigGridIdx(i,j-1) ~= 0
                    oriArrayCounter(6) = oriArrayCounter(6) + 1;
                    oriArray{6}(oriArrayCounter(6)) = counter;
                end
            elseif i==length(newSmallInBigGridIdx) && j~=1 && j~=length(newSmallInBigGridIdx)
                if newSmallInBigGridIdx(i-1,j) ~= 0 ||...
                        newSmallInBigGridIdx(i,j+1) ~= 0 || newSmallInBigGridIdx(i,j-1) ~= 0
                    oriArrayCounter(6) = oriArrayCounter(6) + 1;
                    oriArray{6}(oriArrayCounter(6)) = counter;
                end
            elseif j==1 && i~=1 && i~=length(newSmallInBigGridIdx)
                if newSmallInBigGridIdx(i+1,j) ~= 0 || newSmallInBigGridIdx(i-1,j) ~= 0 ||...
                        newSmallInBigGridIdx(i,j+1) ~= 0
                    oriArrayCounter(6) = oriArrayCounter(6) + 1;
                    oriArray{6}(oriArrayCounter(6)) = counter;
                end
            elseif j==length(newSmallInBigGridIdx) && i~=1 && i~=length(newSmallInBigGridIdx)
                if newSmallInBigGridIdx(i+1,j) ~= 0 || newSmallInBigGridIdx(i-1,j) ~= 0 ||...
                        newSmallInBigGridIdx(i,j-1) ~= 0
                    oriArrayCounter(6) = oriArrayCounter(6) + 1;
                    oriArray{6}(oriArrayCounter(6)) = counter;
                end
            end
        end
    end
end

% Find indices to all other cells
randGridIdx = 1:largeGridIdx(end,end);
for i=1:length(oriArray)
    for j=1:length(oriArray{i})
        randGridIdx(randGridIdx==oriArray{i}(j)) = [];
    end
end
oriArray{7} = randGridIdx;

end











