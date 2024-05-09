% 20192608 - Calculates the options.stim.oriVals.theta angles for each gabor, for the targ and
% reference, for all trials.

function [options] = thetaCalc(options)

% Prealocate our options.stim.oriVals.theta array
options.stim.oriVals.theta = zeros([options.numTrials options.stim.maxGrid^2]);
options.stim.oriVals.thetaRef = zeros([options.numTrials options.stim.maxGrid^2]);

% First determine which cells are on the border of the large grid
options.stim.oriVals.edgeCells{1} = 1;   % Upper left corner
options.stim.oriVals.edgeCells{2} = 2:options.stim.maxGrid-1;   % Upper row
options.stim.oriVals.edgeCells{3} = options.stim.maxGrid;   % Upper right corner
options.stim.oriVals.edgeCells{4} = options.stim.maxGrid+1:options.stim.maxGrid:options.stim.maxGrid*(options.stim.maxGrid-1);   % Left column
options.stim.oriVals.edgeCells{5} = length(options.stim.gaborCoordArray)-options.stim.maxGrid+1;   % Bottom left corner
options.stim.oriVals.edgeCells{6} = length(options.stim.gaborCoordArray)-options.stim.maxGrid+2:length(options.stim.gaborCoordArray)-1;   % Lower row
options.stim.oriVals.edgeCells{7} = length(options.stim.gaborCoordArray);   % Bottom right corner
options.stim.oriVals.edgeCells{8} = options.stim.maxGrid*2:options.stim.maxGrid:length(options.stim.gaborCoordArray)-options.stim.maxGrid;   % Right column

