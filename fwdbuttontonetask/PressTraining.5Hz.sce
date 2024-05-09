#in this scenario we are trying to train the subject to press
#once per second, with an acceptable range of 800-1200ms.
#
#Brian 7/7/2014
#
#10/15/2014: Edited to give inter-press feedback interval to subject

# the name of the scenario/experiment
scenario = "passive press generic training 1.2";

# the type of scenario: if not fMRI-based this will be 'trials'
scenario_type = trials;

#to avoid phantom double-presses
default_stimulus_time_in = 300;

# use 'simple_matching' rather than 'legacy_matching'
response_matching = simple_matching;

# this says how many active (response) buttons there will be in the
# scenario and the codes for these buttons; these must also be defined
# under the 'Input Devices' tab above
active_buttons = 2;
button_codes = 100,0;
no_logfile = false;

# sets the background color to gray
default_background_color = 128,128,128;


# this is needed to send triggers through the port; this must also be
# defined under the 'Port Settings' tab above
write_codes = true;
pulse_width = 5;

begin;
picture {
      text {caption = "+";
				font_size = 36;};
      x = 0; y = 0;
}default;

################Countdown (start)
trial {
   stimulus_event {
      picture{ 
         text { caption = "3"; 
               font_size = 48;
               font_color = 0,0,0;};
           x = 0; y = 0;
      };
         duration = 495;
         code = "83";
			#this will start the EEG recording:
			#port_code = 128;
   };
       
   stimulus_event {
           picture{ 
         text { caption = "2"; 
               font_size = 48;
               font_color = 0,0,0;};
           x = 0; y = 0;
      };
         time = 995; 
         duration = 495;
         code = "82";
   };  
       
   stimulus_event {
		picture{ 
			text { caption = "1"; 
               font_size = 48;
               font_color = 0,0,0;};
           x = 0; y = 0;
      };
         time = 1995; 
         duration = 495;
         code = "81";
   };   
           
   stimulus_event {
      picture{ 
         text { caption = "Focus..."; 
               font_size = 48;
               font_color = 0,0,0;};
           x = 0; y = 0;
      };
         time = 2995; 
         duration = 495;
         code = "80";
   }; 

   stimulus_event {
		picture{ 
			text { caption = "Press!"; 
               font_size = 48;
               font_color = 0,0,0;};
           x = 0; y = 0;
      };
         time = 3995; 
         duration = 995;
         code = "81";
   };  
 stimulus_event {
		picture{ 
			text { caption = "Press!"; 
               font_size = 48;
               font_color = 0,0,0;};
           x = 0; y = 0;
      };
         time = 5995; 
         duration = 995;
         code = "81";
   };  
 stimulus_event {
		picture{ 
			text { caption = "Press!"; 
               font_size = 48;
               font_color = 0,0,0;};
           x = 0; y = 0;
      };
         time = 7995; 
         duration = 995;
         code = "81";
   };  
} countdown;
################Countdown (end)

text {caption = "Keep Pressing!!!";
				font_size = 48;
				font_color = 0,0,0;} keep;
				
picture {
background_color = 128,128,128;
      text {caption = "Too Slow";
				font_size = 36; 
				font_color = 255,0,0;};
      x = -300; y = 0;
		

box { height = 10; width = 200; color = 255,0,0; } box1;
   x = -300; y = -30;

		text {caption = "Perfect!";
				font_size = 36;
				font_color = 0, 255, 0;};
      x = 0; y = 0;

text keep;
      x = 0; y = 200;

box { height = 10; width = 200; color = 0,255,0; } box2;
   x = 0; y = -30;

		text {caption = "Too Fast";
				font_size = 36;
				font_color = 0,0,255;};
      x = 300; y = 0;

box { height = 10; width = 200; color = 0,0,255; } box3;
   x = 300; y = -30;

#set_background_color( int red, int green, int blue ) 

}Qpic;

trial {
trial_duration = stimuli_length;
picture Qpic;
time = 0;
response_active = true;
duration = next_picture;

#nothing{};
#time = 50;
#response_active = true;
#port_code = 255;
} Q;

####PCL####
begin_pcl;
parameter_window.remove_all();

#start the countdown:
countdown.present();

int IPI = 2000;
int lastTime = 0;
int ifresponse = 0;
Q.present();

stimulus_data last = stimulus_manager.last_stimulus_data();
			
#for the first trial in the block, you'll need this
#initial cue time to establish the rate
lastTime = last.time();
		
double teeTime = clock.time_double();

loop
	int hitStreak = 0;
until
	hitStreak > 10 
begin
#infinite loop that runs until you've hit
#more than 10 presses in a row at the specified pace	
#ifresponse = 1 if a button has been pressed
ifresponse = response_manager.response_count();

	response_data lastResp = response_manager.last_response_data();

	keep.set_caption("Keep Pressing!!\n" + string(round((clock.time_double()-teeTime)/double(1000),2)) + " seconds");
	keep.redraw();
	
	if ifresponse > 0 then
		#check on the time between presses
		IPI =  lastResp.time() - lastTime;
		lastTime = lastResp.time();
		teeTime = double(lastTime);
		if IPI > 1000 then #changed from 1700 to 1000
			if IPI < 2500 then #changed from 2300 to 2500
				#just right...
				Qpic.set_background_color( 0, 255, 0 );
				hitStreak = hitStreak+1;
				Q.present();
			else
				#too slow!
				Qpic.set_background_color( 255, 0, 0 );
				hitStreak = hitStreak-1;
				Q.present();
			end;
		else
			if IPI > 300 then
			#too fast!
			Qpic.set_background_color( 0, 0, 255 );
			hitStreak = hitStreak-1;
			Q.present();
			end;
		end
	end;

end;