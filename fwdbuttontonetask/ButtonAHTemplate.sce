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
