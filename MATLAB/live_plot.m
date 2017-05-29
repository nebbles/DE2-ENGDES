function live_plot
close all
clear all
clc

% Create our clean up object.
cleanupObj = onCleanup(@cleanMeUp);
display('Please press CTRL+C or close the "Audio Analysis" window to exit.');

% Set control variables.
fs = 8000;
tperiod = 0.25;
highpass = 500;
magnitude_thresh = 5.0;
maxFs = [];
hFig = figure('Name','Audio Analysis','NumberTitle','off','Color','white','Units','normalized','Position',[.15 .15 .7 .7]);
tic;
stamps = [];
vols = [];
vol = 0;
ts = 0;

% Create audio recording object.
obj = audiorecorder(fs,8,1);
set(obj,'TimerPeriod',tperiod,'TimerFcn',@audioTimer); 
record(obj);

while true % Prevent function from ending unless CTRL+C
    if ~ishghandle(hFig)
        break
    end
    pause(0.1);
end

function audioTimer(hObj,~)
    data = getaudiodata(hObj);
    
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
    
    subplot(2,2,2)
    plot(f, Y/(N)*2);
    ylim([0 0.03]);
    xlabel('frequency (Hz)');
    ylabel('Magnitude');
    title('Frequency spectrum (live)');
    
    % for value in sig below HIGHPASS, set to zero (suppress)
    crit_idx = round(highpass / df);
    for i = 1:crit_idx
        Y(i) = 0;
    end
    subplot(2,2,1)
    plot(f,Y)
    xlabel('Frequency');
    ylabel('Magnitude');
    
    
    % if Y is less than the magnitude threshold value
    [maxY, idx] = max(Y); % find highest peak frequency
    if maxY < magnitude_thresh
        maxF = 0;
    else
        maxF = f(idx); % return corresponding frequency
    end
    maxFs = [maxFs maxF];
    
    subplot(2,2,3)
    plot(maxFs);
    ylim([0 5000]);
    xlim([0 100]);
    ylabel('Max frequency');
    xlabel('Live time segments');
    title('Freq-Time Graph');
    
    if length(maxFs) > 100
        maxFs = [];
    end
    
    % convert the rate into a volume
    dt = toc;
    tic;
    ts = ts + dt;
    if ts > 50
        ts = 0;
        stamps = 0;
        vols = 0;
        vol = 0;
    end
    stamps = [stamps ts];
    vol = vol + maxF * dt;
    if vol < 0
        vol=0;
    end
    vols = [vols vol];
    
    subplot(2,2,4);
    plot(stamps,vols);
    xlim([0 50]);
%     ylim([0 100000]);
    xlabel('Time (sec)');
    ylabel('Volume (unitless)');
    title('Volume vs Time');
    
end

function cleanMeUp()
    % saves data to file (or could save to workspace)
    display('Cleaning up and exiting.')
    stop(obj)
    close all
end

end