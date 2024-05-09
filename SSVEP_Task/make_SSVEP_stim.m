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
    'Google Drive\SchallmoLab\SYON\SSVEP\stimuli'));

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
fix_radius = 0.3;
% fixSize = 5;
% fixColor = 0; % Fixation mark,
colorOval = 0; % color of the two fixation circles [R G B]
colorCross = 255; % color of the fixation Cross [R G B]
d1 = 0.6; % diameter of outer circle (degrees)
d2 = 0.2; % diameter of inner circle (degrees)
bar_width = d1/6;

phoSize = 40; % pixels diameter
phoColor = 255; % Fixation mark,

clutScale = 0;

center_contrasts = [0 0.1 0.2 0.4 0.8];
surr_contrast = 1;

%% make stimuli  for all conditions
h = waitbar(0,'making stimuli, please wait...');

% first make fixation mark
imgSize = [d1 d1].*pixelsPerDegree; % deg wide

[x, y] = meshgrid(1:imgSize(1),1:imgSize(2));

x = (x-imgSize(1)/2)/pixelsPerDegree;
y = (y-imgSize(2)/2)/pixelsPerDegree;

outer_circle = double(sqrt((x).^2 + (y).^2) < ...
    d1/2);
inner_circle = double(sqrt((x).^2 + (y).^2) < ...
    d2/2);

fixation = ones(size(x)).*backgroundColor; % set background gray
fixation(outer_circle == 1) = colorOval; % make outer circle black
v_bar = (x > (- bar_width)) & (x < (bar_width)) & (outer_circle == 1);
fixation(v_bar) = colorCross; % make vertical cross bar white
h_bar = (y > (- bar_width)) & (y < (bar_width)) & (outer_circle == 1);
fixation(h_bar) = colorCross; % make horizontal cross bar white
fixation(inner_circle == 1) = colorOval; % make inner circle black
fixation = repmat(fixation, [1 1 3]);

fixation_red = ones(size(x)).*backgroundColor; % set background gray
fixation_red(outer_circle == 1) = 0; % make outer circle black
v_bar = (x > (- bar_width)) & (x < (bar_width)) & (outer_circle == 1);
fixation_red(v_bar) = colorCross; % make vertical cross bar white
h_bar = (y > (- bar_width)) & (y < (bar_width)) & (outer_circle == 1);
fixation_red(h_bar) = colorCross; % make horizontal cross bar white
fixation_red(inner_circle == 1) = 0.2; % make inner circle black
fixation_red = repmat(fixation_red, [1 1 3]);
fixation_red( fixation_red(:,:,1) == 0 ) = 255;
fixation_red( fixation_red == 0.2 ) = 0;

% fixation_B = ones(size(x)).*backgroundColor./255; % set background gray
% fixation_B(:,10:15) = 0;
% fixation_B(1:5,15:35) = 0;
% fixation_B(39:44,15:35) = 0;
% fixation_B(20:25,15:35) = 0;
% fixation_B(5:20,35:40) = 0;
% fixation_B(25:39,35:40) = 0;

