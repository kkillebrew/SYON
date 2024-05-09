scenario = "push button + tone Instructions";
scenario_type = trials;

# sets the default text font
default_font = "Arial";
default_font_size = 14;
default_text_color = 0,0,0; # sets text to black

# sets the background colour to white (default is black)
default_background_color = 255,255,255;    

#center the text
default_text_align = align_center;
begin;

bitmap { filename = "BlankSubjectMonitor.bmp";} SubMonitor;
bitmap { filename = "BlankSubjectReady.bmp";} SubReady;
bitmap { filename = "BlankSubjectWait.bmp";} SubWait;
bitmap { filename = "BlankSubjectMonitorPlus.bmp";} WhitePlus;
bitmap { filename = "BlankSubjectButtbefore.bmp";} SubButtbefore;
bitmap { filename = "BlankSubjectButtafter.bmp";} SubButtafter;
bitmap { filename = "BlankSubjectRest.bmp";} SubRest;
#bitmap { filename = "BlankSubject.bmp";} blankPCX;

wavefile { filename = "04_button_tone_intsructions.wav"; } butttoneInstruct;
sound {
    wavefile butttoneInstruct;
    attenuation = 0.3;
} butttoneInstruction;

picture {
      bitmap SubMonitor;
      x = 0; y = 0;
} default; 

trial {

monitor_sounds = false;

sound butttoneInstruction;
time = 0;


picture {bitmap SubReady;
			x = 0; y = 0;
			};
			time = 5500; # 5.5 secs
			duration = next_picture;
			
picture {bitmap SubWait;
			x = 0; y = 0;
			};
			time = 13000; # 13 secs
			duration = next_picture;
			
picture {bitmap WhitePlus;
			x = 0; y = 0;
			};
			time = 19000; #19 secs
			duration = next_picture;

picture {bitmap SubButtbefore;
			x = 0; y = 0;
			};
			time = 26000; # 8 secs
			duration = next_picture;

picture {bitmap SubButtafter;
			x = 0; y = 0;
			};
			time = 27000; #8.5 secs
			duration = next_picture;

picture {bitmap WhitePlus;
			x = 0; y = 0;
			};
			time = 29000; #10 secs
			duration = next_picture;
			
picture {bitmap SubRest;
			x = 0; y = 0;
			};
			time = 35000; #29 secs
			duration = next_picture;

picture {bitmap WhitePlus;
			x = 0; y = 0;
			};
			time = 48000; #10 secs
			duration = next_picture;

picture {bitmap SubButtbefore;
			x = 0; y = 0;
			};
			time = 54000; # 19 secs
			duration = next_picture;
picture {bitmap SubButtafter;
			x = 0; y = 0;
			};
			time = 55000; #19.5 secs
			duration = next_picture;

picture {bitmap SubMonitor;
			x = 0; y = 0;
			};
			time = 56500; # 5.5 secs
			duration = next_picture;
};