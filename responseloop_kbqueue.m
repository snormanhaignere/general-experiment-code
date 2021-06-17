function [rt, rkey, press_times, flipped] = responseloop_kbqueue(start_time,max_rt,response_codes,deviceNumber,varargin)

% [rt, rkey, press_times, flipped] = responseloop_kbqueue(start_time,max_rt,response_codes,deviceNumber,varargin)
%
% Uses KbQueue to look for particular button responses. KbQueue has a
% number of benefits over KbCheck, the main one being that it doesn't miss
% short pulses. Looks for responses for a given duration of time,
% determined by the "start_time" and "max_rt" input variables. When a
% response is detected the function immediately returns. Otherwise the
% function returns after the alloted duration. Note this script assumes
% that KbQueueCreate(deviceNumber) has already been run.
%
% -- Required Inputs --
%
% start_time: system time which all other times are relative to
%
% max_rt: maximum response time, the duration for which the function
% searches for button responses, after this duration is exceeded the
% function returns.
%
% response_codes: response code keys to look for (see help KbCheck)
% 
% deviceNumber: index for the device to use (see GetKeyboardIndices)
%
% -- Outputs --
%
% rt: time when a button was registered, relative to start_time
%
% rkey: the key code of the button pressed
% 
% press_time: the system time when the key was pressed
%
% flipped: whether or not a screen was flipped
% 
% -- Optional Arguments --
% 
% loopdelay: amount of time in seconds to pause in between loops
% 
% fliptime: time to flip a screen, useful if you need to present a stimulus
% while looking for a button response
% 
% mainwindow: the index of the window to flip

% optional arguments
I.loopdelay = 0.001;
I.mainwindow = NaN;
I.fliptime = NaN;
I = parse_optInputs_keyvalue(varargin, I);
assert(~(~isnan(I.fliptime) && isnan(I.mainwindow)));

% flush and then start queue
KbQueueFlush(deviceNumber);
KbQueueStart(deviceNumber);

rt = nan;
rkey = nan;
flipped = false;
press_times = nan;
while (GetSecs < start_time+max_rt)
    
    % pause briefly
    if I.loopdelay>0
        WaitSecs(I.loopdelay);
    end
    
    % check queue
    [pressed, firstPress, firstRelease, lastPress, lastRelease] = KbQueueCheck(deviceNumber); %#ok<ASGLU>
    
    % if pressed return the result
    if pressed && any(firstPress(response_codes))
        
        % press times for the particular keys of interest
        press_times = firstPress(response_codes);
        
        % throwout keys that were not pressed (press_times==0)
        xi = logical(press_times);
        response_codes_pressed = response_codes(xi);
        press_times = press_times(xi);
        clear xi;
        
        % if multiple keys pressed, return the one pressed first
        if length(response_codes_pressed)>1
            [~,xi] = min(press_times);
            press_times = press_times(xi);
            response_codes_pressed = response_codes_pressed(xi);
            clear xi;
        end
        
        % compute rt
        rt = press_times-start_time;
        rkey = response_codes_pressed;
        break;
    end
    
    % flip screen
    if ~isnan(I.fliptime) && ~flipped && (GetSecs>I.fliptime)
        Screen('Flip',I.mainwindow);
        flipped = true;
    end
end

% stop adding to queue
KbQueueStop(deviceNumber);