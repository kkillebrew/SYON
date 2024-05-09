scenario = "SSVEP";

active_buttons = 2;
button_codes = 1,2;

write_codes = true; # ERP TRIGGER
pulse_width = 1;

$tPicBackColLum = 128;
default_background_color = $tPicBackColLum,$tPicBackColLum,$tPicBackColLum;

# reset screen units to deg of visual angle, where 1 deg = 1 cm
# AsusVG248QE
screen_width = 1920;
screen_height = 1080;

screen_bit_depth = 32;
screen_distance = 57.0; # AsusVG248QE
screen_width_distance = 53.2; # cm
screen_height_distance = 30.1; # cm

begin;

trial { nothing {}; nothing {}; nothing {};  nothing {}; nothing {};  nothing {}; nothing {};  nothing {}; nothing {};  nothing {}; nothing {};  nothing {}; nothing {};  nothing {}; nothing {};  nothing {}; nothing {};  nothing {};  nothing {}; nothing {}; nothing {};} tTrial; # mps 20190115 this is where the # of events per trial is being assigned
# mps 20190115 now 19 events per trial, which are the alternations...
trial { nothing {}; } tIBTrial; # inter-block trial
trial { nothing {}; } tIBTrialRest;

picture {} default; # required for all visual scenarios, will be shown between stimuli

begin_pcl;

set_random_seed( random(0, 1105) ); # happy birthday to me!

preset double Video_Frame_Rate_Hz = 144.0; # need user input for this; can't be auto-detected

