PHASE_WIDTH_MAX = 10;		% phase bits -> 65536 points
amplitude_N = 14;		% amplitude bits
nb_points = 2^PHASE_WIDTH_MAX;	% 65536
max_val = 2^amplitude_N - 1;	% 16383

t = 0:nb_points-1;

table = round( (sin(2*pi*t/nb_points) + 1) /2 * max_val );

for k = 1:nb_points
  if mod(k, 2) == 0
    printf("\t\t%d \t=> \t\"%s\",\n", k-1, dec2bin(table(k), amplitude_N));
  else
    printf("\t\t%d \t=> \t\"%s\",\n", k-1, dec2bin(max_val, amplitude_N));
  end
end
