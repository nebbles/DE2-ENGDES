MicFFT(8000,1.0)

function audio_recorder = MicFFT(Fs, update_rate)

recObj = audiorecorder(Fs, 16, 2);
get(recObj);

% Record your voice for time specified by update_rate.

while 1 
    recordblocking(recObj, update_rate);
    myRecording = getaudiodata(recObj);
    subplot (2, 1, 1);
    plot (myRecording);
    xlabel('Time')
    ylabel('Amplitude')
    title('Time domain representation of y(t)')

    L = length(myRecording);
    NFFT = 2^nextpow2(L); % Next power of 2 from length of myRecording
    Y = fft(myRecording,NFFT)/L;
    f = Fs/2*linspace(0,1,NFFT/2+1);

    subplot (2, 1, 2); 
    plot(f,2*abs(Y(1:NFFT/2+1))) 
    drawnow; 
    axis([0 Fs/2 0 0.01])
    title('Single-Sided Amplitude Spectrum of y(t)')
    xlabel('Frequency (Hz)')
    ylabel('|Y(f)|')

end

end