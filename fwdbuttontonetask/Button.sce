scenario = "Button";
pcl_file = "Buttonly.pcl";
scenario_type = trials;
write_codes = true;
response_matching = simple_matching;
active_buttons = 2;
button_codes = 10, 20;
target_button_codes = 11, 22;
#write_codes = true;
no_logfile = false;
default_background_color = 0,0,0;    
default_text_color = 255,255,255; 
pulse_width = 1;

begin;
	
picture {
      text {caption = "+";
				font_size = 36;};
      x = 0; y = 0;
}default;
	    
trial{
	monitor_sounds = false;
   all_responses = true;
   trial_duration = 4000; #changed from 1000 to 4000 7/6
   trial_type = specific_response;    
   terminator_button = 1;
   picture {
      text {caption = "Wait";
				font_size = 36;};
      x = 0; y = 0;
   };
   #sound noise;
   time = 0;
   duration = next_picture;
   code = "start";
   port_code = 128;
}start_exps;

# is this needed?
trial {
monitor_sounds = false;
   trial_duration = 500;
   picture {
      text {caption = "+";
				font_size = 36;}; # fixation cross, made huge
      x = 0; y = 0; # centre of screen
   };
   time = 50;          
   duration = next_picture;
   port_code = 15;
}run_types;     

trial {
   trial_duration = 10000;
   monitor_sounds = false;
   picture {
      text {caption = "REST";
				font_size = 36;}; # fixation cross
      x = 0; y = 0; # centre of screen
   };
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
	#trial_duration = forever;
	#trial_type = specific_response;
   #terminator_button = 2; 
   picture {
      text {caption = "+";
				font_size = 36;}; 
      x = 0; y = 0; 
   };
   time = 0;          
   duration = next_picture;
}start_2;

#trial {
#	monitor_sounds = false;
#   trial_duration = 1000;
#   picture {
#      text {caption = "+";
#				font_size = 36;}; 
#      x = 0; y = 0; 
#   };
#   time = 50;          
#   duration = next_picture;
#};

TEMPLATE "buttonly.tem" {
#resp	;
resp;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
2;
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
