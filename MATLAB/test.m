fs = 8000;
duration = 5;

% Record your voice for 5 seconds.
recObj = audiorecorder;
disp('Start speaking.')
recordblocking(recObj, duration);
disp('End of Recording.');

% Play back the recording.
play(recObj);

% Store data in double-precision array.
sig = getaudiodata(recObj);

% Plot the waveform.
plot(sig);
xlabel('Sample no')
ylabel('Signal voltage')
title('Plot of waveform')

plot_spectrum(sig,fs)


% Divide signal into segments and find energy
T = 0.02;
N = fs*T;
E = [];

for i = 1:N:length(sig)-N+1
    seg = sig(i:i+N-1);
    
    maxF = get_spectrum(seg,fs);
    
    E = [E maxF];
end

% plot the energy graph and the peak values

figure; set(gcf,'color','w');
x = 1:length(E)
plot(x,E);
xlabel('Segment number');
ylabel('Energy');
hold on
[pks, locs] = findpeaks(E);
plot(locs, pks, 'o');
hold off


function plot_spectrum( sig, fs )
% Function to plot frequency spectrum of sig
%   usage:
%           plot_spectrum(sig, 8192)

    magnitude = abs(fft(sig));
    N = length(sig);
    df = fs / N;
    f = 0:df:fs/2;
    Y = magnitude(1:length(f));
%     figure
    plot(f, Y/(N)*2);
    xlabel('\fontsize{14}frequency (Hz)');
    ylabel('\fontsize{14}Magnitude');
    title('Plot of spectrum');

end

function maxF = get_spectrum( sig, fs )
% Function to plot frequency spectrum of sig
%   usage:
%           plot_spectrum(sig, 8192)

    magnitude = abs(fft(sig));
    N = length(sig);
    df = fs / N;
    f = 0:df:fs/2;
    Y = magnitude(1:length(f));
    
    [maxY, idx] = max(Y);
    maxF = f(idx);

end