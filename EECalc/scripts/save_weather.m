
% usage: save_weather.m weather-file mat-file
%	weatherfile='chicago_tmy.epw';

arg_list = argv ();
weatherfile = arg_list{1}
outfile     = arg_list{2}

W=read_epw_v0_6(weatherfile);

save(outfile, 'W');
