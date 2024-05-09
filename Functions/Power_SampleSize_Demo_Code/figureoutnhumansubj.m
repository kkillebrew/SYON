total_n = 80+40; % aims 1 & 3, + aim 2
male_frac = 0.58; % sz more prevalent in men
female_frac = 1 - male_frac;
n_male = male_frac * total_n;
n_female = female_frac * total_n;

hisp_fract = 0.05;
nonhisp_fract = 1 - hisp_fract;

white_black_asian_native_pacific = [0.86 0.075 0.06 0.01 0.001];

male_n_demog_hisp = n_male*white_black_asian_native_pacific*hisp_fract
female_n_demog_hisp = n_female*white_black_asian_native_pacific*hisp_fract

male_n_demog_nonhisp = n_male*white_black_asian_native_pacific*nonhisp_fract
female_n_demog_nonhisp = n_female*white_black_asian_native_pacific*nonhisp_fract