array <double> newcolors [3][256]=
{{0,0.0960,0.1287,0.1527,0.1725,0.1896,0.2048,0.2186,0.2313,0.2431,0.2542,0.2646,0.2745,0.2840,0.2930,0.3017,0.3101,0.3181,0.3259,0.3334,0.3407,0.3479,0.3548,0.3615,0.3681,0.3745,0.3807,0.3869,0.3929,0.3987,0.4045,0.4101,0.4157,0.4211,0.4265,0.4317,0.4369,0.4420,0.4470,0.4520,0.4568,0.4616,0.4664,0.4710,0.4756,0.4802,0.4846,0.4891,0.4934,0.4978,0.5020,0.5063,0.5104,0.5146,0.5187,0.5227,0.5267,0.5306,0.5346,0.5384,0.5423,0.5461,0.5499,0.5536,0.5573,0.5610,0.5646,0.5682,0.5718,0.5753,0.5788,0.5823,0.5858,0.5892,0.5926,0.5960,0.5993,0.6026,0.6059,0.6092,0.6124,0.6157,0.6189,0.6221,0.6252,0.6284,0.6315,0.6346,0.6376,0.6407,0.6437,0.6467,0.6497,0.6527,0.6557,0.6586,0.6615,0.6645,0.6673,0.6702,0.6731,0.6759,0.6787,0.6815,0.6843,0.6871,0.6899,0.6926,0.6953,0.6980,0.7008,0.7034,0.7061,0.7088,0.7114,0.7141,0.7167,0.7193,0.7219,0.7245,0.7270,0.7296,0.7321,0.7347,0.7372,0.7397,0.7422,0.7447,0.7471,0.7496,0.7521,0.7545,0.7569,0.7593,0.7618,0.7642,0.7665,0.7689,0.7713,0.7736,0.7760,0.7783,0.7807,0.7830,0.7853,0.7876,0.7899,0.7922,0.7945,0.7967,0.7990,0.8012,0.8035,0.8057,0.8079,0.8101,0.8123,0.8145,0.8167,0.8189,0.8211,0.8233,0.8254,0.8276,0.8297,0.8318,0.8340,0.8361,0.8382,0.8403,0.8424,0.8445,0.8466,0.8487,0.8507,0.8528,0.8549,0.8569,0.8590,0.8610,0.8630,0.8650,0.8671,0.8691,0.8711,0.8731,0.8751,0.8771,0.8790,0.8810,0.8830,0.8849,0.8869,0.8889,0.8908,0.8927,0.8947,0.8966,0.8985,0.9004,0.9024,0.9043,0.9062,0.9081,0.9099,0.9118,0.9137,0.9156,0.9174,0.9193,0.9212,0.9230,0.9249,0.9267,0.9285,0.9304,0.9322,0.9340,0.9358,0.9377,0.9395,0.9413,0.9431,0.9449,0.9467,0.9484,0.9502,0.9520,0.9538,0.9555,0.9573,0.9591,0.9608,0.9626,0.9643,0.9660,0.9678,0.9695,0.9712,0.9730,0.9747,0.9764,0.9781,0.9798,0.9815,0.9832,0.9849,0.9866,0.9883,0.9900,0.9917,0.9933,0.9950,0.9967,0.9983,1.0000},

{0,0.0960,0.1287,0.1527,0.1725,0.1896,0.2048,0.2186,0.2313,0.2431,0.2542,0.2646,0.2745,0.2840,0.2930,0.3017,0.3101,0.3181,0.3259,0.3334,0.3407,0.3479,0.3548,0.3615,0.3681,0.3745,0.3807,0.3869,0.3929,0.3987,0.4045,0.4101,0.4157,0.4211,0.4265,0.4317,0.4369,0.4420,0.4470,0.4520,0.4568,0.4616,0.4664,0.4710,0.4756,0.4802,0.4846,0.4891,0.4934,0.4978,0.5020,0.5063,0.5104,0.5146,0.5187,0.5227,0.5267,0.5306,0.5346,0.5384,0.5423,0.5461,0.5499,0.5536,0.5573,0.5610,0.5646,0.5682,0.5718,0.5753,0.5788,0.5823,0.5858,0.5892,0.5926,0.5960,0.5993,0.6026,0.6059,0.6092,0.6124,0.6157,0.6189,0.6221,0.6252,0.6284,0.6315,0.6346,0.6376,0.6407,0.6437,0.6467,0.6497,0.6527,0.6557,0.6586,0.6615,0.6645,0.6673,0.6702,0.6731,0.6759,0.6787,0.6815,0.6843,0.6871,0.6899,0.6926,0.6953,0.6980,0.7008,0.7034,0.7061,0.7088,0.7114,0.7141,0.7167,0.7193,0.7219,0.7245,0.7270,0.7296,0.7321,0.7347,0.7372,0.7397,0.7422,0.7447,0.7471,0.7496,0.7521,0.7545,0.7569,0.7593,0.7618,0.7642,0.7665,0.7689,0.7713,0.7736,0.7760,0.7783,0.7807,0.7830,0.7853,0.7876,0.7899,0.7922,0.7945,0.7967,0.7990,0.8012,0.8035,0.8057,0.8079,0.8101,0.8123,0.8145,0.8167,0.8189,0.8211,0.8233,0.8254,0.8276,0.8297,0.8318,0.8340,0.8361,0.8382,0.8403,0.8424,0.8445,0.8466,0.8487,0.8507,0.8528,0.8549,0.8569,0.8590,0.8610,0.8630,0.8650,0.8671,0.8691,0.8711,0.8731,0.8751,0.8771,0.8790,0.8810,0.8830,0.8849,0.8869,0.8889,0.8908,0.8927,0.8947,0.8966,0.8985,0.9004,0.9024,0.9043,0.9062,0.9081,0.9099,0.9118,0.9137,0.9156,0.9174,0.9193,0.9212,0.9230,0.9249,0.9267,0.9285,0.9304,0.9322,0.9340,0.9358,0.9377,0.9395,0.9413,0.9431,0.9449,0.9467,0.9484,0.9502,0.9520,0.9538,0.9555,0.9573,0.9591,0.9608,0.9626,0.9643,0.9660,0.9678,0.9695,0.9712,0.9730,0.9747,0.9764,0.9781,0.9798,0.9815,0.9832,0.9849,0.9866,0.9883,0.9900,0.9917,0.9933,0.9950,0.9967,0.9983,1.0000},

{0,0.0960,0.1287,0.1527,0.1725,0.1896,0.2048,0.2186,0.2313,0.2431,0.2542,0.2646,0.2745,0.2840,0.2930,0.3017,0.3101,0.3181,0.3259,0.3334,0.3407,0.3479,0.3548,0.3615,0.3681,0.3745,0.3807,0.3869,0.3929,0.3987,0.4045,0.4101,0.4157,0.4211,0.4265,0.4317,0.4369,0.4420,0.4470,0.4520,0.4568,0.4616,0.4664,0.4710,0.4756,0.4802,0.4846,0.4891,0.4934,0.4978,0.5020,0.5063,0.5104,0.5146,0.5187,0.5227,0.5267,0.5306,0.5346,0.5384,0.5423,0.5461,0.5499,0.5536,0.5573,0.5610,0.5646,0.5682,0.5718,0.5753,0.5788,0.5823,0.5858,0.5892,0.5926,0.5960,0.5993,0.6026,0.6059,0.6092,0.6124,0.6157,0.6189,0.6221,0.6252,0.6284,0.6315,0.6346,0.6376,0.6407,0.6437,0.6467,0.6497,0.6527,0.6557,0.6586,0.6615,0.6645,0.6673,0.6702,0.6731,0.6759,0.6787,0.6815,0.6843,0.6871,0.6899,0.6926,0.6953,0.6980,0.7008,0.7034,0.7061,0.7088,0.7114,0.7141,0.7167,0.7193,0.7219,0.7245,0.7270,0.7296,0.7321,0.7347,0.7372,0.7397,0.7422,0.7447,0.7471,0.7496,0.7521,0.7545,0.7569,0.7593,0.7618,0.7642,0.7665,0.7689,0.7713,0.7736,0.7760,0.7783,0.7807,0.7830,0.7853,0.7876,0.7899,0.7922,0.7945,0.7967,0.7990,0.8012,0.8035,0.8057,0.8079,0.8101,0.8123,0.8145,0.8167,0.8189,0.8211,0.8233,0.8254,0.8276,0.8297,0.8318,0.8340,0.8361,0.8382,0.8403,0.8424,0.8445,0.8466,0.8487,0.8507,0.8528,0.8549,0.8569,0.8590,0.8610,0.8630,0.8650,0.8671,0.8691,0.8711,0.8731,0.8751,0.8771,0.8790,0.8810,0.8830,0.8849,0.8869,0.8889,0.8908,0.8927,0.8947,0.8966,0.8985,0.9004,0.9024,0.9043,0.9062,0.9081,0.9099,0.9118,0.9137,0.9156,0.9174,0.9193,0.9212,0.9230,0.9249,0.9267,0.9285,0.9304,0.9322,0.9340,0.9358,0.9377,0.9395,0.9413,0.9431,0.9449,0.9467,0.9484,0.9502,0.9520,0.9538,0.9555,0.9573,0.9591,0.9608,0.9626,0.9643,0.9660,0.9678,0.9695,0.9712,0.9730,0.9747,0.9764,0.9781,0.9798,0.9815,0.9832,0.9849,0.9866,0.9883,0.9900,0.9917,0.9933,0.9950,0.9967,0.9983,1.0000}};

