###############################################################################################
#
#   NAME:       MSTP_1410_Convergence_Times_r01_exec.tcl
#
#   VERSION:    1.0 draft a
#
#   DATE:	01/11/07
#
#   AURTHOR:    David Stothert / Andy Hurst
#
#   USAGE:      MSTP_Convergence_Times_r01_exec.tcl <file.csv>
#
#   PURPOSE:	To configure a network of 2 bridges and check for convergence.
#               Once this state has been achieved then traffic is injected from
#		an Ixia chassis until MAC learning has been achieved.
# 		The test will then perfom a provocative action to trigger a
#		re-convergence of the network and after this event it will
#		check the Ixia chassis for the delay in reconvergence by
#  		investigating the recieved BPDUs and their time stamps to
#               calculate the delay in reconvergence.
#       
###############################################################################################

# Display and modify the console.  The catch is necessary in case this script is
# run in a tclsh in which case errors will be generated and will cause the
# script to terminate.
console show
console title "OMS1410 MSTP Convergence Time"
console eval {wm geometry . 101x35+430+1}
console eval { .console delete 1.0 end }
wm withdraw .

###############################################################################################
# Source the necessary common functions and configuration files
###############################################################################################
set 	eSCRIPT_DIR [file dirname [info script]]

source	[file join $eSCRIPT_DIR . Include common-functions-log.tcl]
source	[file join $eSCRIPT_DIR . Include common-functions.tcl]
source	[file join $eSCRIPT_DIR . Include utilities.tcl]
source	[file join $eSCRIPT_DIR . Include SDHCommonLibrary.tcl]
source	[file join $eSCRIPT_DIR . Include 14xxCommonLibrary.tcl]
source	[file join $eSCRIPT_DIR . Include XMLRPC.tcl]
source	[file join $eSCRIPT_DIR . MSTPInclude MstpCommonLibrary.tcl]
source	[file join $eSCRIPT_DIR . MSTPInclude 14xxMstpLibrary.tcl]
source	[file join $eSCRIPT_DIR MSTP_1410_ConvTime_Config_r01a.tcl]
source	[file join $eSCRIPT_DIR MSTP_1410_ConvTime_Lib_r01a.tcl]
source	[file join $eSCRIPT_DIR MSTP_Configuration_Files 14xxConfigFile.tcl]

### Update paths for Ixia libraries including the IxTclHal API
set env(IXTCLHAL_LIBRARY) "C:/Program Files/Ixia/IxOS/5.20-GA/TclScripts/lib/ixTcl1.0"
lappend auto_path "C:/Program Files/Ixia/"
lappend auto_path "C:/Program Files/Ixia/IxOS/5.20-GA/TclScripts/lib/IxTcl1.0"
append env(PATH) ";C:/Program Files/Ixia/"
source "C:/Program Files/Ixia/IxOS/5.20-GA/TclScripts/bin/IxiaWish.tcl"

set testSetSw "IxTclHal version [package require IxTclHal]"
package require http
package require tdom

###############################################################################################
# Log file details
###############################################################################################

# Switch on/off logging to file. Would like to remove this eventually
set	cLOGGING	1	;# 1 - Enable logging / 0 - Disable logging

# Generate log filename and directory
regexp {(\w+)_(\w+)_(\w+)} $::cSUT swVersion SwInfo3 swInfo2 SUTlogHeader
set TIME 	"[string map {/ -} [clock format [clock seconds] -format %y/%m/%d]]_[string map {: -} [clock format [clock seconds] -format %T]]"

set eLOGS_DIR 	[file join $eSCRIPT_DIR .. .. Report $SUTlogHeader "report.MSTPConvergenceTime.$TIME.$SUTlogHeader"]
file mkdir $eLOGS_DIR

set eSEQ_LOG	[file join $eSCRIPT_DIR .. .. Log "sequence.MSTPConvergenceTime.$TIME.$SUTlogHeader\.txt"]

set eREP_LOG 	[file join $eSCRIPT_DIR .. .. Report $SUTlogHeader report.MSTPConvergenceTime.$TIME.$SUTlogHeader \
              "report.MSTPConvergenceTime.$TIME.$SUTlogHeader\.txt"]


###############################################################################################
# Load Expect extension
###############################################################################################
package require Expect
exp_log_user 				0	;# Turn on/off echo logging to the user
set		::exp::winnt_debug  1	;# Show the controlled console
set		timeout             180	;# Expect timeout parameter set to 15 seconds

###############################################################################################
# MAIN
###############################################################################################

