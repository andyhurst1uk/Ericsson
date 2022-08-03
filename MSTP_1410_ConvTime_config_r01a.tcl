#####################################################################
# This is a generic config file that is valid for both the CIST test or the
# 14 x MSTIs version of the test, the variation on the test is set by the
# parameter cTEST_OPTION
#####################################################################

global errorInfo
set cCONVERGENCE_MAX_T3_TIME    100000000
set cCONVERGENCE_MAX_GAP_TIME   0.050
set cMAC_INCR_NUM               1420
set cITERATIONS                 10
set cCHASSIS_IP                 "10.44.3.136" ;# IP address of Ixia Chassis
set cUSER_NAME                  $env(USERNAME)
set cSHELF                      1
set cCARD                       2
set cPORT                       1
set cTEST_OPTION                MSTP           ;#RST or MSTP
set cMAINTAIN_NEXT_CONNECTID    0   ;# variable in 14xxSETAllConnections, 0- allows Failed to write to file
set cOMS1410                    1   ;# configures the OMS1410 if set to 1
set cMSTPConfig                 1   ;# configures the MSTP if set to 1
set cEXTRADISPLAY               10  ;# Display exta info in log - pre-TCN inter-frames gaps
set cTEST_NAME                  "OMS1410 MSTP Convergence Time Test"
set cSCRIPT_VERSION             "v1.0"
## Get the software build for remote regression testing only
if {[info exists env(ABAT_BUILD_ZIP_NAME)]} {
    set cSUT  $env(ABAT_BUILD_ZIP_NAME)
} else {
    set cSUT  "SW_Version_Unknown"
}
#####################################################################
# List to set Ixia chassis - including ch ca po name and DA and SA
#####################################################################

set cIXIAPORTLIST   [list   "1 2 2 idle 000033333333 000044444444" \
                            "1 2 1 Sniffer 000011111111 000022222222" \
                            "1 1 1 TX_path 000022222222 000011111111"]
#set cIXIAPORTLIST   [list   "1 1 3 idle 0180C2000000 0180C2000000" \
#                            "1 1 2 Sniffer 0180C2000000 0180C2000000" \
#                            "1 1 1 TX_path 0180C2000000 0180C2000000"]
# where 0180C2000000 = multicast
#####################################################################
# Variables for switching function on or off
#####################################################################

set		cLOGGING			1	;# 0 Output to screen, 1 output to a file
set		cCONFIG_IXIA		1	;# 0 Will not configure the Ixia chassis, 1 will configure the chassis
set		cCONFIG_DUT 		1	;# 0 Will not configure the DUT, 1 will configure the DUT

#####################################################################
# This is stuff defines the parameters for the log header.
#####################################################################

set cCONFIGURATION    		        "MSTP convergence Test"
set cSCRIPT_NAME			convergence_Test
set cSCRIPT_DESCRIPTION   	        "\tTo run a network topology chance scenario and test for convergence times \n"	;# Name of the script
set cTEST_PURPOSE 			"\tTo exercise the OMS1410 functionality"
set cTEST_SUITE				"Ixia - Optixia X16"										;# Name of the test suite
set cTEST_TEAM				"System Proving"
set cDUT_NAME 				"OMS1410"
set cDUT_VERSION 			"Release 3.0.1"

#####################################################################
# Define the mapping between virtual ports and bridge ports
#####################################################################
set VIRTUAL_PORT_MAP_GET(1) {0 0 1 5-5 2 5-11 3 5-12}
set VIRTUAL_PORT_MAP_GET(2) {0 0 1 5-1 2 5-2 3 5-11 4 5-12}

set VIRTUAL_PORT_MAP_SET(1) {0 0 1 5-5 2 5-11 3 5-12}
set VIRTUAL_PORT_MAP_SET(2) {0 0 1 5-1 2 5-2 3 5-11 4 5-12}