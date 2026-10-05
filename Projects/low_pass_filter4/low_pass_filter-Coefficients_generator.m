% Author :	BELLAUD Maxime
% Date : 	1 october 2026

% Octave program for generate low pass filter's coefficients
pkg load signal;
% Frequency parameters
F_clk = 125_000_000; % Hz
Fs = F_clk / 8; %Hz

% Filter parameters
order = 4;
f_cutoff = 500_000; %Hz
type = 'low';

% Compute coefficients
filter_coeff = fir1(order,f_cutoff/(Fs/2),type)

% Plot bode with normalized frequency axis
figure 1;
freqz(filter_coeff)

% Find SCALE for fixed point
SCALE = 8 - ceil(log2(max(filter_coeff)));

% Print and compute coefficients in VHDL format
printf("\tGENERIC(\n")
printf("\t\tSCALE : INTEGER := %d", SCALE)
for k = 0:order-2
	filter_coeff_Fix = round(filter_coeff * 2^(SCALE));
    printf(";\n\t\tB_%d : UNSIGNED(7 DOWNTO 0) := \"%s\"", k, dec2bin(filter_coeff_Fix(k+1), 8))
end
printf("\n\t);\n")