display_device.set_color_table (newcolors);
display_device.apply_color_table();

array<string> tPrms[0];
array<string> tCnds[0];
array<string> tCndPrms[0][0];
# AMK: following lines changed to match MPS version of CndPrms
array<string> tCndsChk[40] = { "default", "tvu1", "tvu2", "tvu3", "tvu4", "tvu5", "thu2", "thu3", "thu4", "thu5", 
	"pvu1", "pvu2", "pvu3", "pvu4", "pvu5", "phu1", "phu2", "phu3", "phu4", "phu5", 
	"tuf", "puf", "tvl2", "tvl3", "tvl4", "tvl5", "thl2", "thl3", "thl4", "thl5", 
	"pvl2", "pvl3", "pvl4", "pvl5", "phl2", "phl3", "phl4", "phl5", "tlf", "plf" };
array<string> tPrmsChk[17] = { "StimFolderName", "PortCode", "Center", "Flank", "CStartMS", "FStartMS",
	"CFpormMS", "Cdur", "TotDurMS", "PartSepDVAH", "PartSepDVAV", "ITIMeanMS", "ITIpormMS", "NTrialsPerBlockPerCnd", "NBlocksPerSsn" };

# this will be path used on HEPStim; if you use your path here, you'll have to change it to run on HEPStim
include_once "C:\\Users\\EEG Task Computer\\Desktop\\SYON.git\\Functions\\MPLib\\CndPrms\\CndPrms.pcl"; # mps 20210108 -- KWK will need to uncomment
include_once "C:\\Users\\EEG Task Computer\\Desktop\\SYON.git\\Functions\\MPLib\\FrameTiming\\FrameTiming.pcl"; # mps 20210108 -- KWK will need to uncomment
#include_once "D:\\SchallmoLab\\SYON.git\\Functions\\MPLib\\CndPrms\\CndPrms.pcl"; # mps 20210108 -- KWK will need to delete
#include_once "D:\\SchallmoLab\\SYON.git\\Functions\\MPLib\\FrameTiming\\FrameTiming.pcl"; # mps 20210108 -- KWK will need to delete

string tCndPrmFileName = "CndPrmsSSVEP_1.txt"; # if no path, then relative to this scenario folder
LoadCndPrms( tCndPrmFileName, tCndPrms, tCnds, tPrms, tCndsChk, tPrmsChk ); # load and check CndPrms from file

# How to use tCndsToRun:
# The user can run a subset of the cnds in CndPrms.txt
# by omitting the PortCode entry for the cnds to be skipped;
# The following aggregates a list of the cnds to run
# (i.e. the ones with non-blank PortCodes)
array< string > tCndsToRun[ 0 ];
loop int iCndChk = 2 until iCndChk > tCndsChk.count() begin
	if IsCndPrm( tCndsChk[ iCndChk ], "PortCode", tCnds, tPrms ) then
		tCndsToRun.add( tCndsChk[ iCndChk ] );
	end;
	iCndChk = iCndChk + 1;
end;
int tNCndsToRun = tCndsToRun.count();
int iCnd; # a counter for iterating over Cnds

string tStimFolderName = "none";
if IsCndPrm( "default", "StimFolderName", tCnds, tPrms ) then
tStimFolderName = GetCndPrm( "default", "StimFolderName", tCnds, tPrms, tCndPrms );
end;

double tPartSepH = 0; # set by AMK; horizontal separation of center stim from fixation marks

double tPartSepV = 0; # set by AMK; vertical separation of center stim from fixation marks

double rotateCorrectH = 0; # manually correct for slight miss-alignment...
double rotateCorrectV = -0.06;

int tNBlocksPerSsn = 3;
if IsCndPrm( "default", "NBlocksPerSsn", tCnds, tPrms ) then
tNBlocksPerSsn = GetCndPrmInt( "default", "NBlocksPerSsn", tCnds, tPrms, tCndPrms );
end;

int tNTrialsPerBlockPerCnd = 3;
if IsCndPrm( "default", "NTrialsPerBlockPerCnd", tCnds, tPrms ) then
tNTrialsPerBlockPerCnd = GetCndPrmInt( "default", "NTrialsPerBlockPerCnd", tCnds, tPrms, tCndPrms );
end;

