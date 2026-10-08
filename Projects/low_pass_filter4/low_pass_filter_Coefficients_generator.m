% Author :	BELLAUD Maxime
% Date : 	1 october 2026

% Octave program for generate low pass filter's coefficients
pkg load signal;

%%% Part 1 : Generate coefficients
% Frequency parameters
F_clk = 125_000_000; % Hz
Fs = F_clk / 8; %Hz

% Filter parameters
order = 4;
f_cutoff = 500_000; %Hz
type = 'low';

% Compute coefficients
filter_coeff = fir1(order,f_cutoff/(Fs/2),type)

%%% Part 2 : Convert coefficients to VHDL format
% Find SCALE for fixed point
SCALE = 8 - ceil(log2(max(filter_coeff)));

% Print coefficients in VHDL format
printf("\tGENERIC(\n")
printf("\t\tSCALE : INTEGER := %d", SCALE)
for k = 0:order-2
	filter_coeff_Fix = round(filter_coeff * 2^(SCALE));
	printf(";\n\t\tB_%d : UNSIGNED(7 DOWNTO 0) := \"%s\"", k, dec2bin(filter_coeff_Fix(k+1), 8))
end
printf("\n\t);\n")

%%% Part 3 : Verify the filter response
% Compute the frequency response
[magnitude, frequency] = freqz(filter_coeff);
frequency_Hz = frequency * Fs / (2 * pi);
magnitude_dB = 20 * log10(abs(magnitude));

% Plot the frequency response
figure(1);
semilogx(frequency_Hz(2:end), magnitude_dB(2:end), 'linewidth', 3)
hold on
semilogx([17e3 Fs/2], [-6 -6], 'r--', 'linewidth', 2)
semilogx([f_cutoff f_cutoff], [-25 2], 'r--', 'linewidth', 2)
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
legend('Frequency response', '-6 dB', '500 kHz', 'location', 'southwest')

xlim([17e3 Fs/2])
ylim([-25 2])
grid on
set(gca, 'gridcolor', [0 0 0], 'gridalpha', 1, 'layer', 'top')

