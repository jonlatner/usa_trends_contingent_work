/* Please do not attemp to run this program without reading the accompanying documentation. */

version 8.0
set more off
prog drop _all
capture log close
clear

/*
File: extract_01.do
Date: August 11, 2003
Desc: This program extracts the 2001 data.
Note: See copyright notice at the end of this program.
*/

/* Acknowledgements

I am grateful to Jean Roth and others at the NBER for their efforts to make 
the data widely available. Many thanks also to Helen Connolly, Danielle Gao, 
Noelle (Bethney) Gundersen, John Schmitt, Jeffrey Sisson, Jeffrey Wenger and 
the SIPP Outreach Staff at the U.S. Census Bureau for helpful discussions 
about the SIPP data. Bradley Hardy provided valuable research assistance on 
this project.

The construction of this SIPP extract has been funded by a generous grant from 
the Rockefeller Foundation.

The *.do and *.dct files associated with this extract program that begin with the 
prefix "sip" were initially created by Jean Roth at the National Bureau of 
Economic Research, although they have been edited for use in this program. 
Complete details and all underlying data are available from the NBER 
(www.nber.org). Please report errors in those program to jroth@nber.org. 
Copyright 2003 shared by Jean Roth and the National Bureau of Economic Research.

The underlying Survey of Income and Program Participation data referenced here 
are in the public domain. The programs are distributed under the GNU GPL. 
See end of this file and http://www.gnu.org/licenses/ for details.

*/

/* USER NOTES

This program will read the 2001 SIPP panel into Stata format and label 
the variables and their values. The underlying data must be downloaded from 
the NBER (http://www.nber.org/data/sipp.html), or from the U.S. Census. 
The raw data will come in *.dat format. Downloading directions can 
be found at the CEPR websited (http:///www.cepr.net/data/sipp_extract.html). 

CEPR's extract programs are meant to substitute for the NBER *.dct and 
*.do files so these do not need to be downloaded from the NBER. In particular, 
the CEPR programs have changed the format of the variables necessary 
to generate the unique id from numeric into string in order to 
concatenate them correctly.

Prior to running this program, the user should create two directories and 
suggested names are below. If you choose not to create directories with the 
following names, you must change the directories referred to below as well as 
make changes in every *.do and *.dct file associated with this extract program 
to reflect your preferred directory structure. This process will be much 
less painful if you use the directory names suggested below.

Save all *.do and *.dct files (from CEPR) in the following directory:
c:\_files\programs\sipp\extract\sipp01\

Save all unzipped *.dat files (from the NBER or the U.S. Census) in the 
following directory:
c:\_files\data\sipp\sipp01\

This program was written for Intercooled Stata Version 8.0. It is 
recommended that you have 1GB of ram memory. 

Please direct all questions to <datahelp@cepr.net>.

*/

/*If you run GNU/Linux, be sure to change $rootdir to match your root directory*/
global rootdir ~/GitHub/usa_trends_contingent_work/data_files/SIPP
global programs $rootdir/programs/sipp08
global dictdir $rootdir/programs/sipp08
global rawdata $rootdir/rawdata/sipp08
global output $rootdir/rawdata/sipp08


/*Core and Regular Topical Module Files*/
capture program drop loop9
program define loop9
while "`1'"~="" {
	local i=1
	while `i'<17 {		
		cd $programs
		do sippl08puw`i'.do
		
		* gen unique id to merge
		sort ssuid eentaid epppnum
		egen id = concat(ssuid eentaid epppnum)
		
		rename swave wave
		rename srotaton rot
		sort id rot wave
		
		cd $output
		save sipp08`1'`i'.dta, replace
		log close
		clear
		
		local i=`i'+1
	}
	mac shift
}
end


/*For longitidual weights*/
capture program drop lweights
program define lweights
	cd $programs

	/*Macros for dictionary files and raw SIPP data files*/
	do sipplgtwgt2008w16.do

	cd $output
	save sipp08lwt.dta, replace
end


/*Extract programs to run*/

loop9 w t
lweights


/*
Copyright 2003 Heather Boushey

Center for Economic and Policy Research
1621 Connecticut Avenue, NW
Suite 500
Washington, DC 20009
Tel: (202) 293-5380
Fax: (202) 588-1356
http://www.cepr.net

This program and all programs referenced in it are free software. You
can redistribute the program or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation;
either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
USA.
*/