# AMK: create PCL variables to calculate fixation cross locations
#double d = 57.0; # AMK: distance in cm for calculating fixation cross location
#double w = 37.5; # AMK: screen width in cm for calculating fixation cross location
#double quarter_w_over_d = (( 0.25 * w ) / d );
# AMK: calculate position of fixation crosses in degrees visual angle
#double fixLoc = arctan( quarter_w_over_d );
double fixLoc = 0; # AMK: this needs to be soft coded

# AMK: set rgb_color for transparency
rgb_color transColor = rgb_color( 128, 128, 128 );

double tBMPsize = 1.0; # AMK: set size of stimulus objects
double tFixSize = 0.5; # AMK changed from 0.5

# AMK moved following line here from elsewhere in code (commented out, not deleted)
string tFldNm = stimulus_directory + tStimFolderName; # stimulus_directory is a PCL predefined variable string equal

array< text > tFixPat[ 4 ]; #AMK created array of fixation objects where there was only one
tFixPat[ 1 ] = new text;
tFixPat[ 2 ] = new text;
#double tFixSize = 0.25; # AMK changed from 0.5
tFixPat[ 1 ].set_caption( "B" ); # mps 20210108
tFixPat[ 1 ].set_font_size( tFixSize );
tFixPat[ 1 ].set_font_color( 0, 0, 0, 255 );
tFixPat[ 1 ].set_background_color( 0, 0, 0, 0 );
tFixPat[ 1 ].redraw();
tFixPat[ 2 ].set_caption( " " ); # mps 20210108
tFixPat[ 2 ].set_font_size( tFixSize );
tFixPat[ 2 ].set_font_color( 255, 255, 255, 255 );
tFixPat[ 2 ].set_background_color( 0, 0, 0, 0 );
tFixPat[ 2 ].redraw();

bitmap tFiducialCirc = new bitmap; # AMK: create circles where stim will be presented
#double tBMPsize = 1.0; # AMK: set size of stimulus objects
tFiducialCirc.set_filename( tFldNm + "\\" + "grating0.bmp" ); # AMK: set circle as fiducial for stim
tFiducialCirc.set_load_size( 0.0, 0.0, tBMPsize ); # AMK: resize fiducial circle
tFiducialCirc.load(); # AMK: load circle pictures as fiducials
tFiducialCirc.set_transparent_color( transColor ); # AMK: make area around fiducial circles transparent
# since default picture is presented during calculation of ITI duration,
# adding the fixation pattern here prevents flickering
default.add_part( tFixPat[ 1 ], fixLoc + rotateCorrectH, rotateCorrectV ); # AMK changed vertical position from -tPartSepV; created two fixation crosses; added rotation correction
default.add_part( tFiducialCirc, fixLoc + tPartSepH, tPartSepV ); # AMK: right side fiducial marks
tFiducialCirc.set_transparent_color( transColor ); # AMK: make area around fiducial circles transparent

text tIBInstructions = new text;
tIBInstructions.set_caption( "For this task, press the far right button\nwhen you see a red flash at the center.\n\nPictures will flash outside of the center, you should ignore these.\n\nKeep your eyes at the center of the screen at all times.\n\nTry to only blink when you see the letter B.\n\nWe will do 3 blocks, each about 3.5 minutes long.\n\nNow blink a few times and rest.\n\nWhen you are ready to start, fix your eyes on\nthe center and let the experimenter know." );
tIBInstructions.set_font_size( tFixSize );
tIBInstructions.set_font_color(0, 0, 0, 255);
tIBInstructions.set_background_color( 0, 0, 0, 0 );
tIBInstructions.redraw();
text tIBInstructionsRest = new text;
tIBInstructionsRest.set_caption( "For this task, press the far right button\nwhen you see a red flash at the center.\n\nPictures will flash outside of the center, you should ignore these.\n\nKeep your eyes at the center of the screen at all times.\n\nTry to only blink when you see the letter B.\n\nWe will do 3 blocks, each about 3.5 minutes long.\n\nNow blink a few times and rest.\n\nWhen you are ready to start, fix your eyes on\nthe center and let the experimenter know." );
tIBInstructionsRest.set_font_size( tFixSize );
tIBInstructionsRest.set_font_color(255, 255, 255, 255);
tIBInstructionsRest.set_background_color( 0, 0, 0, 0 );
tIBInstructionsRest.redraw();
picture tIBPic = new picture;
tIBPic.add_part( tIBInstructions, fixLoc, 15.0 * tFixSize ); # AMK: changed from (0.0,5.0*tfixSize) and made dichoptic (left and right version)
tIBPic.add_part( tFixPat[ 1 ], fixLoc + rotateCorrectH, rotateCorrectV ); # AMK changed vertical position from -tPartSepV to 0.0; created two fixation crosses; added rotation correction
tIBPic.add_part( tFiducialCirc, fixLoc + tPartSepH, tPartSepV ); # added by AMK
tFiducialCirc.set_transparent_color( transColor ); # AMK: make area around fiducial circles transparent
picture tIBPicRest = new picture;
tIBPicRest.add_part( tIBInstructionsRest, fixLoc, 15.0 * tFixSize ); # AMK: changed from (0.0,5.0*tfixSize) and made dichoptic (left and right version)
tIBPicRest.add_part( tFixPat[ 1 ], fixLoc + rotateCorrectH, rotateCorrectV ); # AMK changed vertical position from -tPartSepV to 0.0; created two fixation crosses; added rotation correction
tIBPicRest.add_part( tFiducialCirc, fixLoc + tPartSepH, tPartSepV ); # added by AMK
tFiducialCirc.set_transparent_color( transColor ); # AMK: make area around fiducial circles transparent

