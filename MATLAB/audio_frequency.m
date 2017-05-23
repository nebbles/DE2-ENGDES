close all

fs = 8000;
duration = 5;

%% Set up recording
recObj = audiorecorder; % Create recording object
disp('Start of recording.')
recordblocking(recObj, duration); % Record your voice for x seconds
disp('End of recording.');
sig = getaudiodata(recObj); % Store data in double-precision array.

play(recObj); % Play back the recording.

%% Analyse signal

% Plot the waveform.
figure('Name','Audio Analysis','NumberTitle','off','Color','white','Units','normalized','Position',[.1 .1 .7 .3]);
subplot(1,3,1)
plot(sig);
xlabel('Sample no')
title('Plot of waveform')

subplot(1,3,2); 
plot_spectrum(sig,fs)


% Divide signal into segments and find peak frequency per segment
T = 0.02;
N = fs*T;
F = [];
high_pass_filter = 800; % Suppress all frequencies under value (Hz)

for i = 1:N:length(sig)-N+1
    seg = sig(i:i+N-1);
    
    maxF = get_spectrum_max(seg,fs,high_pass_filter);
    
    F = [F maxF];
end

% plot the energy graph and the peak values

subplot(1,3,3)
x = 1:length(F)
plot(x,F);
xlabel('Segment number');
ylabel('Frequency');
title('Freq vs Time');
hold on
[pks, locs] = findpeaks(F);
plot(locs, pks, 'o');
hold off

%% Functions

function plot_spectrum( sig, fs )
% Function to plot frequency spectrum of sig
%   usage:
%           plot_spectrum(sig, 8192)

    magnitude = abs(fft(sig));
    N = length(sig);
    df = fs / N;
    f = 0:df:fs/2;
    Y = magnitude(1:length(f));
    plot(f, Y/(N)*2);
    xlabel('frequency (Hz)');
    ylabel('Magnitude');
    title('Plot of spectrum');

end

function maxF = get_spectrum_max( sig, fs, highpass )

    magnitude = abs(fft(sig));
    N = length(sig);
    df = fs / N;
    f = 0:df:fs/2;
    Y = magnitude(1:length(f));
    
    % for value in sig below HIGHPASS, set to zero (suppress)
    critical_idx = round(highpass / df)
    for i = 1:critical_idx
        Y(i) = 0;
    end
    
    [maxY, idx] = max(Y); % find highest peak frequency
    maxF = f(idx); % return corresponding frequency

end
