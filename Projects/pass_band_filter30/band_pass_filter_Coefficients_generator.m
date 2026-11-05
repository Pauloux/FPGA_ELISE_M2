% Author :	BELLAUD Maxime
% Date : 	8 october 2026

% Octave program for generate low pass filter's coefficients
pkg load signal;

%%% Part 1 : Generate coefficients
% Frequency parameters
F_clk = 125_000_000; % Hz
Fs = F_clk / 8; %Hz


% Filter parameters
order = 30;
f_cutoff1 = 2_000_000; %Hz
f_cutoff2 = 2_500_000; %Hz
type = 'bandpass';

% Compute coefficients
filter_coeff = fir1(order,[f_cutoff1/(Fs/2) f_cutoff2/(Fs/2)],type);

for k = 1:order+1
	printf("%d,",filter_coeff(k))
end


%%% Part 3 : Verify the filter response
% Compute the frequency response
[magnitude, frequency] = freqz(filter_coeff);
frequency_Hz = frequency * Fs / (2 * pi);
magnitude_dB = 20 * log10(abs(magnitude));

% Plot the frequency response
figure(1);
semilogx(frequency_Hz(2:end), magnitude_dB(2:end), 'linewidth', 3)
hold on
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
legend('Frequency response', 'location', 'southwest')
grid on
set(gca, 'gridcolor', [0 0 0], 'gridalpha', 1, 'layer', 'top')

% Ideal bandpass and the -6 dB line, added for the report
semilogx([frequency_Hz(2) frequency_Hz(end)], [-6 -6], 'r--', 'linewidth', 2)
semilogx([f_cutoff1 f_cutoff1 f_cutoff2 f_cutoff2], [-40 0 0 -40], 'r', 'linewidth', 1.5)
legend('Frequency response', '-6 dB', 'Ideal bandpass', 'location', 'southwest')
xlim([1e5 Fs/2])
ylim([-40 5])

% Frequencies where the gain crosses -6 dB
below = magnitude_dB <= -6;
changes = find(below(2:end) != below(1:end-1));
for k = changes(:)'
	f_cross = interp1(magnitude_dB(k:k+1), frequency_Hz(k:k+1), -6);
	printf("f at -6 dB : %.0f Hz\n", f_cross)
end

print('-dpng', '-r160', 'reponse_passe_bande.png')

