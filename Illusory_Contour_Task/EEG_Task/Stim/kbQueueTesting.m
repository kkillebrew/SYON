% Test code for using KbQueue and mouse inputs

clear all; close all;

[options.windowNum, options.rect] = Screen('OpenWindow',2,[127 127 127]);
options.yc = options.rect(4)/2;
options.xc = options.rect(3)/2;

KbName('UnifyKeyNames');
buttonEscape = KbName('Escape');
buttonSpace = KbName('Space');
buttonLeftMouse = KbName('Left_Mouse');
buttonRightMouse = KbName('Right_Mouse');
buttonMiddleMouse  = KbName('Middle_Mouse');

% Define keyboard
[nums, names] = GetKeyboardIndices;
[mouseNums, mouseNames] = GetMouseIndices;
options.dev_id_mouse = mouseNums(1);

% Creat KbQueue
keyList = zeros([256 1]);
keyList([buttonLeftMouse buttonRightMouse buttonMiddleMouse]) = 1;
KbQueueCreate(dev_id_mouse,keyList);
KbQueueStart(dev_id_mouse);

for n=1:2  
    
    KbQueueFlush(dev_id_mouse);
    
%     [keyisdown, secs, keycode] = KbCheck;
%     if keycode(buttonEscape)
%         break
%     end
    
    [~, syncTime(n), ~, ~, ~] = Screen('Flip',options.windowNum);
    
    % Present first sentence
    text1='This is the first sentence.';
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
    DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,[0 0 0]);
    [~, firstSentTime(n), ~, ~, ~] = Screen('Flip',options.windowNum,...
        syncTime(n));
    
    % Present second sentence
    text1='This is the sEcOnD sentence.';
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
    DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,[0 0 0]);
    [~, secondSentTime(n), ~, ~, ~] = Screen('Flip',options.windowNum,...
        (firstSentTime(n)+2));
    
    % Present third sentence
    text1='This is the THIRD sentence.';
    textHeight = RectHeight(Screen('TextBounds',options.windowNum,text1));
    DrawFormattedText(options.windowNum,text1,'center',options.yc-(textHeight/2)-150,[0 0 0]);
    [~, thirdSentTime(n), ~, ~, ~] = Screen('Flip',options.windowNum,...
        (secondSentTime(n)+2));
    
    [~, endTime(n), ~, ~, ~] = Screen('Flip',options.windowNum,...
        (thirdSentTime(n)+2));
    
    % Check for response
    [pressed{n} firstPress{n} firstRelease{n} lastPress{n} lastRelease{n}] = KbQueueCheck(dev_id_mouse);
    
    % Determine what button/s were pressed
    numResponses(n) = length(find(firstPress{1}>0));
    
%     % Determine time response made relative to start of trial (time of queue flush)
%     respTimeFirst(n) = firstPress{n}(buttonSpace) - syncTime(n);
%     respTimeLast(n) = lastPress{n}(buttonSpace) - syncTime(n);
    
end

KbQueueStop(dev_id_mouse);


Screen('CloseAll')





