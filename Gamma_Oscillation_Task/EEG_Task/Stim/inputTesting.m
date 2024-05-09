clear all; close all;

config_io;
% optional step: verify that the inpoutx64 driver was successfully initialized
global cogent;
if( cogent.io.status ~= 0 )
   error('inp/outp installation failed');
end
KbName('UnifyKeyNames');
options.buttons.buttonEscape = KbName('escape');

options.addressOut = hex2dec('A010');
options.addressIn = hex2dec('C010'); % may need to be C000, was "status" channels in Presentation, 4-bit
% object=io64;
% status=io64(object);

byte = 99;
% Continuosly read the input port
counter = 1;
[w,rect] = Screen('OpenWindow',1);
[~,~,buttons{counter},~,~,~] = GetMouse(1);
% outp(options.addressIn,0);
datumHolder = inp(options.addressIn)
datum(1) = inp(options.addressIn)
while 1
        datumHolder = inp(options.addressIn);
        if datumHolder ~= datum(counter)
            counter = counter+1
            datum(counter)=inp(options.addressIn)
%             outp(options.addressIn,0)
        end
%     [~,~,buttonsHolder,~,~,~] = GetMouse;
%     if buttonsHolder(1) ~= buttons{counter}(1) ||...
%             buttonsHolder(2) ~= buttons{counter}(2) ||...
%             buttonsHolder(3) ~= buttons{counter}(3)
%         counter = counter+1;
%         [~,~,buttons{counter},~,~,~] = GetMouse;
%     end
    [keyisdown, secs, keycode] = KbCheck;
    if keycode(options.buttons.buttonEscape)
        sca
        break
    end
    
end