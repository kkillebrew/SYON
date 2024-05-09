scenario = "Stim";
pcl_file = "ButtAhrest.pcl";
scenario_type = trials;
write_codes = true;
response_matching = simple_matching;
active_buttons = 2;
button_codes = 128, 2;
write_codes = true;
no_logfile = false;
default_background_color = 0,0,0;
pulse_width = 1;

begin;
                      #B2n0nnAh
wavefile { filename = "1000.wav"; } wAHv;
sound { 	wavefile wAHv;
			attenuation = .25;
} Ah;      

picture {
      text {caption = "+";
				font_size = 36;};
      x = 0; y = 0;
}default;
	    
trial{
	monitor_sounds = false;
   #all_responses = true;
   trial_duration = 1000;
   #trial_type = specific_response;    
   #terminator_button = 1;
   #sound noise;
   picture {
      text {caption = "Wait";
				font_size = 36;};
      x = 0; y = 0;
   };             
   time = 0;
   duration = 500;
   code = "start";
   port_code = 128; #change to 128 later
   picture {
      text {caption = "+";
				font_size = 36;};
      x = 0; y = 0;
};
time = 500;
duration = 500;
}start_exps;     
 

trial {
   trial_duration = 10000;
   monitor_sounds = false;
   picture {
      text {caption = "REST";
				font_size = 36;
				font_color = 255,0,0	;}; # fixation cross
      x = 0; y = 0; # centre of screen
   };
   time = 5; 
	port_code = 25;   
	sound Ah;  
   time = 0;
	code = "rest";
   duration = next_picture; 
}rest;

trial {
   trial_duration = 1000;
   monitor_sounds = false;
   picture {
      text {caption = "10";
				font_size = 36;}; # fixation cross
      x = 0; y = 0; # centre of screen
   };
   time = 0; 
	port_code = 122;   
   duration = next_picture; 
}ten;

trial {
   trial_duration = 1000;
   monitor_sounds = false;
   picture {
      text {caption = "9";
				font_size = 36;}; # fixation cross
      x = 0; y = 0; # centre of screen
   };
   time = 0; 
	port_code = 122;   
   duration = next_picture; 
}nine;

trial {
   trial_duration = 1000;
   monitor_sounds = false;
   picture {
      text {caption = "8";
				font_size = 36;}; # fixation cross
      x = 0; y = 0; # centre of screen
   };
   time = 0; 
	port_code = 122;   
   duration = next_picture; 
}eight;

trial {
   trial_duration = 1000;
   monitor_sounds = false;
   picture {
      text {caption = "7";
				font_size = 36;}; # fixation cross
      x = 0; y = 0; # centre of screen
   };
   time = 0; 
	port_code = 122;   
   duration = next_picture; 
}seven;

trial {
   trial_duration = 1000;
   monitor_sounds = false;
   picture {
      text {caption = "6";
				font_size = 36;}; # fixation cross
      x = 0; y = 0; # centre of screen
   };
   time = 0; 
	port_code = 122;   
   duration = next_picture; 
}six;

trial {
   trial_duration = 1000;
   monitor_sounds = false;
   picture {
      text {caption = "5";
				font_size = 36;}; # fixation cross
      x = 0; y = 0; # centre of screen
   };
   time = 0; 
	port_code = 122;   
   duration = next_picture; 
}five;

trial {
   trial_duration = 1000;
   monitor_sounds = false;
   picture {
      text {caption = "4";
				font_size = 36;}; # fixation cross
      x = 0; y = 0; # centre of screen
   };
   time = 0; 
	port_code = 122;   
   duration = next_picture; 
}four;

trial {
   trial_duration = 1000;
   monitor_sounds = false;
   picture {
      text {caption = "3";
				font_size = 36;}; # fixation cross
      x = 0; y = 0; # centre of screen
   };
   time = 0; 
	port_code = 122;   
   duration = next_picture; 
}three;

trial {
   trial_duration = 1000;
   monitor_sounds = false;
   picture {
      text {caption = "2";
				font_size = 36;}; # fixation cross
      x = 0; y = 0; # centre of screen
   };
   time = 0; 
	port_code = 122;   
   duration = next_picture; 
}two;

trial {
   trial_duration = 1000;
   monitor_sounds = false;
   picture {
      text {caption = "1";
				font_size = 36;}; # fixation cross
      x = 0; y = 0; # centre of screen
   };
   time = 0; 
	port_code = 122;   
   duration = next_picture; 
}one;

trial {
	monitor_sounds = false;
   picture {
      text {caption = "+";
				font_size = 36;}; 
      x = 0; y = 0; 
   };
   time = 0;          
   duration = next_picture;
}start_2;

TEMPLATE "Ahonly.tem" {
resp	;
1077	;
1601	;
1310	;
1440	;
1437	;
1446	;
1396	;
1409	;
1431	;
1466	;
1429	;
1433	;
1360	;
1460	;
1375	;
1395	;
1491	;
1406	;
1415	;
1458	;
1494	;
1421	;
1324	;
1411	;
1462	;
1507	;
1439	;
1450	;
1471	;
1338	;
1428	;
1466	;
1317	;
1291	;
1350	;
1316	;
1459	;
1395	;
1371	;
1382	;
1475	;
1274	;
1504	;
1353	;
1404	;
1336	;
1395	;
1248	;
1407	;
1376	;
1339	;
1470	;
1426	;
1397	;
1382	;
1194	;
1432	;
1426	;
1417	;
1388	;
1412	;
1439	;
1287	;
1612	;
1307	;
1298	;
1276	;
1276	;
1290	;
1361	;
1431	;
1476	;
1403	;
1396	;
1511	;
1481	;
1428	;
1391	;
1405	;
1522	;
1366	;
1392	;
1349	;
1368	;
1518	;
1382	;
1540	;
1388	;
1406	;
1525	;
1418	;
1344	;
1252	;
1448	;
1402	;
1501	;
1508	;
1428	;
};

trial {
	trial_duration = 1000;
	picture {
		text {caption = "+";
		font_size = 14;}; # fixation cross
	x = 0; y = 0; # centre of screen
	};
	time = 50;
	duration = next_picture;
	port_code = 129;
};