% then make the rest of the stimuli

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
                        gratings = ...
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
                            surrounds = surrMask.* ...
                                cos(phases(iP)+2*pi*SF*(x*cos(surroundOrient) + y*sin(surroundOrient)));
                        else
                            surrounds = zeros(size(gratings));
                        end
                        
                    end
                end
                
                for iOrient = 1:2
                    for iP = 1:length(phases)
                        center = 128*(matchC)*gratings*2^clutScale;
                        surround = 128*(surroundC)*surrounds*2^clutScale;
                        ring = - 128*circleMask*circleCon;
                        
                        use_stim = ...
                            repmat( uint8(center + surround + ring + backgroundColor) , [1 1 3]);
                        
                        box_size = size(use_stim);
                        
                        if iFix == 1 % black fixation
                            use_stim...
                                (round(box_size(1)/2)-size(fixation,1)/2:...
                                round(box_size(1)/2)+size(fixation,1)/2-1,...
                                round(box_size(2)/2)-size(fixation,2)/2:...
                                round(box_size(2)/2)+size(fixation,2)/2-1, :) = fixation;
                            
                        elseif iFix == 2 % red fixation
                            
                            use_stim...
                                (round(box_size(1)/2)-size(fixation,1)/2:...
                                round(box_size(1)/2)+size(fixation,1)/2-1,...
                                round(box_size(2)/2)-size(fixation,2)/2:...
                                round(box_size(2)/2)+size(fixation,2)/2-1, :) = fixation_red;
                            
                        elseif iFix == 3 % bottom right white for photodiode
                            if strcmp(options.write_cmd , 'imwrite') % up and down are switched for these 2 options...
                                use_stim...
                                    (round(box_size(1)/2)-size(fixation,1)/2:...
                                    round(box_size(1)/2)+size(fixation,1)/2-1,...
                                    round(box_size(2)/2)-size(fixation,2)/2:...
                                    round(box_size(2)/2)+size(fixation,2)/2-1, :) = fixation;
                                
                                use_stim...
                                    (box_size(1)-2*phoSize+1:box_size(1)-phoSize, ...
                                    box_size(2)-2*phoSize+1:box_size(2)-phoSize, :) = phoColor;
                                % leave a gap between white square and edge
                                
                            elseif strcmp(options.write_cmd , 'print') % up and down are switched for these 2 options...
                                
                                use_stim...
                                    (phoSize+1:2*phoSize, ...
                                    box_size(2)-2*phoSize:box_size(2)-phoSize) ...
                                    = phoColor;
                            end
                        end
                        if strcmp(options.write_cmd , 'imwrite')
                            stim_name = ['grating' num2str(iC) '_cont' num2str(iCont) ...
                                '_or' num2str(iOrient) '_upLow' num2str(iUpLow) ...
                                '_fix' num2str(iFix) '_ph' num2str(iP) '.bmp'];
                            imwrite(use_stim, stim_name, 'BMP')
                        elseif strcmp(options.write_cmd , 'print')
                            error('MPS didn''t write this yet...');
                        end
                    end
                end
            end
        end
    end
end
close(h)
%% choose the stimulus to draw
% %imgSizeCM = size(use_stim{1},1)/round(pixelsPerCM);
% imgSizeCM = size(use_stim{1})./round(pixelsPerCM);
% cmap = repmat(0:1/255:1,3,1)';
% figure;
% set(gcf,'POS',[200 200 imgSize(1) imgSize(2)])
% set(gcf,'units','centimeters','PaperPosition',[0 0 imgSizeCM(2) imgSizeCM(1)])
% subplot('Position',[0 0 1 1])
% colormap(cmap); box off; axis equal; hold on;
% set(gca,'YTick',[],'XTick',[])
%
% %dpi = round(mean(monitor.pix_per_cm)*2.54);
% dpi = round(mean(monitor.pix_per_cm)); % images are being generated at 2.54 x the intended size...
%
% for iC = useConditions
%     for iO = 1:length(targetOrients)
%         for iCont = 1:numel(center_contrasts)
%             for iUpLow = 1:2
%                 for iFix = 1:3
%                     for iP = 1:length(phases);
%                         if iCont == 1 && (iUpLow > 1 || (iP > 1 && iC == 1) )
%                             % if target = 0% contrast, skip extra blanks
%                             continue
%                         else
%
% %                         imagesc(use_stim{iC,iO,iCont,iUpLow,iFix,iP},[0 255])
%                         stim_name = ['grating' num2str(iC) '_cont' num2str(iCont) ...
%                             '_or' num2str(iO) '_upLow' num2str(iUpLow) ...
%                             '_fix' num2str(iFix) '_ph' num2str(iP) '.bmp'];
%                         imwrite(use_stim{iC,iO,iCont,iUpLow,iFix,iP}, ...
%                             stim_name, 'BMP')
%
%                         %%% print command is giving crap results, switching
%                         %%% to imwrite...
% %                         print(gcf,'-dbmp',['-r' num2str(dpi)],stim_name)
%   %                      stim_name = ['grating' num2str(iC) '_or' num2str(iO) '_ph' num2str(iP)];
%                         % print(gcf,'-depsc',['-r500'],stim_name)
%                         end
%                     end
%                 end
%             end
%         end
%     end
% end
%
% imwrite(fixation, 'fixation_black.bmp', 'BMP')
%
% imwrite(fixation_red, 'fixation_red.bmp', 'BMP')
%
% imwrite(fixation_B, 'fixation_B.bmp', 'BMP')

