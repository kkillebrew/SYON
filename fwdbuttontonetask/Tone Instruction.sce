scenario = "tone Instructions";
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

wavefile { filename = "05_tone_instructions.wav"; } toneInstruct;
sound {
    wavefile toneInstruct;
    attenuation = 0.3;
} toneInstruction;

picture {
      bitmap SubMonitor;
      x = 0; y = 0;
} default; 

trial {

monitor_sounds = false;

sound toneInstruction;
time = 0;


};