set cDEBUG      0
###### Declaring global variables #####
###### Define the valid equipment types currently supported by MSTP test scripts
set MSTP_EQUIP_TYPES {DS20Q DS20AD CISCO OMS1410}
set 14xx_CONNECT 1  	;# 1 - Connect to 1410 via  , 0 - use captured logs
set EXPORT_RESPONSE	0   ;# 1 - Export snmp responses, 0 - do not export.
set dut_port 8080
set http_protocol "http"
set XMLVersion "1.0"
set assignedNumRoot [XMLRPC_XmlParseNumbers ./AssignedNumbers.xml]
##set assignedNumRoot [XMLRPC_XmlParseNumbers ./AssignedNumbersPenguin.xml]
set FILENAMES {	1 macAddress
				2 configName
				3 configRevision
				4 configDigest
				5 inst
				6 instPri
				7 instDesRoot
				8 instRootPathCost
				9 instRootPort
				10 bridgePorts
				11 instIfDesRoot
				12 instIfDesBridge
				13 instDesIfPri
				14 instDesIfPort
				15 instIfState
				16 instIfRole
				17 instIfPri
				18 instIfCost}

array set EXPORT_FILENAMES $FILENAMES
set EXPORT_DIR [file join $eSCRIPT_DIR Capture]
array unset Results

###############################################################################################
##  Display Standard Report Header

set quickTestfSw "N/A"
##set sut "oms1410 release: [14xxGetSoftwareVersion $::cDUT_HOSTNAME(1)]"
set startTimeSec [clock format [clock seconds] -format "%s"]
GenerateStandardReportHeader $::cTEST_NAME $::cSCRIPT_VERSION $testSetSw $quickTestfSw $::cUSER_NAME $swVersion

###############################################################################################
## Configure all 14xx cards
###############################################################################################

set filename "14xxConfigFile.tcl"

if {$::cTEST_OPTION == "RST" } {
	set filename [file join $eSCRIPT_DIR RST_Configuration_Files $filename]
	} elseif {$::cTEST_OPTION == "MSTP"} {
	set filename [file join $eSCRIPT_DIR MSTP_Configuration_Files $filename]	
	} else {
		Mputs "\tThe \"TEST OPTION\" has not been defined correctly \n \
		It should be either MSTP or RST in the config file" -c -s
	}
## Apply OMS1410 configuration
if {$::cOMS1410 == 1} {
	
	if { [catch {14xxApplyConfiguration $filename} ] } {
		global errorInfo
		Mputs "\t$errorInfo" -c -s
		exit 1
	}
}
################################################################################################
## Configure the MSTP network
#################################################################################################
## Apply MSTP Configurations
if {$::cMSTPConfig == 1} {
	set filename "MstpBaselineConfig_1410.csv"
	if {$::cTEST_OPTION == "RST" } {
		set filename [file join $eSCRIPT_DIR RST_Configuration_Files CSV_TOOLS $filename]
		} elseif {$::cTEST_OPTION == "MSTP"} {
		set filename [file join $eSCRIPT_DIR MSTP_Configuration_Files CSV_TOOLS $filename]	
		} else {
			Mputs "\tThe \"TEST OPTION\" has not been defined correctly"
		}
	#### Apply MSTP configuration to the network

	Mputs "========================" -c -s
	Mputs "CONFIGURING MSTP NETWORK" -c -s
	Mputs "========================\n" -c -s
	if {[catch {MstpConfigureNetwork bridges.csv $filename networkMSTPdB -force}]} {
		global errorInfo
		Mputs $errorInfo -c -s
	   exit 1
	}
}
###############################################################################################
# Apply configuration to the Ixia chassis (with 3 ports)
###############################################################################################
if {[catch {SetupIxiaStreams}]} {
	global errorInfo
	Mputs $errorInfo -c -s
    exit 1
}
###############################################################################################
# Pull in the "Expected" results (NB: .csv files must exist in same directory)
###############################################################################################
if {$::cTEST_OPTION == "RST" } {
		set expConvFilename [file join $eSCRIPT_DIR RST_Configuration_Files CSV_TOOLS convergedFile_1410.csv]
		set expReconFilename [file join $eSCRIPT_DIR RST_Configuration_Files CSV_TOOLS reconvergedFile_1410.csv]
	} elseif {$::cTEST_OPTION == "MSTP"} {
		set expConvFilename [file join $eSCRIPT_DIR MSTP_Configuration_Files CSV_TOOLS convergedFile_1410.csv]
		set expReconFilename [file join $eSCRIPT_DIR MSTP_Configuration_Files CSV_TOOLS reconvergedFile_1410.csv]	
	} else {
		Mputs "\tThe \"TEST OPTION\" has not been defined correctly"
	}
##after 15000
if {[catch {MstpProcessExpectedFile $expConvFilename expectedMSTPdBconverged}]} {
	Mputs $errorInfo -c -s
    exit 1
}