%% make an icon for JOV
%
% % n.b. this runs properly on my old Dell XPS laptop, but not on the Surface
% % Pro 3 -- likely the very high screen resolution is a problem?
%
% %iC = 3;
% iP = 1;
% iOrient = 1;
% matchC = .77;
% surroundC = .77;
%
% iconSize  = 96;
% figure(1); clf
% set(gcf,'menubar', 'none', 'toolbar', 'none')
% WindowAPI(1,'Position',[200 200 iconSize iconSize])
% %set(gcf,'POS',[iconSize iconSize iconSize iconSize])
% %set(gcf,'units','pixels','PaperPosition',[0 0 iconSize iconSize])
% subplot('Position',[0 0 1 1])
% cmap = repmat(0:1/255:1,3,1)';
% colormap(cmap); box off; axis equal; hold on;
% set(gca,'YTick',[],'XTick',[])
%
% filename = 'Schallmo_JOV_icon.gif';
% delay_time = 1.5;
%
% for iC = 2:3
%     center = 128*(matchC)*gratings{iC,iOrient}(:,:,iP)*2^clutScale;
%     surround = 128*(surroundC)*surrounds{iC,iOrient}(:,:,iP)*2^clutScale;
%     ring = - 128*circleMask*circleCon;
%
%     imagesc(center+surround+ring+backgroundColor,[0 255])
%
%     drawnow
%     frame = getframe(1);
%     im = frame2im(frame);
%     [imind,cm] = rgb2ind(im,256);
%     if iC == 2;
%         imwrite(imind,cm,filename,'gif','DelayTime',delay_time, 'Loopcount',inf);
%     else
%         imwrite(imind,cm,filename,'gif','DelayTime',delay_time,'WriteMode','append');
%     end
% end

