function onset_time = PresentTextScreen(t, mainwindow, blankscreen, start_time, textsize, xposition, color)

% function onset_time = PresentTextScreen(t, mainwindow, blankscreen, start_time)
%
% Presents text at the center of the screen.
%
% Last modified by Sam Norman-Haignere on 2015-06-24

if nargin <  5
    textsize = 26;
end

if nargin < 6
    xposition = 'center';
end

if nargin < 7
    color = [];
end


Screen('CopyWindow', blankscreen, mainwindow);
Screen('TextSize', mainwindow, textsize);
DrawFormattedText(mainwindow, t, xposition, 'center',color,[],[],[],1.5);

if nargin < 4
    onset_time = Screen('Flip',mainwindow);
else
    onset_time = Screen('Flip',mainwindow, start_time);
end