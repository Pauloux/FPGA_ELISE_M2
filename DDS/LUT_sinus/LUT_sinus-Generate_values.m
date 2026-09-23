phase_N = 16;			% phase bits -> 1024 points
amplitude_N = 14;		% amplitude bits
nb_points = 2^phase_N;		% 1024
max_val = 2^amplitude_N - 1;	% 16383

t = 0:nb_points-1;

table = round( (sin(2*pi*t/nb_points) + 1) /2 * max_val );

for k = 1:nb_points
  printf("\t\t%d \t=> \t\"%s\",\n", k-1, dec2bin(table(k), amplitude_N));
end
