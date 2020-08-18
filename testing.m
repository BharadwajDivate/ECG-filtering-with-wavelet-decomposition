clc
%[~,config] = wfdbloadlib;
% load('100m1.mat')
% % ecgsignal = val/200;
% % fs = 360;
% % t = [0 : length(ecgsignal)-1];
% % plot(t,ecgsignal);
% plotATM('100m1')

[tm,signal,Fs,siginfo]= rdmat('16265m');
signal = signal - mean(signal);
figure; grid on;
plot(tm,signal); title('signal obatined from database');
xlabel('time'); ylabel('magnitude in mV');
%% generating powerline interference noise and plot noisy signal
fNoise = 60;
ampnoise = 0.15;
pli = ampnoise*sin(2*pi.*tm.*fNoise);
pli = pli';
figure;
plot(tm,pli); title('powerline interference of 60 Hz');
noise = bw + pli;
noisysignal = signal + bw + pli ;
figure;
plot(noisysignal); title('noisy signal');
xlabel('time'); ylabel('magnitude in mV');


%% visualize the frequency spectrum of the noisy ecg_signal
y = fft(noisysignal);
xf = linspace(1,128,length(signal));
figure;
plot(xf,abs(y)); title('Frequency spectrum of the ECG signal');
xlabel('frequency');
grid on;


%% perform wavelet decomposition
dwtmode('per','nodisp');
wname = 'db5';
Lev = 5;        % performing a level 5 decomposition
[c, l] = wavedec(noisysignal,Lev,wname);

%plotting the detail coefficients
[d1,d2,d3,d4,d5] = detcoef(c,l,[1 2 3 4 5]);
figure
subplot(5,1,1);
plot(d1); axis tight; title('level 1 detail coefficient');
subplot(5,1,2);
plot(d2);axis tight; title('level 2 detail coefficient');
subplot(5,1,3);
plot(d3); axis tight; title('level 3 detail coefficient');
subplot(5,1,4);
plot(d4); axis tight; title('level 4 detail coefficient');
subplot(5,1,5);
plot(d5); axis tight; title('level 5 detail coefficient');

%plotting the approximate coefficients
a1 = appcoef(c,l,wname,1);
a2 = appcoef(c,l,wname,2);
a3 = appcoef(c,l,wname,3);
a4 = appcoef(c,l,wname,4);
a5 = appcoef(c,l,wname,5);
% a6 = appcoef(c,l,wname,6);
% figure;
% plot(a6);
figure;
subplot(5,1,1);
plot(a1); title('Level-1 Approximation Coefficients');
subplot(5,1,2);
plot(a2); title('Level-2 Approximation Coefficients');
subplot(5,1,3);
plot(a3); title('Level-3 Approximation Coefficients');
subplot(5,1,4);
plot(a4); title('Level-4 Approximation Coefficients');
subplot(5,1,5);
plot(a5); title('Level-5 Approximation Coefficients');
%[ea ed] = wenergy(c,l)


%% calculating the wavelet energies for different layers using detail coefficients
sum(1) = 0;
for i = 1 : length(d1)
    sum(1) = sum(1) + (abs(d1(i))).^2 ;
end
e(1) = log(sum(1));

sum(2) = 0;
for i = 1 : length(d2)
    sum(2) = sum(2) + (abs(d2(i))).^2 ;
end
e(2) = log(sum(2));

sum(3) = 0;
for i = 1 : length(d3)
    sum(3) = sum(3) + (abs(d3(i))).^2 ;
end
e(3) = log(sum(3));

sum(4) = 0;
for i = 1 : length(d4)
    sum(4) = sum(4) + (abs(d4(i))).^2 ;
end
e(4) = log(sum(4));

sum(5) = 0;
for i = 1 : length(d5)
    sum(5) = sum(5) + (abs(d5(i))).^2 ;
end
e(5) = log(sum(5));

disp('Displaying layer energies of detail co-efficients...');
disp(e);

% suppress low frequency noise corresponding to BW drift as observed in
% graph
for i = 1 : length(a5)
    c(i) = 0;
end

% suppress the high frequency powerline interference noise
for i = 641 : 1280
    if (abs(c(i)) <= 0.23)
        c(i) = 0;
    end
end

%% recover the ecg signal using the new coefficients
recsig = waverec(c,l,wname);
figure;
grid on;
plot(tm,recsig); title('reconstructed signal');
xlabel('time'); ylabel('magnitude in mV');

%% calculating Signal - to - Noise ratio
snr_i = snr(signal,noise);
disp('The input snr for the corrupted ecg signal is'); disp(snr_i);
snr_o = snr(signal,signal-recsig);
disp('The output snr for the filtered ecg signal is');disp(snr_o);

%% savitsky - golay smoothing filter 
frame = 1;
degree = 0;
final = sgolayfilt(recsig, degree, frame);
figure;
plot(tm,final); title('final smoothed signal');
xlabel('time'); ylabel('magnitude in mV');
figure;
plot(tm,signal,'b'); title('comparison with input');
hold on;
grid on;
plot(tm,final,'r');
xlabel('time'); ylabel('magnitude in mV');
legend('original signal','reconstructed signal');