tIBTrial.get_stimulus_event( 1 ).set_stimulus( tIBPic );
tIBTrial.set_duration( forever );
tIBTrial.set_type( first_response );
tIBTrialRest.get_stimulus_event( 1 ).set_stimulus( tIBPicRest );
tIBTrialRest.set_duration( 5000 );
#tIBTrialRest.set_type( first_response );

array< int > tITIMean[ tNCndsToRun ];
array< int > tITIporm[ tNCndsToRun ];
array< int > tPortCodes[ tNCndsToRun ];

# resources for center stimuli
# MPS changed tCImgFNms to tCLImgFNms and tCRImgFNms
array< string > tCImgFNms[ tNCndsToRun ]; # image file names (for each cnd to run)
array< int > tCStart[ tNCndsToRun ]; # start time
# AMK changed from tCBM to tCLBM & tCRBM
array< bitmap > tCBM[ 20 ]; # bitmaps # mps 20190115 add in 17 more bitmap for phase reversal
# resources for flank stimuli
# AMK changed tFImgFNms to tFLImgFNms and tFRImgFNms
array< string > tFImgFNms[ tNCndsToRun ];
array< int > tFStart[ tNCndsToRun ];
array< int > tCenterDur[ tNCndsToRun ];
array< int > tTotDur[ tNCndsToRun ];
array< int > tCFporm[ tNCndsToRun ];
# AMK changed from tFBM to tFLBM & tFRBM
array< bitmap > tFBM[ 20 ]; # bitmaps # mps 20190115 add in 17 more bitmap for phase reversal
#array< bitmap > tSURF[ 3 ]; # bitmaps
array< picture > tPics[ 20 ]; # mps 20190115 add in 17 more bitmap for phase reversal

sub int GetDurPrm( string aPrmNm ) begin
	# streamlined sub for dense compound statement; must be defined here after decl/def of tCnds, etc.
	return GetCndPrmInt( tCndsToRun[ iCnd ], aPrmNm, tCnds, tPrms, tCndPrms );
end;

# AMK moved the following line earlier
#string tFldNm = stimulus_directory + tStimFolderName; # stimulus_directory is a PCL predefined variable string equal
																		# to folder selected in Stimulus Directory field of Stimulus Tab
																		
loop iCnd = 1 until iCnd > tNCndsToRun begin
	# AMK separated filename lists for Center and Flank into left and right versions
	tCImgFNms[ iCnd ] = GetCndPrm( tCndsToRun[ iCnd ], "Center", tCnds, tPrms, tCndPrms ); # MPS changed back
	tFImgFNms[ iCnd ] = GetCndPrm( tCndsToRun[ iCnd ], "Flank", tCnds, tPrms, tCndPrms );
	tPortCodes[ iCnd ] = GetCndPrmInt( tCndsToRun[ iCnd ], "PortCode", tCnds, tPrms, tCndPrms );
	tITIMean[ iCnd ] = GetDurPrm( "ITIMeanMS" );
	tITIporm[ iCnd ] = GetDurPrm( "ITIpormMS" );
	tCStart[ iCnd ] = GetDurPrm( "CStartMS" );
	tFStart[ iCnd ] = GetDurPrm( "FStartMS" );
	tCFporm[ iCnd ] = GetDurPrm( "CFpormMS" );
	tCenterDur[ iCnd ] = GetDurPrm( "Cdur" );
	tTotDur[ iCnd ] = GetDurPrm( "TotDurMS" );
	
	if tCFporm[ iCnd ] > abs( tCStart[ iCnd ] - tFStart[ iCnd ] ) then
		exit( "Cnd " + string( iCnd ) + ": CFpormMS must be less than difference between CStartMS and FStartMS" );
	end;
	
	if tCStart[ iCnd ] > 0 && tFStart[ iCnd ] > 0 then
		exit( "Cnd " + string( iCnd ) + ": Either CStartMS, or FStartMS, or both must be zero" );
	end;
	
	iCnd = iCnd + 1;
end;

