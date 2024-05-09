%% Show 'B' fixation mark to indicate a blink can be made
function newFixationTex = do_fixation_blink(options)

% Make initial fixation texture
newFixationArray(:,:,1) = zeros([ceil(options.fix.fixSizeOuter * options.PPD), ceil(options.fix.fixSizeOuter * options.PPD)]) + options.grayCol(1);
newFixationArray(:,:,2) = zeros([ceil(options.fix.fixSizeOuter * options.PPD), ceil(options.fix.fixSizeOuter * options.PPD)]) + options.grayCol(1);
newFixationArray(:,:,3) = zeros([ceil(options.fix.fixSizeOuter * options.PPD), ceil(options.fix.fixSizeOuter * options.PPD)]) + options.grayCol(1);
newFixationArray(:,:,4) = zeros([ceil(options.fix.fixSizeOuter * options.PPD), ceil(options.fix.fixSizeOuter * options.PPD)]) + 255;
newFixationTex = Screen('MakeTexture',options.windowNum,newFixationArray);

% Draw 'B'
text1 = 'B';
% textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
% textWidth = RectWidth(Screen('TextBounds',options.windowNum,text1));
DrawFormattedText(newFixationTex,text1,'center','center',options.fixCol);

end