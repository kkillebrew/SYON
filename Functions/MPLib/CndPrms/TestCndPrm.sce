scenario = "TestCndPrm";

active_buttons = 2;
button_codes = 1,2;

begin;
begin_pcl;

array<string> tPrms[0];
array<string> tCnds[0];
array<string> tCndPrms[0][0];
array<string> tCndsChk[6] = { "default", "0", "1", "10", "11", "12" };
array<string> tPrmsChk[5] = 
	{ "Duration_Word_MSec", "background_color", "font", "font_color", "font_size" };

/*
use the following in CndPrms.txt:
code	Duration_Word_MSec	background_color	font	font_color	font_size
default	500	127.127.127	default	127.127.127	1
0					2
1				0.255.0	
10			times		
11	750				
12					
*/

include_once "CndPrms.pcl";
string tCndPrmFileName = "CndPrms.txt";
LoadCndPrms( tCndPrmFileName, tCndPrms, tCnds, tPrms, tCndsChk, tPrmsChk );

string tCnd = "1";
string tPrm = "font_color";
if IsCndPrm( tCnd, tPrm, tCnds, tPrms ) then
#	# either just print the strings
#	term.print( tCnd + ", " + tPrm + ": " + GetCndPrm( tCnd, tPrm, tCnds, tPrms, tCndPrms ) + "\n" );

# or print the color...
	rgb_color tC = GetCndPrmColor( tCnd, tPrm, tCnds, tPrms, tCndPrms );
	string tCStr = string( tC.red_byte() ) + ", " + string( tC.green_byte() ) + ", " + string( tC.blue_byte() ) + "\n";
	term.print( tCnd + ", " + tPrm + ": " + tCStr + "\n" );
else
	term.print( "Condition " + tCnd + ": " + tPrm + " is not file-defined.\n" );
end





