function varargout = WaitPulseSNH(targetcodes,npulses,varargin)

% varargout = WaitPulseSNH(targetcodes,npulses,varargin);
% edited 10/20/10

endtime = Inf;
debugstate = false;
deviceindex = -3;

if optInputs(varargin, 'deviceindex')
    deviceindex = varargin{optInputs(varargin, 'deviceindex')+1};
end

if optInputs(varargin, 'debug')
    debugstate = true;
    ndsecs = 2000;
    dsecs = zeros(ndsecs,1);
    dsecindex = 0;
end

if optInputs(varargin, 'time')
    endtime = varargin{optInputs(varargin, 'time')+1};
end

recorded = false;
loopdelay = 0.001;

for i = 1:npulses
    testcode = 0;
    while (GetSecs<endtime)
        WaitSecs(loopdelay);
        [zz,secs,keyCode,delsecs] = KbCheck(deviceindex); %#ok<ASGLU>
        if (sum(keyCode(targetcodes)) == testcode)
            if (testcode == 0) 
                testcode = 1;
            else
                recorded = true;
                break;
            end
        end
        if debugstate
            dsecindex = dsecindex + 1;
            dsecs(dsecindex) = delsecs*1000;
        end
    end
end

varargout{1} = secs;
varargout{2} = recorded;

if debugstate; varargout{3} = dsecs; end
