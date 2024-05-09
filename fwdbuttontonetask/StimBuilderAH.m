
copyfile('ButtonAHTemplate.sce', 'Tone Playback.sce', 'f'); %%Changed StimAH.sce to Tone Playback.sce
fid = fopen('Tone Playback.sce', 'a+');

%%%output should be ITI \t ; \n
% 2		;
itis = dlmread('iti.txt');
for i = 2:length(itis)
    fprintf(fid,'%i\t;\n',itis(i));
end
%end of file:
fprintf(fid, '};\n\n');

fprintf(fid, 'trial {\n');
fprintf(fid, '\ttrial_duration = 1000;\n');
fprintf(fid, '\tpicture {\n\t\ttext {caption = "+";\n\t\tfont_size = 14;}; # fixation cross\n');
fprintf(fid, '\tx = 0; y = 0; # centre of screen\n\t};\n\ttime = 50;\n\tduration = next_picture;\n\tport_code = 129;\n};\n\n');

fclose(fid);