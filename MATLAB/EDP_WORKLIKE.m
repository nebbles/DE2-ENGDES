function live_plot
close all
clear all
format compact
clc

% Create our clean up object.
cleanupObj = onCleanup(@cleanMeUp);
display('Please press CTRL+C or close the "Audio Analysis" window to exit.');

% Set control variables.
fs = 8000;
tperiod = 0.2;
highpass = 500;
magnitude_thresh = 5.0;
maxFs = [];
hFig = figure('Name','Audio Analysis','NumberTitle','off','Color','white','Units','normalized','Position',[.15 .15 .7 .7]);
% stop_btn = uicontrol('Style','pushbutton','String','Stop','Callback',@stop_fcn);
tic;
stamps = [];
vols = [];
flows = [];
vol = 0;
breaths = [];
ts = 0;
k = 0.09; % linear coefficient for Freq->Vol
counter = 0;
isRunning = 1;
p = 0;

% Create audio recording object.
obj = audiorecorder(fs,8,1);
set(obj,'TimerPeriod',tperiod,'TimerFcn',@audioTimer); 
record(obj);
% pause(3)
% pause(obj)


pause(1)
while true % Prevent function from ending unless CTRL+C
    if ~ishghandle(hFig)
        break
    end
    if p == 1
        pause(obj)
    end
    pause(0.01)
end
    
function stop_fcn
    display('working')
    pause(obj)
end

function audioTimer(hObj,~)
    if isRunning == 1
        data = getaudiodata(hObj);
    end

    num = fs * tperiod;
    sig = data( length(data) - num +1 : length(data) );

    subplot(2,2,1)
%     plot(sig);
%     ylim([-0.2 0.2]);

    magnitude = abs(fft(sig));
    N = length(sig);
    df = fs / N;
    f = 0:df:fs/2;
    Y = magnitude(1:length(f));

%     subplot(2,2,2)
%     plot(f, Y/(N)*2);
%     ylim([0 0.03]);
%     xlabel('frequency (Hz)');
%     ylabel('Magnitude');
%     title('Frequency spectrum (live)');

    % for value in sig below HIGHPASS, set to zero (suppress)
    crit_idx = round(highpass / df);
    for i = 1:crit_idx
        Y(i) = 0;
    end
    subplot(2,2,1)
    plot(f,Y)
    title('Adjusted Frequency Spectrum');
    xlabel('Frequency');
    ylabel('Magnitude');
    ylim([0 5]);



    % if Y is less than the magnitude threshold value
    [maxY, idx] = max(Y); % find highest peak frequency
    if maxY < magnitude_thresh
        maxF = 0;
    else
        maxF = f(idx); % return corresponding frequency
    end
    maxFs = [maxFs maxF];

    subplot(2,2,2)
    plot(maxFs);
    ylim([0 3000]);
    xlim([0 100]);
    ylabel('Max frequency');
    xlabel('Live time segments');
    title('Freq-Time Graph');

    if length(maxFs) > 100
        maxFs = [];
    end

    %% Convert frequency to flow rate

    flow = maxF * k; % calc flow rate
    flows = [flows flow];

    subplot(2,2,3)
    plot(flows);
%     ylim([0 3000]);
    xlim([0 300]);
    ylabel('Flow rate (L/min)');
    xlabel('Counter');
    title('Flow-Time Graph');

    if length(flows) > 100
%         flows = [];
        export = transpose(flows);
        csvwrite('flow-time.csv',export)
    end


    %% Convert flow rate to volume

    dt = toc;
    tic;

    ts = ts + dt;
%     if ts > 50
%         ts = 0;
%         stamps = 0;
%         vols = 0;
%         vol = 0;
%     end

    stamps = [stamps ts];
    vol = vol + flow * dt;

    if flow == 0
        counter = counter + 1;
    end
    if counter == 20
        counter = 0;
        display('Volume of breath is:')
        vol
        breaths = [breaths vol];
        vol = 0;
    end

    if vol < 0
        vol=0;
    end
    vols = [vols vol];

    subplot(2,2,4);
    plot(stamps,vols);
    xlim([0 50]);
%   ylim([0 100000]);
    xlabel('Time (sec)');
    ylabel('Volume (mL)');
    title('Volume vs Time');
end

function cleanMeUp()
    % saves data to file (or could save to workspace)
    display('Cleaning up and exiting.')
    stop(obj)
    close all
end

end