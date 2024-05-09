scenario = "Push Button + tone (0ms)";
pcl_file = "ButtAh25.pcl";
scenario_type = trials;
write_codes = true;
response_matching = simple_matching;
active_buttons = 2;
button_codes = 10, 20;
target_button_codes = 111, 222;
no_logfile = false;
default_background_color = 0,0,0;
default_text_color = 255,255,255;
pulse_width = 1;

begin;
                      #B2n0nnAh
wavefile { filename = "1000.wav"; } wAHv;
sound { 	wavefile wAHv;
			attenuation = 0.25;
} Ah;      

picture {
      text {caption = "+";
				font_size = 36;};
      x = 0; y = 0;
}default;
	    
#trial{ COMMENTED LINES 27-35 out 7/6/21
 #  all_responses = false;
  # trial_type = first_response;    
   #terminator_button = 1;
	#picture {
    #  text {caption = "+";
		#		font_size = 36;};
      #x = 0; y = 0;
   #}; 
#added lines 36-46 7/6/21
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
            
   time = 0;
   duration = next_picture;
   code = "start";
   port_code = 128;
}start_exp;     

trial {
monitor_sounds = false;
   trial_duration = 500;
   picture {
      text {caption = "+";
				font_size = 36;}; # fixation cross
      x = 0; y = 0; # centre of screen
   };
   time = 50;          
   duration = next_picture;
   port_code = 15;
}run_type;  

trial {
   trial_duration = 10000;
   monitor_sounds = false;
   picture {
      text {caption = "REST";
				font_size = 36;
				font_color = 255,0,0;}; # fixation cross
      x = 0; y = 0; # centre of screen
   };
   time = 0;    
	sound Ah;  
   time = 0;
	code = "ah";
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
	trial_duration = forever;
	trial_type = correct_response; 
   picture {
      text {caption = "+";
				font_size = 36;}; 
      x = 0; y = 0; 
   };
   time = 0;          
   duration = next_picture;
   target_button = 2;
}start_2;

trial {
    trial_duration = forever;        	# trial lasts until target
    trial_type = correct_response;   	#   button is pressed
    nothing {};
	 time = 0;
    code = "nothing";
    duration = next_picture;
    target_button = 2;
};


TEMPLATE "buttAh0.tem" {
resp	;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		;
2		; #2		;
};

trial {
   trial_duration = 1000;
   sound Ah;
   code = 20;
   time = 0;
   picture {
      text {caption = "stop";
				font_size = 14;}; # fixation cross
      x = 0; y = 0; # centre of screen
   };
   time = 0;           
   duration = next_picture;
   port_code = 20;
};

trial {
   trial_duration = 1000;
   nothing{};
   time = 0;           
   duration = next_picture;
   port_code = 16;
};

trial {
   trial_duration = 2000;
   picture {
      text {caption = "+";
				font_size = 14;}; # fixation cross
      x = 0; y = 0; # centre of screen
   };
   time = 0; 
	port_code =129;          
   duration = next_picture; 
};