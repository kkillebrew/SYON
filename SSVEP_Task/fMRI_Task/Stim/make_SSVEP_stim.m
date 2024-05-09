function make_SSVEP_stim(options)
%%

%% options
if ~exist('options','var')
    options = [];
end
if ~isfield(options,'write_cmd')
    options.write_cmd = 'imwrite'; % print is giving me crappy images, use imwrite
    % valid options are imwrite, print
end

%% set up parameters
Gdrive_path = {'E:\','C:\Users\mpschallmo\'};
for iG = 1:numel(Gdrive_path)
    find_dir(iG) = exist(Gdrive_path{iG},'dir');
end
cd(fullfile(Gdrive_path{(find_dir > 1)},...
    'Google Drive\SchallmoLab\Sponheim\VA_NeuralSync_SYON\SSVEP\stimuli'));

monitor.pix = [1920 1080]; % based on SJJ code...
monitor.width = [53.2 30.1]; % cm
monitor.dist = 57; % cm

monitor.subtend = atand((monitor.width./2)./monitor.dist)*2;
monitor.pix_per_deg = monitor.pix./monitor.subtend;
monitor.pix_per_cm = monitor.pix./monitor.width;

pixelsPerDegree = round(mean(monitor.pix_per_deg));
pixelsPerCM = round(mean(monitor.pix_per_cm));

hz = 144;

targetOrients = [0 pi/2];

SF = 4; % cpd, Ani suggests higher SF will yield stronger C1 response

y_ecc_upper = 1.7101; % this is upper
x_ecc_upper = 4.6985;

y_ecc_lower = 3.5355; % lower
x_ecc_lower = 3.5355;

diag_ecc_upper = sqrt(x_ecc_upper^2+y_ecc_upper^2);
diag_ecc_lower = sqrt(x_ecc_lower^2+y_ecc_lower^2);

diskRadius = 1.0; % degrees
surroundRadius = 8;
blurr_SD = 0.05;

circleRadius = diskRadius + 1/16; % degrees, size of the circle to reduce uncertainty, similar to Petrov 2009
circleCon = .15; % 1% contrast
circleWidth = .04; % 1.2 arcmin wide, about 2 pixel

backgroundColor = 128;
fix_radius = 0.15;
fixSize = 5;
fixColor = 0; % Fixation mark,
phoSize = 40; % pixels diameter
phoColor = 255; % Fixation mark,

clutScale = 0;

center_contrasts = [0 0.1 0.2 0.4 0.8];
surr_contrast = 1;

%% make stimuli  for all conditions
h = waitbar(0,'making stimuli, please wait...');

useConditions = 1:3; % we don't need surround only, same as 0% contrast targets

for iC = useConditions
    condition = useConditions(iC);
    
    for iCont = 1:numel(center_contrasts)
        waitbar(((iC-1)*numel(center_contrasts) + iCont)/...
            (numel(useConditions)*numel(center_contrasts)), h)
        
        for iUpLow = 1:2
            
            for iFix = 1:3 % 1 = none, 2 = center black for task, 3 = bottom right white for photodiode
                
                if condition == 1 % target alone
                    relOrient = 0;
                    matchC = center_contrasts(iCont);
                    surroundC = 0;
                    gapwidth = 0; % degrees, aka 1.5 min each
                    dataLabel{1} = 'targ';
                    
                elseif condition == 2; % parallel
                    relOrient = 0;
                    matchC = center_contrasts(iCont);
                    surroundC = surr_contrast;
                    gapwidth = 0.25; % gap in degrees
                    dataLabel{2} = 'para';
                    
                elseif condition == 3; % orthogonal
                    relOrient = 2;
                    matchC = center_contrasts(iCont);
                    surroundC = surr_contrast;
                    gapwidth = 0.25; % gap degrees
                    dataLabel{3} = 'ortho';
                    
                elseif condition == 4; % surround
                    if iCont == 1 % only need to make these stimuli 1 time, center = 0 contrast
                        relOrient = 0;
                        matchC = 0;
                        surroundC = surr_contrast;
                        gapwidth = 0.25; % gap in degrees
                        dataLabel{4} = 'surr';
                    else continue
                    end
                    
                else
                    error('Don''t recognize condition index.')
                end
                
                % Now make the mask and some gratings for the centers
                %            imgSize = round(pixelsPerDegree*2*(surroundRadius + .5));
                imgSize = monitor.pix;
                [x y] = meshgrid(1:imgSize(1),1:imgSize(2));
                x = (x-imgSize(1)/2)/pixelsPerDegree;
                y = (y-imgSize(2)/2)/pixelsPerDegree;
                
                nPhasesPerCycle = 6; %
                
                phases = 2*pi*(0:(1/nPhasesPerCycle):1); phases = phases(1:nPhasesPerCycle);
                
                % make a family of gratings for each condition
                
                if strcmp(options.write_cmd , 'imwrite') % up and down are switched for these 2 options...
                    if iUpLow == 2
                        mask = double(sqrt((x+x_ecc_upper).^2 + (y+y_ecc_upper).^2) < diskRadius) + ...
                            double(sqrt((x-x_ecc_upper).^2 + (y+y_ecc_upper).^2) < diskRadius);
                    elseif iUpLow == 1
                        mask = double(sqrt((x+x_ecc_lower).^2 + (y-y_ecc_lower).^2) < diskRadius) + ...
                            double(sqrt((x-x_ecc_lower).^2 + (y-y_ecc_lower).^2) < diskRadius);
                    end
                elseif strcmp(options.write_cmd , 'print')
                    if iUpLow == 1
                        mask = double(sqrt((x+x_ecc_upper).^2 + (y-y_ecc_upper).^2) < diskRadius) + ...
                            double(sqrt((x-x_ecc_upper).^2 + (y-y_ecc_upper).^2) < diskRadius);
                    elseif iUpLow == 2
                        mask = double(sqrt((x+x_ecc_lower).^2 + (y+y_ecc_lower).^2) < diskRadius) + ...
                            double(sqrt((x-x_ecc_lower).^2 + (y+y_ecc_lower).^2) < diskRadius);
                    end
                end
                
                g_filt = fspecial('gaussian',length(mask)+1,blurr_SD*pixelsPerDegree);
                mask = conv2(mask,g_filt,'same');
                
                for iOrient = 1:length(targetOrients)
                    orient = targetOrients(iOrient);
                    
                    for iP = 1:length(phases)
                        gratings{iC,iOrient,iCont,iUpLow}(:,:,iP) = ...
                            mask.*cos(phases(iP)+2*pi*SF*(x*cos(orient) + y*sin(orient)));
                    end
                end
                
                if strcmp(options.write_cmd , 'imwrite') % up and down are switched for these 2 options...
                    
                    circleMask =  double(sqrt((x+x_ecc_upper).^2 + (y+y_ecc_upper).^2) >= (circleRadius)).* ...
                        double(sqrt((x+x_ecc_upper).^2 + (y+y_ecc_upper).^2) < (circleRadius + circleWidth)) + ...
                        double(sqrt((x-x_ecc_upper).^2 + (y+y_ecc_upper).^2) >= (circleRadius)).* ...
                        double(sqrt((x-x_ecc_upper).^2 + (y+y_ecc_upper).^2) < (circleRadius + circleWidth)) + ...
                        double(sqrt((x+x_ecc_lower).^2 + (y-y_ecc_lower).^2) >= (circleRadius)).* ...
                        double(sqrt((x+x_ecc_lower).^2 + (y-y_ecc_lower).^2) < (circleRadius + circleWidth)) + ...
                        double(sqrt((x-x_ecc_lower).^2 + (y-y_ecc_lower).^2) >= (circleRadius)).* ...
                        double(sqrt((x-x_ecc_lower).^2 + (y-y_ecc_lower).^2) < (circleRadius + circleWidth));
                    
                    % make a family of surrounds
                    surrMask = double(sqrt(x.^2 + y.^2) < surroundRadius);
                    cutMask = double(sqrt((x+x_ecc_upper).^2 + (y+y_ecc_upper).^2) < (diskRadius + gapwidth)) + ...
                        double(sqrt((x-x_ecc_upper).^2 + (y+y_ecc_upper).^2) < (diskRadius + gapwidth)) + ...
                        double(sqrt((x+x_ecc_lower).^2 + (y-y_ecc_lower).^2) < (diskRadius + gapwidth)) + ...
                        double(sqrt((x-x_ecc_lower).^2 + (y-y_ecc_lower).^2) < (diskRadius + gapwidth)) + ...
                        double( x.^2 + y.^2 < fix_radius);
                    surrMask = surrMask - cutMask;
                    
                elseif strcmp(options.write_cmd , 'print') % up and down are switched for these 2 options...
                    
                    circleMask =  double(sqrt((x+x_ecc_upper).^2 + (y-y_ecc_upper).^2) >= (circleRadius)).* ...
                        double(sqrt((x+x_ecc_upper).^2 + (y-y_ecc_upper).^2) < (circleRadius + circleWidth)) + ...
                        double(sqrt((x-x_ecc_upper).^2 + (y-y_ecc_upper).^2) >= (circleRadius)).* ...
                        double(sqrt((x-x_ecc_upper).^2 + (y-y_ecc_upper).^2) < (circleRadius + circleWidth)) + ...
                        double(sqrt((x+x_ecc_lower).^2 + (y+y_ecc_lower).^2) >= (circleRadius)).* ...
                        double(sqrt((x+x_ecc_lower).^2 + (y+y_ecc_lower).^2) < (circleRadius + circleWidth)) + ...
                        double(sqrt((x-x_ecc_lower).^2 + (y+y_ecc_lower).^2) >= (circleRadius)).* ...
                        double(sqrt((x-x_ecc_lower).^2 + (y+y_ecc_lower).^2) < (circleRadius + circleWidth));
                    
                    % make a family of surrounds
                    surrMask = double(sqrt(x.^2 + y.^2) < surroundRadius);
                    cutMask = double(sqrt((x+x_ecc_upper).^2 + (y-y_ecc_upper).^2) < (diskRadius + gapwidth)) + ...
                        double(sqrt((x-x_ecc_upper).^2 + (y-y_ecc_upper).^2) < (diskRadius + gapwidth)) + ...
                        double(sqrt((x+x_ecc_lower).^2 + (y+y_ecc_lower).^2) < (diskRadius + gapwidth)) + ...
                        double(sqrt((x-x_ecc_lower).^2 + (y+y_ecc_lower).^2) < (diskRadius + gapwidth)) + ...
                        double( x.^2 + y.^2 < fix_radius);
                    surrMask = surrMask - cutMask;
                    
                end
                
                surrMask = conv2(surrMask,g_filt,'same');
                for iOrient = 1:length(targetOrients)
                    if relOrient == 2
                        surroundOrient = targetOrients(iOrient -1 + 2*mod(iOrient,2));
                    else
                        surroundOrient = targetOrients(iOrient);
                    end
                    for iP = 1:length(phases)
                        if surroundC > 0
                            surrounds{iC,iOrient}(:,:,iP) = surrMask.* ...
                                cos(phases(iP)+2*pi*SF*(x*cos(surroundOrient) + y*sin(surroundOrient)));
                        else
                            surrounds{iC,iOrient}(:,:,iP) = zeros(size(gratings{iC,iOrient}(:,:,iP)));
                        end
                        
                    end
                end
                
                for iOrient = 1:2
                    for iP = 1:length(phases)
                        center = 128*(matchC)*gratings{iC,iOrient,iCont,iUpLow}(:,:,iP)*2^clutScale;
                        surround = 128*(surroundC)*surrounds{iC,iOrient}(:,:,iP)*2^clutScale;
                        ring = - 128*circleMask*circleCon;
                        
                        use_stim{iC,iOrient,iCont,iUpLow,iFix,iP} = ...
                            uint8(center + surround + ring + backgroundColor);
                        
                        if iFix == 2 % center black for fix target
                            box_size = size(use_stim{iC,iOrient,iCont,iUpLow,iFix,iP});
                            
                            use_stim{iC,iOrient,iCont,iUpLow,iFix,iP}...
                                (round(box_size(1)/2)-fixSize:round(box_size(1)/2)+fixSize,...
                                round(box_size(2)/2)-fixSize:round(box_size(2)/2)+fixSize) = fixColor;
                            
                        elseif iFix == 3 % bottom right white for photodiode
                            box_size = size(use_stim{iC,iOrient,iCont,iUpLow,iFix,iP});
                            if strcmp(options.write_cmd , 'imwrite') % up and down are switched for these 2 options...
                                
                                use_stim{iC,iOrient,iCont,iUpLow,iFix,iP}...
                                    (box_size(1)-2*phoSize+1:box_size(1)-phoSize, ...
                                    box_size(2)-2*phoSize+1:box_size(2)-phoSize) = phoColor;
                                % leave a gap between white square and edge
                                
                            elseif strcmp(options.write_cmd , 'print') % up and down are switched for these 2 options...
                                
                                use_stim{iC,iOrient,iCont,iUpLow,iFix,iP}...
                                    (phoSize+1:2*phoSize, ...
                                    box_size(2)-2*phoSize:box_size(2)-phoSize) ...
                                    = phoColor;
                            end
                        end
                    end
                end
            end
        end
    end
end
close(h)
%% choose the stimulus to draw
%imgSizeCM = size(use_stim{1},1)/round(pixelsPerCM);
imgSizeCM = size(use_stim{1})./round(pixelsPerCM);
cmap = repmat(0:1/255:1,3,1)';
figure;
set(gcf,'POS',[200 200 imgSize(1) imgSize(2)])
set(gcf,'units','centimeters','PaperPosition',[0 0 imgSizeCM(2) imgSizeCM(1)])
subplot('Position',[0 0 1 1])
colormap(cmap); box off; axis equal; hold on;
set(gca,'YTick',[],'XTick',[])

%dpi = round(mean(monitor.pix_per_cm)*2.54);
dpi = round(mean(monitor.pix_per_cm)); % images are being generated at 2.54 x the intended size...

for iC = useConditions
    for iO = 1:length(targetOrients)
        for iCont = 1:numel(center_contrasts)
            for iUpLow = 1:2
                for iFix = 1:3
                    for iP = 1:length(phases);
                        if iCont == 1 && (iUpLow > 1 || (iP > 1 && iC == 1) )
                            % if target = 0% contrast, skip extra blanks
                            continue
                        else
                            
                            %                         imagesc(use_stim{iC,iO,iCont,iUpLow,iFix,iP},[0 255])
                            stim_name = ['grating' num2str(iC) '_cont' num2str(iCont) ...
                                '_or' num2str(iO) '_upLow' num2str(iUpLow) ...
                                '_fix' num2str(iFix) '_ph' num2str(iP) '.bmp'];
                            imwrite(use_stim{iC,iO,iCont,iUpLow,iFix,iP}, ...
                                stim_name, 'BMP')
                            
                            %%% print command is giving crap results, switching
                            %%% to imwrite...
                            %                         print(gcf,'-dbmp',['-r' num2str(dpi)],stim_name)
                            %                      stim_name = ['grating' num2str(iC) '_or' num2str(iO) '_ph' num2str(iP)];
                            % print(gcf,'-depsc',['-r500'],stim_name)
                        end
                    end
                end
            end
        end
    end
end