%% generating baseline drift noise
t = linspace(0,10*pi,1280);
s = sin(t);
sn = 0.4*cos(t./4);
bw = s + sn;
bw = bw';
figure(1)
subplot(2,1,1)
plot(t, s)
title('Signal with constant baseline')
grid on;
subplot(2,1,2)
plot(t, bw)
title('Signal with with wandering baseline')
grid on;
% %% generating powerline interference noise
% fNoise = 60;
% ampnoise = 0.15;
% pli = ampnoise*sin(2*pi.*tm.*fNoise);
% pli = pli';
% figure;
% plot(pli); title('powerline interference of 60 Hz');