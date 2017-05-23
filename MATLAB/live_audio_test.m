function live_audio_test
close all
clear all
clc

% Create our clean up object.
cleanupObj = onCleanup(@cleanMeUp);
display('Please press CTRL+C to exit.');

% Set control variables.
fs = 8000;
tperiod = 0.5;

figure('Name','Audio Analysis','NumberTitle','off','Color','white','Units','normalized','Position',[.1 .1 .7 .3]);

% Create audio recording object.
obj = audiorecorder(fs,8,1);
set(obj,'TimerPeriod',tperiod,'TimerFcn',@audioTimer); 
record(obj);

while true % Prevent function from ending unless CTRL+C
    pause(1);
end

function audioTimer(hObj,~)
    data = getaudiodata(hObj);
    
    num = fs * tperiod;
    sig = data( length(data) - num +1 : length(data) );
    
    subplot(1,2,1)
    plot(sig);
    ylim([-0.2 0.2]);
    
    magnitude = abs(fft(sig));
    N = length(sig);
    df = fs / N;
    f = 0:df:fs/2;
    Y = magnitude(1:length(f));
    
    subplot(1,2,2)
    plot(f, Y/(N)*2);
    ylim([0 0.03]);
    xlabel('frequency (Hz)');
    ylabel('Magnitude');
    
end

function cleanMeUp()
    % saves data to file (or could save to workspace)
    display('Cleaning up.')
    stop(obj)
    close all
end
end