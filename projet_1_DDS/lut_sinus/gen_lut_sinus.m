N = 10;              % phase bits → 1024 points
M = 14;              % amplitude bits
nb_points = 2^N;     % 1024
max_val = 2^M - 1;   % 16383

i = 0:nb_points-1;

table = round( (sin(2*pi*i/nb_points) + 1)/2 * max_val );

for k = 1:nb_points
  printf("\t\t%d => \"%s\",\n", k-1, dec2bin(table(k), M));
end