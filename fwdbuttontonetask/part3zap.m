%part 3

%base case:
if startTime == 0
    %this should never be true
elseif lastTime == 0
    %then we have the first interrupt trial time so
    iti = [nextTime - startTime];
    lastTime = nextTime;
else
    %then lastTime = something
    iti = [iti; nextTime - lastTime];
    lastTime = nextTime;
end