int iPic;
loop iPic = 1 until iPic > tPics.count() begin
	tPics[ iPic ] = new picture;
	tTrial.get_stimulus_event( iPic ).set_stimulus( tPics[ iPic ] );
	
	tFBM[ iPic ] = new bitmap; # MPS just 1
		
	tPics[ iPic ].add_part( tFiducialCirc, fixLoc + tPartSepH, tPartSepV ); # AMK added fiducials to tPics array
	tFiducialCirc.set_transparent_color( transColor ); # AMK: make area around fiducial circles transparent
	
   tCBM[ iPic ] = new bitmap; # MPS just 1
		if (iPic > 1) && (iPic < 20) then
			tCBM[ iPic ].set_alpha( 255 ); # MPS just 1
			# AMK: make gray area surrounding center stim transparent
		#	tCLBM[ iPic ].set_transparent_color( transColor );
		#	tCRBM[ iPic ].set_transparent_color( transColor );
		else
			tCBM[ iPic ].set_alpha( 0 ); # MPS just 1
		end;
	# AMK: testing order of add_part effect
	tPics[ iPic ].add_part( tFBM[ iPic ], fixLoc + tPartSepH, tPartSepV ); # right target (AMK: right and left targets assigned separate bitmap arrays)
	# AMK: end test

	tPics[ iPic ].add_part( tCBM[ iPic ], fixLoc + tPartSepH, tPartSepV ); # right target (AMK: right and left targets assigned separate bitmap arrays)
	
	# AMK: make gray area surrounding center stim transparent
	tCBM[ iPic ].set_transparent_color( transColor );
	# AMK: make gray area surrounding flank stim transparent
	tFBM[ iPic ].set_transparent_color( transColor );
	
	# MPS adding fixation after stim, so it appears in front
	tPics[ iPic ].add_part( tFixPat[ 2 ], fixLoc + rotateCorrectH, rotateCorrectV); # AMK changed vertical position from -tPartSepV to 0.0; created additional fixation cross
	
	iPic = iPic + 1;
end;

array< int > tRCnds[ tNTrialsPerBlockPerCnd * tNCndsToRun ]; # Random Cnds
tRCnds.fill( 1, 0, 1, 1 );
loop iCnd = 1 until iCnd > tRCnds.count() begin
	tRCnds[ iCnd ] = ( tRCnds[ iCnd ] % tNCndsToRun ) + 1;
	iCnd = iCnd + 1;
end;

int nStimImages = 18;

loop until clock.time() >= 0 begin end; # cf. NBS forum search: "Negative times reported"

int iB, iTr, tITI;
array< string > resetBMPs[ 4 ]; # AMK: create array for use in PrepareTrial (temporary storage of bitmap names for plaid Cnds

sub PrepareTrial
begin
	int imageDur = tCenterDur[iCnd] / nStimImages;
	int tDTporm =  1 * random( 0, tCFporm[ iCnd ] );   # 20190905 making it continuous in units of 1 instead of 100ms KWK
	int Phase = random( 1, 6 ); # AMK: create random integer to select phase of gratings added phase name to file naming below
	
	int fixCont;
	int fixOri;
    if tPortCodes[ iCnd ] == 30 || tPortCodes[ iCnd ] == 31 || tPortCodes[ iCnd ] == 130 || tPortCodes[ iCnd ] == 131 then # MPS 20191021
		fixCont = random( 1, 5 ); # MPS: random contrast
		fixOri = random( 1, 2 ); # MPS: random orientation
				
		# AMK: store original bitmap names in order to reset at end of trial
		resetBMPs[ 1 ] = tCImgFNms[ iCnd ];
		resetBMPs[ 2 ] = tFImgFNms[ iCnd ];

		if tPortCodes[ iCnd ] == 30 || tPortCodes[ iCnd ] == 130 then # MPS center only
			if fixCont == 1 then
				fixOri = 1;
			end;
			tCImgFNms[ iCnd ] = "grating1_cont" + string( fixCont ) + "_or" + string( fixOri );
		elseif tPortCodes[ iCnd ] == 31 || tPortCodes[ iCnd ] == 131 then
			tCImgFNms[ iCnd ] = "grating2_cont" + string( fixCont ) + "_or" + string( fixOri );
			tFImgFNms[ iCnd ] = "grating2_cont1_or" + string( fixOri );		