%% make eps figures for paper
% stim_name = 'orth_plaid';
%
% switch stim_name
%
%     case 'blank'
%         iC = 0; % condition
%         iO = 1; % orientation
%         iP = 1; % phase
%         which_plaid = 0;
%         use_fix = dk_fix_both;
%         upper_lower = 1;
%
%     case 'surr_only'
%         iC = 4; % condition
%         iO = 1; % orientation
%         iP = 1; % phase
%         which_plaid = 0;
%         use_fix = lt_fix_both;
%         upper_lower = 1;
%
%     case 'para'
%         iC = 2; % condition
%         iO = 1; % orientation
%         iP = 1; % phase
%         which_plaid = 0;
%         use_fix = lt_fix_both;
%         upper_lower = 1;
%
%     case 'C1_lower'
%         iC = 1; % condition
%         iO = 2; % orientation
%         iP = 4; % phase
%         which_plaid = 0;
%         use_fix = lt_fix_both;
%         upper_lower = 2;
%
%     case 'center'
%         iC = 1; % condition
%         iO = 2; % orientation
%         iP = 4; % phase
%         which_plaid = 0;
%         use_fix = lt_fix_both;
%         upper_lower = 1;
%
%     case 'orth'
%         iC = 3; % condition
%         iO = 1; % orientation
%         iP = 4; % phase
%         which_plaid = 0;
%         use_fix = lt_fix_both;
%         upper_lower = 1;
%
%     case 'orth_plaid'
%         iC = 3; % condition
%         iO = 1; % orientation
%         iP = 4; % phase
%         which_plaid = 3;
%         use_fix = lt_fix_both;
%         upper_lower = 1;
%
%     case 'plaid_PD_right'
%         iC = 4; % condition
%         iO = 2; % orientation
%         iP = 1; % phase
%         which_plaid = 0;
%         use_fix = lt_fix2;
%         upper_lower = 1;
%
%     case 'plaid_PD_left'
%         iC = 1; % condition
%         iO = 2; % orientation
%         iP = 1; % phase
%         which_plaid = 1;
%         use_fix = lt_fix1;
%         upper_lower = 1;
%
%     case 'PD_right'
%         iC = 4; % condition
%         iO = 2; % orientation
%         iP = 1; % phase
%         which_plaid = 0;
%         use_fix = lt_fix2;
%         upper_lower = 1;
%
%     case 'PD_left'
%         iC = 1; % condition
%         iO = 2; % orientation
%         iP = 1; % phase
%         which_plaid = 0;
%         use_fix = lt_fix1;
%         upper_lower = 1;
%
%     case 'OD_left'
%         iC = 1; % condition
%         iO = 2; % orientation
%         iP = 1; % phase
%         which_plaid = 0;
%         use_fix = lt_fix1;
%         upper_lower = 1;
%
%     case 'OD_right'
%         iC = 4; % condition
%         iO = 1; % orientation
%         iP = 1; % phase
%         which_plaid = 0;
%         use_fix = lt_fix2;
%         upper_lower = 1;
% end
%
% if iC == 0
%     plot_me = ring+128;
%     plot_me2 = plot_me;
% elseif ~which_plaid
%     plot_me = use_stim{iC,iO,iP};
%     plot_me2 = plot_me;
% elseif which_plaid == 1
%     plot_me = use_plaids{iC,iO,iP};
%     plot_me2 = use_stim{iC,iO,iP};
% elseif which_plaid == 2
%     plot_me2 = use_plaids{iC,iO,iP};
%     plot_me = use_stim{iC,iO,iP};
% elseif which_plaid == 3
%     plot_me2 = use_plaids{iC,iO,iP};
%     plot_me = use_plaids{iC,iO,iP};
% end
% if upper_lower == 1
%     y_ecc = 2;
%     x_ecc = 4.96;
% elseif upper_lower == 2
%     y_ecc = -3.7816;
%     x_ecc = 3.7816;
% end
%
% %cd('C:\Users\mpschallmo\OneDrive - UW Office 365\MurrayLab\SSERP\stimuli\Fig1')
% cd('E:\Google Drive\MurrayLab\SSERP\Figures\eps\Fig1')
% imgSizeCM = size(use_stim{1},1)/round(pixelsPerCM);
% scale_img = [2.5 1.2];
% cmap = repmat(0:1/255:1,3,1)';
% cmap = [cmap; 1 0 0; 0 0 1];
% figure;
% set(gcf,'POS',[200 100 imgSize*scale_img(1) imgSize*scale_img(2)])
% set(gcf,'units','centimeters','PaperPosition',[0 0 imgSizeCM*scale_img(2) imgSizeCM*scale_img(2)])
% subplot('Position',[0 0 1 1])
% colormap(cmap); box off; axis equal; hold on;
% set(gca,'YTick',[],'XTick',[])
%
% dpi = round(mean(monitor.pix_per_cm)); % images are being generated at 2.54 x the intended size...
%
% plot_stim = backgroundColor*ones(round(size(use_stim{1},1)*scale_img(2)),...
%     round(size(use_stim{1},2)*scale_img(1)));
%
% if upper_lower == 1
%     center_pos = [round(size(plot_stim,1)./3.75) round(size(plot_stim,2)./2)];
% elseif upper_lower == 2
%     center_pos = [round(3*size(plot_stim,1)./4) round(size(plot_stim,2)./2)];
% end
% adjust_left_x = center_pos(2) - round(x_ecc * pixelsPerDegree);
% left_window = (adjust_left_x - size(use_stim{1},1)/2):(adjust_left_x + size(use_stim{1},1)/2 -1);
% adjust_right_x = center_pos(2) + round(x_ecc * pixelsPerDegree);
% right_window = (adjust_right_x - size(use_stim{1},1)/2):(adjust_right_x + size(use_stim{1},1)/2 -1);
% adjust_y = center_pos(1) + round(y_ecc * pixelsPerDegree);
% y_window = (adjust_y - size(use_stim{1},1)/2):(adjust_y + size(use_stim{1},1)/2 -1);
%
% y_window = y_window(y_window > 0);
%
% plot_stim(y_window,left_window) = plot_me(end-length(y_window)+1:end,:);
% plot_stim(y_window,right_window) = plot_me2(end-length(y_window)+1:end,:);
%
% fix_window_x = (center_pos(2) - size(dk_fix2,1)/2):(center_pos(2) + size(dk_fix2,1)/2 -1);
% fix_window_y = (center_pos(1) - size(dk_fix2,1)/2):(center_pos(1) + size(dk_fix2,1)/2 -1);
%
% plot_stim(fix_window_y,fix_window_x) = use_fix;
%
% imagesc(plot_stim,[1 258])

% %%
% print(gcf,'-deps',['-r600'],stim_name)