if {[catch {MstpProcessExpectedFile $expReconFilename expectedMSTPdBReconverged}]} {
	Mputs $errorInfo -c -s
    exit 1
}
###############################################################################################
# Recognition of link A's location within the network
###############################################################################################

## Source 14xxConfigFile.tcl
set filename "14xxConfigFile.tcl"
set filename [file join $eSCRIPT_DIR MSTP_Configuration_Files $filename]
source $filename
## Find the slot/port designated as link A
foreach Link $::cSDHCARDINTERFACES_LIST(1) {
  regexp {(\d+) (\d+) (\w+) Link(\w+)} $Link trash slot port trash2 AorB
  if {$AorB == "A"} {
		set linkAslot $slot
		set linkAport $port
  }
}

###############################################################################################
# START OF THE PROVOCATIVE SECTION OF THE TEST
###############################################################################################

###### FOR loop for multiple iterations ######

set validatnRstList ""

for {set i 1} {$i <= $::cITERATIONS} {incr i} {
	
	###### Set up for convergence testing ######
	set convergenceState "converging"
	set CONVERGENCESTATE "CONVERGING"
	array set expectedMSTPdB [array get expectedMSTPdBconverged]
	
	###### Set up for RE-convergence testing ######
	for {set j 1} {$j <= 2} {incr j} {
		if {$j == 2} {
			array set expectedMSTPdB [array get expectedMSTPdBReconverged]
			set convergenceState "re-converging"
			set CONVERGENCESTATE "RE-CONVERGING"
		}
		
		###### Network (calculated(config files)) status versus Expected (measured (shelf)) status ######
		set title "TESTING ITERATION $i OF $::cITERATIONS, CONVERGENCE STATUS:- $CONVERGENCESTATE"
		
		Mputs "[Underline [string length $title] =]" -c -s
		Mputs "$title" -c -s
		Mputs "[Underline [string length $title] =]\n" -c -s
		
		
		if {[catch {MstpGetNetworkStatus networkMSTPdB bridges.csv {1 2}}]} {
			Mputs $errorInfo -c -s
			exit 1
		}
		
		MstpTranslateExpecteddB expectedMSTPdB networkMSTPdB
		
		if {[catch {MstpValidateNetworkStatus networkMSTPdB expectedMSTPdB -ld} result]} {

			Mputs $errorInfo -c -s
			exit 1
		}
		set validatnRstlt($convergenceState$i) $result
		lappend validatnRstList "$i"
		lappend validatnRstList "$convergenceState"
		lappend validatnRstList "$result"
		
		###### Run provocative section of test prior to extracting results ######
		if {[catch {RunProvactiveTest $convergenceState $CONVERGENCESTATE $linkAslot $linkAport $i}] } {
			global errorInfo
			Mputs $errorInfo -c -s
			exit 1
		}

		######  Set Ixia sniffer and idle ports ######
		foreach port $::cIXIAPORTLIST {
			regexp {(\d+) (\d+) (\d+) (\w+) (\w+) (\w+)} $port trash ch ca po name destAddress sourceAddress
			if {$name == "Sniffer"} {
				set chSnif $ch
				set caSnif $ca
				set poSnif $po
			} elseif {$name == "idle"} {
				set chIdle $ch
				set caIdle $ca
				set poIdle $po
			}
		}
		###### Find time T2 from Ixia sniffer port capture buffers ######
		if {[catch {findT2 $chSnif $caSnif $poSnif $i Results $convergenceState} timelist]} {
			global errorInfo
			Mputs $errorInfo -c -s
			exit 1
		}
		###### Find time T3 from Ixia idle port capture buffers ######
#		if {$timelist == 0} {
#			Mputs "\tTerminating search for MAC address flooding\n" -c -s
#			
#		} else {}
				if {[catch {findT3 $chIdle $caIdle $poIdle $i Results $convergenceState}]} {
					global errorInfo
					Mputs $errorInfo -c -s
			
				}
		
		array unset expectedMSTPdB
	}
	Mputs "\tWaiting for 30 seconds\n" -c -s
	after 30000
}
###############################################################################################
# Output total results
###############################################################################################

Mputs "==============================================" -c -s -r
Mputs "REPORTING ON CONVERGENCE TIME TEST FOR OMS1410" -c -s -r
Mputs "==============================================\n" -c -s -r

if {[catch {ResultsCheckerandLogOutput Results $::cITERATIONS $timelist $validatnRstList}]} {
	global errorInfo
	Mputs $errorInfo -c -s
    exit 1
}
###### The end of the test ######
Mputs "\n\n" -c -s
GenerateStandardReportFooter $startTimeSec
exit

