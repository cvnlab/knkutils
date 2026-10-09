function showinstructionscreen(fileIn,txtOffset,instTextWrap,textsize,background,offset)

if ~exist('offset','var') || isempty(offset)
  offset = [0 0];
end

fd = fopen(fileIn, 'rt');
mytext = '';
tl = fgets(fd);
lcount = 0;
while lcount < 48
    mytext = [mytext tl]; %#ok<*AGROW>
    tl = fgets(fd);
    lcount = lcount + 1;
end
fclose(fd);
instr=mytext;

% get some basics
win = firstel(Screen('Windows'));
rect = Screen('Rect',win);
rect = rect + [offset(1) offset(2) offset(1) offset(2)];

% draw background
Screen('FillRect', win, background);
Screen('TextSize', win, textsize);
Screen('TextStyle', win, 0);
DrawFormattedText(win, instr, 'center', (rect(4)/2)-txtOffset,0,instTextWrap,[],[],[],[],rect);    
Screen('Flip', win);