for n=1:options.numTrials
    
    % Randomly determine where the cube will appear in the grid
    options.oriArray{n} = cubeGridCalc(options.stim.minGrid,options.stim.maxGrid);
    
    if randi(2) == 1
        surfOri = randi([30,60],1);
    else
        surfOri = randi([120,150],1);
    end
    for i=1:length(options.stim.gaborCoordArray)
        if ismember(i,options.oriArray{n}{1})
            options.stim.oriVals.theta(n,i) = 90;   % Orientation
        elseif ismember(i,options.oriArray{n}{2})
            options.stim.oriVals.theta(n,i) = 180;   % Orientation
        elseif ismember(i,options.oriArray{n}{3})
            options.stim.oriVals.theta(n,i) = 45;   % Orientation
        elseif ismember(i,options.oriArray{n}{4})
            options.stim.oriVals.theta(n,i) = 135;   % Orientation
        elseif ismember(i,options.oriArray{n}{5})
            options.stim.oriVals.theta(n,i) = surfOri;   % Make orientation of the surfaces = a random value outside of +/- 30 degs of 0/90 degs
        elseif ismember(i,options.oriArray{n}{6})
            % Calculate the gabor orientations for the cells adjacent to the cube in the target
            % Make sure adjacent cells are +/- 30 degs from their neightbors
            % We only have to compare to non-zero values surrounding the
            % cell.
            % Check to make sure the cells you're trying to grab acutally exist
            if ismember(i,options.stim.oriVals.edgeCells{1})
                surrOris = [options.stim.oriVals.theta(n,i+1) options.stim.oriVals.theta(n,i+options.stim.maxGrid)];   % First grab the ori values surrounding the cell
            elseif ismember(i,options.stim.oriVals.edgeCells{2})
                surrOris = [options.stim.oriVals.theta(n,i-1) options.stim.oriVals.theta(n,i+1) options.stim.oriVals.theta(n,i+options.stim.maxGrid)];
            elseif ismember(i,options.stim.oriVals.edgeCells{3})
                surrOris = [options.stim.oriVals.theta(n,i-1) options.stim.oriVals.theta(n,i+options.stim.maxGrid)];
            elseif ismember(i,options.stim.oriVals.edgeCells{4})
                surrOris = [options.stim.oriVals.theta(n,i+1) options.stim.oriVals.theta(n,i-options.stim.maxGrid) options.stim.oriVals.theta(n,i+options.stim.maxGrid)];
            elseif ismember(i,options.stim.oriVals.edgeCells{5})
                surrOris = [options.stim.oriVals.theta(n,i+1) options.stim.oriVals.theta(n,i-options.stim.maxGrid)];
            elseif ismember(i,options.stim.oriVals.edgeCells{6})
                surrOris = [options.stim.oriVals.theta(n,i-1) options.stim.oriVals.theta(n,i+1) options.stim.oriVals.theta(n,i-options.stim.maxGrid)];
            elseif ismember(i,options.stim.oriVals.edgeCells{7})
                surrOris = [options.stim.oriVals.theta(n,i-1) options.stim.oriVals.theta(n,i-options.stim.maxGrid)];
            elseif ismember(i,options.stim.oriVals.edgeCells{8})
                surrOris = [options.stim.oriVals.theta(n,i-1) options.stim.oriVals.theta(n,i-options.stim.maxGrid) options.stim.oriVals.theta(n,i+options.stim.maxGrid)];
            else
                surrOris = [options.stim.oriVals.theta(n,i-1) options.stim.oriVals.theta(n,i+1) options.stim.oriVals.theta(n,i-options.stim.maxGrid) options.stim.oriVals.theta(n,i+options.stim.maxGrid)];
            end
            
            % If there is a zero in the surrOris get rid of it, as it's just
            % a cell that hasn't been assigned an orientation yet.
            surrOris(surrOris==0) = [];
            
            % Now find the range of ori values you can chose from given the
            % ori values of the surrounding cells
            excludeRange = [];
            for j=1:length(surrOris)
                excludeRangeHolder = surrOris(j)-30:surrOris(j)+30;
                % If the options.stim.oriVals.theta range extends outside 1:360, wrap back
                % around
                if any(excludeRangeHolder < 1)
                    excludeRangeHolder(excludeRangeHolder < 1) = excludeRangeHolder(excludeRangeHolder < 1)+180;
                elseif any(excludeRangeHolder > 180)
                    excludeRangeHolder(excludeRangeHolder > 180) = excludeRangeHolder(excludeRangeHolder > 180)-180;
                end
                
                excludeRange = [excludeRange excludeRangeHolder];
                
                clear excludeRangeHolder
            end
            
            excludeRangeUnique = unique(excludeRange);
            
            thetaRange = 1:180;
            thetaRange(excludeRangeUnique) = [];
            
            options.stim.oriVals.theta(n,i) = thetaRange(randi(length(thetaRange)));
            
            clear surrOris excludeRange excludeRangeUnique thetaRange
        elseif ismember(i,options.oriArray{n}{7})
            % Calculate the gabor orientations for the other cells in the target
            % Make sure adjacent cells are +/- 30 degs from their neightbors
            % Calculate the gabor orientations for the cells adjacent to the cube in the target
            % Make sure adjacent cells are +/- 30 degs from their neightbors
            % We only have to compare to non-zero values surrounding the
            % cell.
            % Check to make sure the cells you're trying to grab acutally exist
            if ismember(i,options.stim.oriVals.edgeCells{1})
                surrOris = [options.stim.oriVals.theta(n,i+1) options.stim.oriVals.theta(n,i+options.stim.maxGrid)];   % First grab the ori values surrounding the cell
            elseif ismember(i,options.stim.oriVals.edgeCells{2})
                surrOris = [options.stim.oriVals.theta(n,i-1) options.stim.oriVals.theta(n,i+1) options.stim.oriVals.theta(n,i+options.stim.maxGrid)];
            elseif ismember(i,options.stim.oriVals.edgeCells{3})
                surrOris = [options.stim.oriVals.theta(n,i-1) options.stim.oriVals.theta(n,i+options.stim.maxGrid)];
            elseif ismember(i,options.stim.oriVals.edgeCells{4})
                surrOris = [options.stim.oriVals.theta(n,i+1) options.stim.oriVals.theta(n,i-options.stim.maxGrid) options.stim.oriVals.theta(n,i+options.stim.maxGrid)];
            elseif ismember(i,options.stim.oriVals.edgeCells{5})
                surrOris = [options.stim.oriVals.theta(n,i+1) options.stim.oriVals.theta(n,i-options.stim.maxGrid)];
            elseif ismember(i,options.stim.oriVals.edgeCells{6})
                surrOris = [options.stim.oriVals.theta(n,i-1) options.stim.oriVals.theta(n,i+1) options.stim.oriVals.theta(n,i-options.stim.maxGrid)];
            elseif ismember(i,options.stim.oriVals.edgeCells{7})
                surrOris = [options.stim.oriVals.theta(n,i-1) options.stim.oriVals.theta(n,i-options.stim.maxGrid)];
            elseif ismember(i,options.stim.oriVals.edgeCells{8})
                surrOris = [options.stim.oriVals.theta(n,i-1) options.stim.oriVals.theta(n,i-options.stim.maxGrid) options.stim.oriVals.theta(n,i+options.stim.maxGrid)];
            else
                surrOris = [options.stim.oriVals.theta(n,i-1) options.stim.oriVals.theta(n,i+1) options.stim.oriVals.theta(n,i-options.stim.maxGrid) options.stim.oriVals.theta(n,i+options.stim.maxGrid)];
            end
            
            % If there is a zero in the surrOris get rid of it, as it's just
            % a cell that hasn't been assigned an orientation yet.
            surrOris(surrOris==0) = [];
            
            % Now find the range of ori values you can chose from given the
            % ori values of the surrounding cells
            excludeRange = [];
            for j=1:length(surrOris)
                excludeRangeHolder = surrOris(j)-30:surrOris(j)+30;
                % If the options.stim.oriVals.theta range extends outside 1:360, wrap back
                % around
                if any(excludeRangeHolder < 1)
                    excludeRangeHolder(excludeRangeHolder < 1) = excludeRangeHolder(excludeRangeHolder < 1)+180;
                elseif any(excludeRangeHolder > 180)
                    excludeRangeHolder(excludeRangeHolder > 180) = excludeRangeHolder(excludeRangeHolder > 180)-180;
                end
                
                excludeRange = [excludeRange excludeRangeHolder];
                
                clear excludeRangeHolder
            end
            
            excludeRangeUnique = unique(excludeRange);
            
            thetaRange = 1:180;
            thetaRange(excludeRangeUnique) = [];
            
            options.stim.oriVals.theta(n,i) = thetaRange(randi(length(thetaRange)));
            
            clear surrOris excludeRange excludeRangeUnique thetaRange
        end
    end
    
    % Calculate the gabor orientations for the reference
    successBreak = 0;
    while 1
        refChoose = randperm(length(options.stim.oriVals.theta(n,:)));
        options.stim.oriVals.thetaRef(n,1) = options.stim.oriVals.theta(n,refChoose(1));
        refChooseUpdate = options.stim.oriVals.theta(n,refChoose);
        refChooseUpdate(1) = [];   % Update the ref ori index array
        for i=2:length(options.stim.oriVals.theta(n,:))
            
            clear surrOris
            if i<=options.stim.maxGrid   % If we're on the first row, only check the value to the left
                surrOris = options.stim.oriVals.thetaRef(n,i-1);   % Start by finding the exclude range or orientations
            elseif any(i==options.stim.maxGrid+1:options.stim.maxGrid:(options.stim.maxGrid*options.stim.maxGrid-1)+1)   % If it is on the left most edge, and not on the top row, compare with only upper value
                surrOris = options.stim.oriVals.thetaRef(n,i-options.stim.maxGrid);   % Start by finding the exclude range or orientations
            else   % For every other value compare options.windowNum/ the left and upper value
                surrOris = [options.stim.oriVals.thetaRef(n,i-1) options.stim.oriVals.thetaRef(n,i-options.stim.maxGrid)];
            end
            
            refExcludeRange = [];
            for j=1:length(surrOris)
                % Determine the range of oris you can't chose from
                refExcludeRangeHolder = surrOris(j)-30:surrOris(j)+30;
                
                % If you are <1 or >180 then wrap back around
                if any(refExcludeRangeHolder < 1)
                    refExcludeRangeHolder(refExcludeRangeHolder < 1) = refExcludeRangeHolder(refExcludeRangeHolder < 1)+180;
                elseif any(refExcludeRangeHolder > 180)
                    refExcludeRangeHolder(refExcludeRangeHolder > 180) = refExcludeRangeHolder(refExcludeRangeHolder > 180)-180;
                end
                
                refExcludeRange = [refExcludeRangeHolder refExcludeRange];
                
                clear refExcludeRangeHolder
            end
            
            % Only keep unique values
            refExcludeRangeUnique = unique(refExcludeRange);
            
            % Now find an orientation that doesn't overlap options.windowNum/ the exclude
            % range.
            for j=1:length(refChooseUpdate)
                options.stim.oriVals.thetaRef(n,i) = refChooseUpdate(j);
                if ~any(options.stim.oriVals.thetaRef(n,i)==refExcludeRangeUnique)
                    % Remove the value from the list if we select it
                    refChooseUpdate(j) = [];
                    
                    % If you successfully found all ori values break out of loop
                    if i == length(options.stim.oriVals.theta(n,:))
                        successBreak = 1;
                    end
                    
                    break
                end
            end
        end
        
        if successBreak == 1
            break
        end
    end
    
    % Because in half the trials (where options.varList(n,1)==2), the
    % target is acutally scramble as well, we want to go through and
    % re-scramble the shape made above and reblace the target (shape)
    % orientations with this second set of scrambled orientations. We still
    % want to initially make the shape, so we have the correct number of
    % 'shape' oreinted gabors, but we don't want to use the same scrambled
    % orientation array as we do for the reference. 
    clear thetaRefHolder refChooseUpdate refChoose successBreak surrOris refExcludeRange refExcludeRangeHolder
    if options.varList(n,1)==2   % Targ=scrambled
        % Re-calculate the gabor orientations for the target
        successBreak = 0;
        while 1
            refChoose = randperm(length(options.stim.oriVals.theta(n,:)));
            thetaRefHolder(1) = options.stim.oriVals.theta(n,refChoose(1));
            refChooseUpdate = options.stim.oriVals.theta(n,refChoose);
            refChooseUpdate(1) = [];   % Update the ref ori index array
            for i=2:length(options.stim.oriVals.theta(n,:))
                
                clear surrOris
                if i<=options.stim.maxGrid   % If we're on the first row, only check the value to the left
                    surrOris = thetaRefHolder(i-1);   % Start by finding the exclude range or orientations
                elseif any(i==options.stim.maxGrid+1:options.stim.maxGrid:(options.stim.maxGrid*options.stim.maxGrid-1)+1)   % If it is on the left most edge, and not on the top row, compare with only upper value
                    surrOris = thetaRefHolder(i-options.stim.maxGrid);   % Start by finding the exclude range or orientations
                else   % For every other value compare options.windowNum/ the left and upper value
                    surrOris = [thetaRefHolder(i-1) thetaRefHolder(i-options.stim.maxGrid)];
                end
                
                refExcludeRange = [];
                for j=1:length(surrOris)
                    % Determine the range of oris you can't chose from
                    refExcludeRangeHolder = surrOris(j)-30:surrOris(j)+30;
                    
                    % If you are <1 or >180 then wrap back around
                    if any(refExcludeRangeHolder < 1)
                        refExcludeRangeHolder(refExcludeRangeHolder < 1) = refExcludeRangeHolder(refExcludeRangeHolder < 1)+180;
                    elseif any(refExcludeRangeHolder > 180)
                        refExcludeRangeHolder(refExcludeRangeHolder > 180) = refExcludeRangeHolder(refExcludeRangeHolder > 180)-180;
                    end
                    
                    refExcludeRange = [refExcludeRangeHolder refExcludeRange];
                    
                    clear refExcludeRangeHolder
                end
                
                % Only keep unique values
                refExcludeRangeUnique = unique(refExcludeRange);
                
                % Now find an orientation that doesn't overlap options.windowNum/ the exclude
                % range.
                for j=1:length(refChooseUpdate)
                    thetaRefHolder(i) = refChooseUpdate(j);
                    if ~any(thetaRefHolder(i)==refExcludeRangeUnique)
                        % Remove the value from the list if we select it
                        refChooseUpdate(j) = [];
                        
                        % If you successfully found all ori values break out of loop
                        if i == length(options.stim.oriVals.theta(n,:))
                            successBreak = 1;
                        end
                        
                        break
                    end
                end
            end
            
            if successBreak == 1
                break
            end
        end
        % Replace theta values w/ new thetaRefHolder
        options.stim.oriVals.theta(n,:) = thetaRefHolder;
    end
    
end

end