#		elseif tPortCodes[ iCnd ] == 42 then
#			tCImgFNms[ iCnd ] = "grating3_cont" + string( fixCont ) + "_or" + string( fixOri );
#			tFImgFNms[ iCnd ] = "grating3_cont1_or" + string( fixOri );
		end;
	end;
	
	int first_up_low;
	int second_up_low;
	if tPortCodes[ iCnd ] < 100 then
		first_up_low = 2; # 1 = lower, 2 = upper, event code < 100 = upper first
		second_up_low = 1;
	else
		first_up_low = 1;
		second_up_low = 2;
	end;
	
	if tPortCodes[ iCnd ] == 10 || ( tPortCodes[ iCnd ] == 30 && fixCont == 1 ) || ( tPortCodes[ iCnd ] == 130 && fixCont == 1 ) then # these are target = 0% contrast
		Phase = 1; # set these to 1, because I didn't make the other stimuli!
		first_up_low = 1;
		second_up_low = 1;
	elseif tPortCodes[ iCnd ] == 20 || tPortCodes[ iCnd ] == 25 || ( tPortCodes[ iCnd ] == 31 && fixCont == 1 ) || ( tPortCodes[ iCnd ] == 131 && fixCont == 1 ) then
		first_up_low = 1;
		second_up_low = 1;
	end;
	
	array <int> fixNum [20]= {1,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}; # 3 = white square at stim onset
	int randFix = 1;
	int sendFixCode = 0;
    if tPortCodes[ iCnd ] == 30 || tPortCodes[ iCnd ] == 31 || tPortCodes[ iCnd ] == 130 || tPortCodes[ iCnd ] == 131 then # MPS 20191021
		randFix = random( 1, 16 ) + 2; # put the fixation mark change randomly between pictures 3 and 18
		fixNum[ randFix ] = 2;
	end;
	int tPortCode = 0;
	
	loop iPic = 1 until iPic > tPics.count() begin
		# set up bitmaps
		# set up timing and codes
		stimulus_event tSE = tTrial.get_stimulus_event( iPic );
		# int tPortCode = ( iPic - 1 ) + tPortCodes[ iCnd ]; # AMK removed *10 multiplier from ( iPic - 1 )
		
       if tPortCodes[ iCnd ] == 30 || tPortCodes[ iCnd ] == 31 || tPortCodes[ iCnd ] == 130 || tPortCodes[ iCnd ] == 131 then # MPS 20191021
			if fixNum[ iPic ] == 2 then
				sendFixCode = 1;
			else
				sendFixCode = 0;
			end;
		end;
		
		if iPic == 1 then
			tPortCode = 3; # mps 20190117 fixation onset = 3
		elseif iPic == 2 then
			tPortCode = tPortCodes[ iCnd ]; # mps 20190117 change so only send if iPic == 2, only send the port code not modified by iPic
		elseif sendFixCode == 1 then
			tPortCode = 5; # mps 20190529 fixation mark = 5
		elseif iPic == 20 then
			tPortCode = 4; # mps 20190117 offset = 4
		else
			tPortCode = 0; # mps 20190117 change so only send if iPic == 2, only send the port code not modified by iPic
		end;
		
		tSE.set_port_code( tPortCode );

		# AMK set tEventCode to include image filenames for left and right center and flanking stim separately
		string tEventCode = "Pic" + string( iPic ) + ":" + string( tPortCode ) + ":" + tCImgFNms[ iCnd ] + "," + tFImgFNms[ iCnd ] + ", fix:" + string( fixNum[ iPic ] );
		tSE.set_event_code( tEventCode );
		int tDT = tCStart[ iCnd ] - tFStart[ iCnd ];
		
		if iPic == 1 then
			if tDT > 0 then
				# center comes on after flank
				tCBM[ iPic ].set_filename( tFldNm + "\\" + "grating0.bmp" ); # MPS just 1
				if tPortCodes[ iCnd ] < 20 || tPortCodes[ iCnd ] == 30 || ( tPortCodes[ iCnd ] > 110 && tPortCodes[ iCnd ] < 120 ) || tPortCodes[ iCnd ] == 130 then # mps 20191021
					tFBM[ iPic ].set_filename( tFldNm + "\\" + "grating0.bmp" ); # MPS just 1
				else
					tFBM[ iPic ].set_filename( tFldNm + "\\" + tFImgFNms[ iCnd ] + "_upLow1_fix1_ph" + string( Phase ) + ".bmp" ); # MPS just 1
				end;
			elseif tDT < 0 then
				# flank comes on after center
				tCBM[ iPic ].set_filename( tFldNm + "\\" + tCImgFNms[ iCnd ] + "_upLow1_fix1_ph" + string( Phase ) + ".bmp" ); # MPS just 1
				tFBM[ iPic ].set_filename( tFldNm + "\\" + "grating0.bmp" ); # MPS just 1
			else
				# both come on at same time
				tCBM[ iPic ].set_filename( tFldNm + "\\" + tCImgFNms[ iCnd ] + "_upLow" + string( first_up_low ) + "_fix" + string( fixNum[ iPic ] ) + "_ph" + string( Phase ) + ".bmp" ); # MPS just 1
                if tPortCodes[ iCnd ] < 20 || tPortCodes[ iCnd ] == 30 || ( tPortCodes[ iCnd ] > 110 && tPortCodes[ iCnd ] < 120 ) || tPortCodes[ iCnd ] == 130 then # mps 20191021
					tFBM[ iPic ].set_filename( tFldNm + "\\" + "grating0.bmp" ); # MPS just 1
				else
					tFBM[ iPic ].set_filename( tFldNm + "\\" + tFImgFNms[ iCnd ] + "_upLow1_fix1_ph" + string( Phase ) + ".bmp" ); # MPS just 1
				end;			end;
			tSE.set_deltat( 0 );
		elseif iPic == 2 then
			tCBM[ iPic ].set_filename( tFldNm + "\\" + tCImgFNms[ iCnd ] + "_upLow" + string( first_up_low ) + "_fix" + string( fixNum[ iPic ] ) + "_ph" + string( Phase ) + ".bmp" ); # MPS just 1
			tFBM[ iPic ].set_filename( tFldNm + "\\" + "grating0.bmp" ); # MPS just 1
			tSE.set_deltat( AdjFrDur( abs( tDT ) + tDTporm, Video_Frame_Rate_Hz ) ); # mps 20190115 this is setting duration for this event, want this one to have the random offset (delay from fixation)
		elseif iPic == 4  || iPic == 6  || iPic == 8  || iPic == 10  || iPic == 12  || iPic == 14  || iPic == 16  || iPic == 18 then
			tCBM[ iPic ].set_filename( tFldNm + "\\" + tCImgFNms[ iCnd ] + "_upLow" + string( first_up_low ) + "_fix" + string( fixNum[ iPic ] ) + "_ph" + string( Phase ) + ".bmp" ); # MPS just 1
			tFBM[ iPic ].set_filename( tFldNm + "\\" + "grating0.bmp" ); # MPS just 1
			tSE.set_deltat( AdjFrDur( imageDur, Video_Frame_Rate_Hz ) ); # mps 20190115 this is setting duration for this event, changing to imageDur
		elseif iPic == 3 || iPic == 5  || iPic == 7  || iPic == 9  || iPic == 11  || iPic == 13  || iPic == 15  || iPic == 17  || iPic == 19 then
			tCBM[ iPic ].set_filename( tFldNm + "\\" + tCImgFNms[ iCnd ] + "_upLow" + string( second_up_low ) + "_fix" + string( fixNum[ iPic ] ) + "_ph" + string( Phase ) + ".bmp" ); # MPS just 1
			tFBM[ iPic ].set_filename( tFldNm + "\\" + "grating0.bmp" ); # MPS just 1
			tSE.set_deltat( AdjFrDur( imageDur, Video_Frame_Rate_Hz ) ); # mps 20190115 this is setting duration for this event, changing to imageDur
		else
			tCBM[ iPic ].set_filename( tFldNm + "\\" + "grating0.bmp" ); # MPS just 1
            if tPortCodes[ iCnd ] < 20 || tPortCodes[ iCnd ] == 30 || ( tPortCodes[ iCnd ] > 110 && tPortCodes[ iCnd ] < 120 ) || tPortCodes[ iCnd ] == 130 then # mps 20191021
				tFBM[ iPic ].set_filename( tFldNm + "\\" + "grating0.bmp" ); # MPS just 1
			else
				tFBM[ iPic ].set_filename( tFldNm + "\\" + tFImgFNms[ iCnd ] + "_upLow1_fix1_ph" + string( Phase ) + ".bmp" ); # MPS just 1
			end;
			tSE.set_deltat( AdjFrDur(imageDur, Video_Frame_Rate_Hz) ); # mps 20190115 this is setting duration for this event, changing to imageDur
		end;
		tTrial.set_duration( AdjFrDur( tTotDur[ iCnd ] + tCenterDur[iCnd] + abs( tDT ) + tDTporm, Video_Frame_Rate_Hz ) );
		# mps 20190115 above is setting total trial duration...
		
		tCBM[ iPic ].set_load_size( 0.0, 0.0, tBMPsize ); # MPS just 1
		tFBM[ iPic ].set_load_size( 0.0, 0.0, tBMPsize );;
		
		tCBM[ iPic ].load(); # MPS just 1
		#tSURF[ iPic ].load();
		tFBM[ iPic ].load(); # MPS cut this out, only 1 picture type...
		iPic = iPic + 1;
	end;
	# AMK: as far as I can tell port codes can only be assigned to stimulus events within a trial
	#int tPortCode = 3 + tPortCodes[ iCnd ]; # AMK: create port code for ITI following each trial; from iPic 1 to ITI, port code assends (i.e. 1,2,3,4 or 5,6,7,8)
	#tTrial.set_port_code( tPortCode );
	
    if tPortCodes[ iCnd ] == 30 || tPortCodes[ iCnd ] == 31 || tPortCodes[ iCnd ] == 130 || tPortCodes[ iCnd ] == 131 then # MPS 20191021
		tCImgFNms[ iCnd ] = resetBMPs[ 1 ];
		tFImgFNms[ iCnd ] = resetBMPs[ 2 ];
		fixNum[ randFix ] = 1; # also reset fixNum...?
	end;
	
	#tITI = tITIMean[ iCnd ] - tITIporm[ iCnd ] + ( 2 * random( 0, tITIporm[ iCnd ] ) );# sjjoo_timing
	#tITI = tITIMean[ iCnd ];
	tITI = tITIMean[ iCnd ] + 1 * random( 0, tITIporm[ iCnd ] ); # 20190905 making it continuous in units of 1 instead of 100ms KWK
end;

loop iB = 1; until iB > tNBlocksPerSsn begin
	tIBTrialRest.present();
	tIBTrial.present();
	tRCnds.shuffle();
	loop iTr = 1; until iTr > tRCnds.count() begin
		iCnd = tRCnds[ iTr ];
		PrepareTrial();
		default.present();
#		wait_interval( AdjFrDur( tITI, Video_Frame_Rate_Hz ) );
		tTrial.set_start_delay( AdjFrDur( tITI, Video_Frame_Rate_Hz ) );
		tTrial.present();
		default.present();
		iTr = iTr + 1;
	end;
	iB = iB + 1;
end;















