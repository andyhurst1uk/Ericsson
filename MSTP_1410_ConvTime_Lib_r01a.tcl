
##############################################################
#   Configure the Ixia Chassis with as many ports to the
#   require config as are detailed in the array.
##############################################################

proc SetupIxiaStreams {} {
    
######### Chassis list - {10.243.123.25} #########

ixConnectToChassis   $::cCHASSIS_IP

set owner $::cUSER_NAME
ixLogin                      $owner            


######### Chassis-10.243.123.25 #########
chassis                      get               $::cCHASSIS_IP
set chassis	  [chassis cget -id]



foreach port $::cIXIAPORTLIST {
        
        regexp {(\d+) (\d+) (\d+) (\w+) (\w+) (\w+)} $port trash ch ca po name destAddress sourceAddress
            
        regexp {(.\w)(.\w)(.\w)(.\w)(.\w)(.\w)} $destAddress trash mac1 mac2 mac3 mac4 mac5 mac6
        set destAddress "$mac1 $mac2 $mac3 $mac4 $mac5 $mac6"
        regexp {(.\w)(.\w)(.\w)(.\w)(.\w)(.\w)} $sourceAddress trash mac1 mac2 mac3 mac4 mac5 mac6
        set sourceAddress "$mac1 $mac2 $mac3 $mac4 $mac5 $mac6"
        
        #ixClearTimeStamp $::cIXIAPORTLIST
        if {$name == "idle"} {
            
            set portList {}
            set chassis $ch
            set ownershipPortList "{$ch $ca $po}"
            ixTakeOwnership $ownershipPortList force
            
            set card     $ca
            card                         setDefault        
            card                         set               $chassis $card
            card                         write             $chassis $card
            
            ######### Chassis-10.243.123.25 Card-1  Port-3 #########
            
            set port     $po
            
            port                         setFactoryDefaults $chassis $card $port
            port                         setPhyMode        $::portPhyModeCopper $chassis $card $port
            
            port                         config            -autonegotiate                      true
            port                         config            -advertise1000FullDuplex            true
            port                         config            -negotiateMasterSlave               1
            port                         set               $chassis $card $port
            
            stat                         setDefault        
            stat                         set               $chassis $card $port
            
            ipAddressTable               setDefault        
            ipAddressTable               set               $chassis $card $port
            
            interfaceTable               select            $chassis $card $port
            interfaceTable               setDefault        
            interfaceTable               set               
            interfaceTable               clearAllInterfaces 
            protocolServer               setDefault        
            protocolServer               set               $chassis $card $port
            
            flexibleTimestamp            setDefault        
            flexibleTimestamp            set               $chassis $card $port
            
            capture                      setDefault
            capture                      config            -captureMode                        captureContinuousMode
            capture                      set               $chassis $card $port
            filter                       setDefault        
            filter                       set               $chassis $card $port
            filterPallette               setDefault        
            filterPallette               set               $chassis $card $port
            lappend                      portList          [list $chassis $card $port]
            ixWritePortsToHardware       portList          
            ixCheckLinkState             portList          
            
            
            
            ###################################################################
            ######### Generating streams for all the ports from above #########
            ###################################################################
            
            
            ######### Chassis-10.243.123.25 Card-1  Port-3 ########
            
            set streamId 1
            
            #  Stream 1
            stream                       setDefault        
            stream                       config            -name                               $name
            stream                       config            -numFrames                          2
            stream                       config            -ifgMIN                             1920.0
            stream                       config            -ifgMAX                             2560.0
            stream                       config            -fpsRate                            148809.52381
            stream                       config            -bpsRate                            76190476.1905
            stream                       config            -percentPacketRate                  1.0
            stream                       config            -sa                                 $sourceAddress
            stream                       config            -da                                 $destAddress
            stream                       config            -frameType                          "FF FF"
            stream                       config            -numDA                              16
            stream                       config            -numSA                              16
            stream                       config            -asyncIntEnable                     true
            protocol                     setDefault           
            protocol                     config            -enable802dot1qTag                  vlanSingle
            
            vlan                         setDefault        
            vlan                         config            -vlanID                             100
            vlan                         config            -userPriority                       5
            vlan                         config            -maskval                            "1010XXXXXXXXXXXX"
            vlan                         set               $chassis $card $port
            
            if {[port isValidFeature $chassis $card $port $::portFeatureTableUdf]} { 
                tableUdf setDefault
                tableUdf clearColumns
                tableUdf set $chassis $card $port
            }
            
            
            if {[port isValidFeature $chassis $card $port $::portFeatureRandomFrameSizeWeightedPair]} { 
                weightedRandomFramesize setDefault
                weightedRandomFramesize set $chassis $card $port
            }
            
            stream                       set               $chassis $card $port $streamId
            incr                         streamId          
            ixWriteConfigToHardware      portList          -noProtocolServer  
                        
            
        } else {
            
            set portList {}
            set ownershipPortList "{$ch $ca $po}"
            ixTakeOwnership $ownershipPortList force           
            
            ######### Chassis-10.243.123.25 #########
            
            ######### Card Type : 10/100/1000 STXS4-256MB ############
            
            set card     $ca
            card                         setDefault        
            card                         set               $chassis $card
            card                         write             $chassis $card
            
            ######### Chassis-10.243.123.25 Card-1  Port-1 #########
            
            set port     $po
            
            port                         setFactoryDefaults $chassis $card $port
            port                         setPhyMode        $::portPhyModeCopper $chassis $card $port
            port                         config            -autonegotiate                      true
            port                         config            -advertise1000FullDuplex            true
            port                         config            -negotiateMasterSlave               1
            port                         set               $chassis $card $port
            
            stat                         setDefault        
            
            stat                         set               $chassis $card $port
            
            ipAddressTable               setDefault        
            ipAddressTable               set               $chassis $card $port
            
            interfaceTable               select            $chassis $card $port
            interfaceTable               setDefault        
            interfaceTable               set               
            interfaceTable               clearAllInterfaces 
            protocolServer               setDefault        
            protocolServer               set               $chassis $card $port
            
            flexibleTimestamp            setDefault        
            flexibleTimestamp            set               $chassis $card $port
            
            capture                      setDefault
            capture                      config            -captureMode                        captureContinuousMode
            capture                      set               $chassis $card $port
            filter                       setDefault        
            
            filter                       set               $chassis $card $port
            filterPallette               setDefault        
            filterPallette               set               $chassis $card $port
            lappend                      portList          [list $chassis $card $port]
            ixWritePortsToHardware       portList          
            ixCheckLinkState             portList          
            
            
            
            ###################################################################
            ######### Generating streams for all the ports from above #########
            ###################################################################
            
            
            ######### Chassis-10.243.123.25 Card-1  Port-1 #########
            
            set streamId 1
            
            #  Stream 1
            stream                       setDefault        
            stream                       config            -name                               $name
            stream                       config            -numFrames                          2
    
            stream                       config            -numFrames                          2
            stream                       config            -ifg                                2809919.99023
            stream                       config            -ifgMIN                             1920.0
            stream                       config            -ifgMAX                             2560.0
            stream                       config            -ibg                                2809919.99023
            stream                       config            -isg                                2809919.99023
            stream                       config            -percentPacketRate                  0.25
            stream                       config            -fpsRate                            355.113636364
            stream                       config            -bpsRate                            193181.818182
            stream                       config            -sa                                 $sourceAddress
            stream                       config            -saRepeatCounter                    increment
            stream                       config            -da                                 $destAddress
            stream                       config            -daRepeatCounter                    increment
            stream                       config            -framesize                          68
            stream                       config            -frameSizeMIN                       68
            stream                       config            -frameSizeMAX                       68
            stream                       config            -frameType                          "FF FF"
            stream                       config            -numDA                              $::cMAC_INCR_NUM
            stream                       config            -numSA                              $::cMAC_INCR_NUM
            stream                       config            -dma                                advance
            stream                       config            -asyncIntEnable                     true
            protocol                     setDefault        
            protocol                     config            -enable802dot1qTag                  vlanSingle
            
            vlan                         setDefault        
            vlan                         config            -vlanID                             100
            vlan                         set               $chassis $card $port
            
            if {[port isValidFeature $chassis $card $port $::portFeatureTableUdf]} { 
                tableUdf setDefault
                tableUdf clearColumns
                tableUdf set $chassis $card $port
            }
            
            
            if {[port isValidFeature $chassis $card $port $::portFeatureRandomFrameSizeWeightedPair]} { 
                weightedRandomFramesize setDefault
                weightedRandomFramesize set $chassis $card $port
            }
            
            stream                       set               $chassis $card $port $streamId
            incr                         streamId          
            #  Stream 2
            stream                       setDefault        
            stream                       config            -name                               $name
            stream                       config            -numFrames                          2
            stream                       config            -ifg                                2809919.99023
            stream                       config            -ifgMIN                             1920.0
            stream                       config            -ifgMAX                             2560.0
            stream                       config            -ibg                                2809919.99023
            stream                       config            -isg                                2809919.99023
            stream                       config            -percentPacketRate                  0.25
            stream                       config            -fpsRate                            355.113636364
            stream                       config            -bpsRate                            193181.818182
            stream                       config            -sa                                 $sourceAddress
            stream                       config            -saRepeatCounter                    increment
            stream                       config            -da                                 $destAddress
            stream                       config            -daRepeatCounter                    increment
            stream                       config            -framesize                          68
            stream                       config            -frameSizeMIN                       68
            stream                       config            -frameSizeMAX                       68
            stream                       config            -frameType                          "FF FF"
            stream                       config            -numDA                              $::cMAC_INCR_NUM
            stream                       config            -numSA                              $::cMAC_INCR_NUM
            stream                       config            -dma                                advance
            stream                       config            -asyncIntEnable                     true
            protocol                     setDefault        
            protocol                     config            -enable802dot1qTag                  vlanSingle
            
            vlan                         setDefault        
            vlan                         config            -vlanID                             200
            vlan                         set               $chassis $card $port
            
            if {[port isValidFeature $chassis $card $port $::portFeatureTableUdf]} { 
                tableUdf setDefault
                tableUdf clearColumns
                tableUdf set $chassis $card $port
            }
            
            
            if {[port isValidFeature $chassis $card $port $::portFeatureRandomFrameSizeWeightedPair]} { 
                weightedRandomFramesize setDefault
                weightedRandomFramesize set $chassis $card $port
            }
            
            stream                       set               $chassis $card $port $streamId
            incr                         streamId          
            #  Stream 3
            stream                       setDefault        
            stream                       config            -name                               $name
            stream                       config            -numFrames                          2
            stream                       config            -ifg                                2809919.99023
            stream                       config            -ifgMIN                             1920.0
            stream                       config            -ifgMAX                             2560.0
            stream                       config            -ibg                                2809919.99023
            stream                       config            -isg                                2809919.99023
            stream                       config            -percentPacketRate                  0.25
            stream                       config            -fpsRate                            355.113636364
            stream                       config            -bpsRate                            193181.818182
            stream                       config            -sa                                 $sourceAddress
            stream                       config            -saRepeatCounter                    increment
            stream                       config            -da                                 $destAddress
            stream                       config            -daRepeatCounter                    increment
            stream                       config            -framesize                          68
            stream                       config            -frameSizeMIN                       68
            stream                       config            -frameSizeMAX                       68
            stream                       config            -frameType                          "FF FF"
            stream                       config            -numDA                              $::cMAC_INCR_NUM
            stream                       config            -numSA                              $::cMAC_INCR_NUM
            stream                       config            -dma                                advance
            stream                       config            -asyncIntEnable                     true
            protocol                     setDefault        
            protocol                     config            -enable802dot1qTag                  vlanSingle
            
            vlan                         setDefault        
            vlan                         config            -vlanID                             300
            vlan                         set               $chassis $card $port
            
            if {[port isValidFeature $chassis $card $port $::portFeatureTableUdf]} { 
                tableUdf setDefault
                tableUdf clearColumns
                tableUdf set $chassis $card $port
            }
            
            
            if {[port isValidFeature $chassis $card $port $::portFeatureRandomFrameSizeWeightedPair]} { 
                weightedRandomFramesize setDefault
                weightedRandomFramesize set $chassis $card $port
            }
            
            stream                       set               $chassis $card $port $streamId
            incr                         streamId          
            #  Stream 4
            stream                       setDefault        
            stream                       config            -name                               $name
            stream                       config            -numFrames                          2
            stream                       config            -ifg                                2809919.99023
            stream                       config            -ifgMIN                             1920.0
            stream                       config            -ifgMAX                             2560.0
            stream                       config            -ibg                                2809919.99023
            stream                       config            -isg                                2809919.99023
            stream                       config            -percentPacketRate                  0.25
            stream                       config            -fpsRate                            355.113636364
            stream                       config            -bpsRate                            193181.818182
            stream                       config            -sa                                 $sourceAddress
            stream                       config            -saRepeatCounter                    increment
            stream                       config            -da                                 $destAddress
            stream                       config            -daRepeatCounter                    increment
            stream                       config            -framesize                          68
            stream                       config            -frameSizeMIN                       68
            stream                       config            -frameSizeMAX                       68
            stream                       config            -frameType                          "FF FF"
            stream                       config            -numDA                              $::cMAC_INCR_NUM
            stream                       config            -numSA                              $::cMAC_INCR_NUM
            stream                       config            -dma                                gotoFirst
            stream                       config            -asyncIntEnable                     true
            protocol                     setDefault        
            protocol                     config            -enable802dot1qTag                  vlanSingle
            
            vlan                         setDefault        
            vlan                         config            -vlanID                             400
            vlan                         set               $chassis $card $port
            
            if {[port isValidFeature $chassis $card $port $::portFeatureTableUdf]} { 
                tableUdf setDefault
                tableUdf clearColumns
                tableUdf set $chassis $card $port
            }
            
            
            if {[port isValidFeature $chassis $card $port $::portFeatureRandomFrameSizeWeightedPair]} { 
                weightedRandomFramesize setDefault
                weightedRandomFramesize set $chassis $card $port
            }
            
            stream                       set               $chassis $card $port $streamId
            incr                         streamId          
            ixWriteConfigToHardware      portList          -noProtocolServer
        }
    }
}

###############################################################################################
# This process will run the provocative test
###############################################################################################
proc RunProvactiveTest {convergenceState CONVERGENCESTATE linkAslot linkAport i} {
        
        set title2 "PROVOCATIVE ACTION FOR $CONVERGENCESTATE STATE ITERATION $i OF $::cITERATIONS"
        Mputs "\n" -c -s
        Mputs "\t$title2" -c -s 
		Mputs "\t[Underline [string length $title2] -]\n" -c -s
        
        ###### Set Tx Ports TXpath & Sniffer. Set Rx Ports idle & Sniffer ######
        set rxPortList ""
        set txPortList ""    
        foreach port $::cIXIAPORTLIST {
                regexp {(\d+) (\d+) (\d+) (\w+)} $port trash ch ca po name
                        if {($name == "Sniffer") || ($name == "TX_path")} {
                                set txPortList [ concat $txPortList \{$ch $ca $po\} ]   
                }
                if {($name == "Sniffer") || ($name == "idle")} {
                    set rxPortList [ concat $rxPortList \{$ch $ca $po\} ]
                }
        }
        ###### AdminState: state=1, in service. state=2, out of service #######
        if {$convergenceState == "converging"} {
            set state 2
            set stateDescription "out of service"
        } else {
            set state 1
            set stateDescription "in service"
        }
        global eSEQ_LOG eREP_LOG
        
        ###### Start the transmit ######
        Mputs "\tStarting transmit on Ixia ports $txPortList" -s -c

        if {[ixStartTransmit txPortList]} {
          Mputs "\tCould not start transmit on Ixia ports $txPortList"  -s -c
        } else {
          Mputs "\t- Complete -\n" -s -c
        }
           
        
        Mputs "\tWaiting 1 seconds to ensure all MAC learning is complete"  -s -c
        after 100        
        Mputs "\t- Complete -\n" -s -c
        
        ####### Logging in to generate a session id to set port admin status ######
        Mputs "\tLogging in to DUT"  -c -s
        if { [catch {14xxLogIn $::cDUT_HOSTNAME(1) } sessionId ] } {
                return -code error "Unable to establish contact with DUT"
        }
        Mputs "\t- Complete -\n" -s -c
        
        ###### Start the capture buffers ######
        Mputs "\tStarting capture buffers for Ixia ports $rxPortList "  -s -c
        if {[ixStartCapture rxPortList]} {
                Mputs "\tCould not start capture on $rxPortList"  -s -c
        } else {
          Mputs "\t- Complete -\n" -s -c
        }
        ###### Perform provocative action to change link A status ######

        Mputs "\tSetting admin status on $::cDUT_HOSTNAME(1) SDH port {$linkAslot-$linkAport} to: '$stateDescription'"  -s -c
        14xxSetPortAdminStatus $sessionId $::cDUT_HOSTNAME(1) $linkAslot $linkAport $state SDHPort
        Mputs "\t- Complete -\n" -s -c
        
		if {$convergenceState == "re-converging"} {
			Mputs "\t- Waiting 1 second -\n" -s -c
			after 1000
		}
        Mputs "\tLogging out of DUT"  -c -s
        14xxLogOut $sessionId $::cDUT_HOSTNAME(1)
        Mputs "\t- Complete -\n" -c -s
        
        Mputs "\tWaiting 1 second"  -s -c
        after 1000
        Mputs "\t- Complete -\n" -s -c
        
        Mputs "\tStop the capture buffers for Ixia ports $rxPortList "  -s -c
        if {[ixStopCapture rxPortList]} {
          Mputs "\tCould not stop capture on Ixia ports $rxPortList"  -s -c
        }
        Mputs "\t- Complete -\n" -s -c
        
        ###### Stop the transmit ######
        Mputs "\tStop Ixia transmit ports"  -s -c
        Mputs "\t- Complete -\n\n\n" -s -c
        if {[ixStopTransmit txPortList]} {
          Mputs "\tCould not stop transmit on Ixia ports $txPortList"  -s -c
        }
        return 1
}
###############################################################################################
proc findT2 {ch ca po iterationNum results1 convState} {
    Mputs "\tFINDING A TCN-BPDU AND PRE TCN-BPDU FRAMES" -s -c
    Mputs "\t------------------------------------------\n" -s -c
    upvar 1 $results1 resultsArray
    set timeList 0
    #set timeList2() 0 
    
    ###### Retrieve frames from the capture buffer #######
    capture get $ch $ca $po
    set numframes [capture cget -nPackets]
    captureBuffer get $ch $ca $po 1 $numframes
    Mputs "\tFrames in capture buffer: $numframes" -s -c
    
    ####### Retrieve the BPDU with a TCN  #######################
    
    for {set frm 1} {$frm <= $numframes} {incr frm} {
        captureBuffer getframe $frm
        set framedata [captureBuffer cget -frame]
        set tcnFlag 0
        regexp {42 42 03 00 00 03 02 (\w+)(\w+)} $framedata trash tcn2 tcnFlag
        switch -- $tcnFlag {
                "D" -
                "F" {
                set resultsArray(iteration$iterationNum,T2$convState) [captureBuffer cget -timestamp]
                set timeList "t1_[captureBuffer cget -timestamp]_$frm"
                #set timeList2($convState) "t1_[captureBuffer cget -timestamp]_$frm"
                
                Mputs "\t[format %-26s "TCN-BPDU Frame Data:"][format %-8s $trash]" -s -c
                break
                }
        }
    }
    if {$timeList == 0} {
        set resultsArray(iteration$iterationNum,T1$convState)  0
        set resultsArray(iteration$iterationNum,T2$convState)  0
        set resultsArray(iteration$iterationNum,T3$convState)  0
        set resultsArray(iteration$iterationNum,gap$convState) 0
                
        Mputs "\tNo TCN-BPDUs were found for $convState, there must be an error in the runnning of the test\n" -s -c
        return 0
    } else {
    
        if {[catch {findT1 $timeList resultsArray $iterationNum $convState}]} {
            global errorInfo
            Mputs $errorInfo -c -s
            return 0
        }
    }
}
###################################################################
# Find Total Traffic loss including spikes
###################################################################

proc findT1 {timeList results iterationNum convState} {
        
        ## Set a maximum of 5 times to find a result
        for {set resultCnt 1} {$resultCnt <= 5} {incr resultCnt} {

                set gap 0
                set convergenceTime 0
                upvar 1 $results resultsArray
                set resultsArray(iteration$iterationNum,gap$convState) 0
                
                regexp {t1_(\d+)_(\d+)} $timeList trash TCNframeTime TCNframeNo
                set TCNframeTime [mpexpr ($TCNframeTime/(1000000000000*0.1)*0.1)]
                set resultsArray(iteration$iterationNum,T2$convState) $TCNframeTime
                
                set preTCNFrame [mpexpr $TCNframeNo -1]
                captureBuffer getframe $preTCNFrame
                set preTCNFrameTime [captureBuffer cget -timestamp]
                set preTCNFrameTime [mpexpr ($preTCNFrameTime/(1000000000000*0.1)*0.1)]
                set resultsArray(iteration$iterationNum,T1$convState) $preTCNFrameTime
                
                set convergenceTime [mpexpr $TCNframeTime - $preTCNFrameTime]
                ##set convergenceTime [mpexpr $convergenceTime*1000000]
                set resultsArray(iteration$iterationNum,gap$convState) $convergenceTime
                      
                Mputs "\t[format %-26s "TCN-BPDU Frame No:"][format %-22s $TCNframeNo]" -s -c
                Mputs "\t[format %-26s "TCN-BPDU time:"][format %-22s "$TCNframeTime sec"]" -s -c
                Mputs "\t[format %-26s "Previous Frame No:"][format %-22s $preTCNFrame]" -s -c
                Mputs "\t[format %-26s "Frame time:"][format %-22s "$preTCNFrameTime sec"]" -s -c
                Mputs "\t[format %-26s "Convergence time:"][format %-30s "$convergenceTime sec"]\n" -s -c
                #Mputs "\tConvergence time: $convergenceTime micro-sec\n" -s -c
            
                set thisFrameNoCounter -1
                set nextFrameNoCounter 0
                set preTCNcount 0
                set var 1
                set IFG 100 ;# 100 micro-seconds
        
                while {$var==1} {
                    #### Retrieve frames with time stamps ##########
                    incr thisFrameNoCounter 1
                    incr nextFrameNoCounter 1
                            
                    set thisFrameNo [expr $TCNframeNo - $thisFrameNoCounter]
                    captureBuffer getframe $thisFrameNo
                    set thisFrameTime [captureBuffer cget -timestamp]
                    set thisFrameTime [mpexpr ($thisFrameTime/(1000000000000*0.1)*0.1)]
                    
                    set nextFrameNo [expr $TCNframeNo - $nextFrameNoCounter]
                    captureBuffer getframe $nextFrameNo
                    set nextFrameTime [captureBuffer cget -timestamp]
                    set nextFrameTime [mpexpr ($nextFrameTime/(1000000000000*0.1)*0.1)]  
                    
                    set frameGap [mpexpr $thisFrameTime - $nextFrameTime]
                    set frameGap [mpexpr $frameGap*1000000]
                    if {$frameGap >=$IFG} {
                        set var 0
                    }
                    ### LOOP IF THE GAP FOUND IS JUST AN ORDINARY IFG, MAXIMUM REPITITION =500 ###
                    if {$frameGap <$IFG} {
                        set var 1
                        incr preTCNcount 
                        if {$preTCNcount==10} {
                            set var 0
                            #Mputs "\tPre TCN frame count = $preTCNcount" -s -c
                        }
                    }
                }
                
                ###### ROUTINE TO CHECK FOR SPIKES PRIOR TO THE TCN-BPDU #####
                if {$::cEXTRADISPLAY == 1} {
                        Mputs "\tPre TCN-BPDU events:" -s -c
                }
                set thisFrameCount 0
                set nextFrameCount 1
                set spikeCount 0
        
                for {set i 1} {$i <=2} {incr i} {
                        set var 1
                        set preTCNcount 0
                        
                        while {$var==1} {
                                #### Retrieve frames with time stamps ##########
                                incr thisFrameCount 1
                                incr nextFrameCount 1
                                            
                                set thisFrameNo [expr $TCNframeNo - $thisFrameCount]
                                captureBuffer getframe $thisFrameNo
                                set thisFrameTime [captureBuffer cget -timestamp]
                                set thisFrameTime [mpexpr ($thisFrameTime/(1000000000000*0.1)*0.1)]
                                if {$::cEXTRADISPLAY == 1} {
                                        
                                        Mputs "\tFrame Number: $thisFrameNo ,time: $thisFrameTime sec" -s -c
                                }
                                set nextFrameNo [expr $TCNframeNo - $nextFrameCount]
                                captureBuffer getframe $nextFrameNo
                                set resultsArray(iteration$iterationNum,T1$convState) [captureBuffer cget -timestamp]
                                set nextFrameTime [captureBuffer cget -timestamp]
                                set nextFrameTime [mpexpr ($nextFrameTime/(1000000000000*0.1)*0.1)]
                                
                                set frameGap [mpexpr $thisFrameTime - $nextFrameTime]
                                set frameGap [mpexpr $frameGap*1000000]
                                if {$::cEXTRADISPLAY == 1} {
                                        
                                        Mputs "\tFrame Number: $nextFrameNo ,time: $nextFrameTime sec\tInter-frame gap: $frameGap micro-sec\n" -s -c
                                }                
                                if {$frameGap >=$IFG} {
                                        set var 0
                                        set convergenceTime [mpexpr $TCNframeTime - $nextFrameTime]
                                        set resultsArray(iteration$iterationNum,T1$convState) $nextFrameTime
                                        set resultsArray(iteration$iterationNum,gap$convState) $convergenceTime
                                        Mputs "\t##### Re-calculated convergence time: $convergenceTime sec #####\n" -s -c
                                        incr spikeCount
                                }
                                ### LOOP IF THE GAP FOUND IS JUST AN ORDINARY IFG, MAXIMUM REPITITION =10 ###
                                if {$frameGap <$IFG} {
                                        #set var 1
                                        incr preTCNcount 1
                                        if {$preTCNcount==3} {
                                            set var 0
                                        }
                                }
                        }
                }
                if {$convergenceTime == 0} {
                        set resultsArray(iteration$iterationNum,gap$convState) 0   
                        return -code error -errorinfo "\tError - No GAP was found, there must be an error in the runnning of the test"     
                } else {
                        Mputs "\tResults were after $resultCnt test attempt(s)" -c -s
                        set resultCnt 6
                }
                Mputs "\tPre BPDU-spike frame count: $spikeCount\n\n\n" -s -c
        }
}
###################################################################
# Find MAC Learning Time (MACLT)
###################################################################

proc findT3 {ch ca po iterationNum results2 convState} {
    Mputs "\tDETERMINING MAC LEARNING TIME" -s -c
    Mputs "\t-----------------------------\n" -s -c
    upvar 1 $results2 resultsArray
    set T3 0
    
    ###### Retrieve frames from the capture buffer #######
    capture get $ch $ca $po
    set numframes [capture cget -nPackets]
    #Mputs "\tNumber of frames in capture buffer: $numframes" -s -c
    Mputs "\t[format %-26s "Frames in capture buffer:"][format %-30s $numframes]\n" -s -c
    captureBuffer get $ch $ca $po 1 $numframes
    
    ## FIND THE FIRST FRAME
    
    
    for {set frameNo 1} {$frameNo <= $numframes} {incr frameNo} {
        
        set BPDU "01 80 C2" ; set time1 0
        ## Get the first/next frame 
        captureBuffer getframe $frameNo
        set framedata [captureBuffer cget -frame]
        
        ## Find if the frame contains a BPDU
        regexp {01 80 C2} $framedata BPDU
        ##Mputs "BPDU = $BPDU" -c -s       
        if {$BPDU != "01 80 C2"} {
                captureBuffer getframe $frameNo
                set time1 [captureBuffer cget -timestamp]
                set time1 [mpexpr ($time1/(1000000000000*0.1)*0.1)]
                #Mputs "\tFrame number: $frameNo, time 1: $time1 sec" -s -c
                Mputs "\t[format %-26s "Frame number:"][format %-8s $frameNo]" -s -c
                Mputs "\t[format %-26s "Frame time"][format %-30s "$time1 sec"]\n" -s -c
                ##set numframes [expr $numframes + 1]
                break
        }
    }
    ## FIND THE LAST FRAME
    for {set frameNo $numframes} {$frameNo >= 1} {incr frameNo -1} {
        
        set BPDU "01 80 C2" ; set time2 0
        ## Get the last/next previous frame
        captureBuffer getframe $frameNo
        set framedata [captureBuffer cget -frame]
        
        ## Find if the frame contains a BPDU
        regexp {01 80 C2} $framedata BPDU
        if {$BPDU != "01 80 C2"} {
                captureBuffer getframe $frameNo
                set time2 [captureBuffer cget -timestamp]
                set time2 [mpexpr ($time2/(1000000000000*0.1)*0.1)]
                #Mputs "\tFrame number: $frameNo, time 2: $time2 sec" -s -c
                Mputs "\t[format %-26s "Frame number:"][format %-8s $frameNo]" -s -c
                Mputs "\t[format %-26s "Frame time"][format %-30s "$time2 sec"]\n" -s -c
                ##set numframes [expr $numframes - 1]
                break
        }
    }
    ##### Then calculate MAC Learning Time ###########
    set resultsArray(iteration$iterationNum,T3$convState) 0
    set T3 [mpexpr ($time2 - $time1) * 1000]
    if {$T3 == 0} {
        Mputs "\tMAC learning = 0, therefore MAC learning could not be calculated at this time\n" -s -c
    }
    Mputs "\t[format %-26s "MAC learning time equals:"][format %-30s "$T3 milli-sec\n\n"]\n" -s -c
    set resultsArray(iteration$iterationNum,T3$convState) [mpexpr $time2 - $time1]

}
#########################################################################
# Takes the results array, calculates and outputs the results to the log
#########################################################################

proc ResultsCheckerandLogOutput {results iterationNum Timelist validatnRstList} {
 
    upvar 1 $results resultsArray
    
    set convMaxT3 0
    set convMinT3 10000000000
    set convMaxGap 0
    set convMinGap 10000000000
    set convTotalT3 0
    set convTotalGap 0
    set reconvMaxT3 0
    set reconvMinT3 10000000000
    set reconvMaxGap 0
    set reconvMinGap 10000000000
    set reconvTotalT3 0
    set reconvTotalGap 0
    
    Mputs "\tTABLE 1: NETWORK VALIDATION RESULTS" -c -s -r
    Mputs "\t-----------------------------------" -c -s -r
    set title "[format %-15s ITERATION][format %-20s "CONVERGENCE STATE"][format %-20s P/F]"
    Mputs "\t$title" -c -s -r
    Mputs "\t---------------------------------------" -c -s -r
    ##Mputs "\t[Underline [expr [string length $title]] -]" -c -s -r
    foreach {iter convStat pfResult} $validatnRstList {
        Mputs "\t[format %-15s $iter][format %-20s $convStat][format %-20s $pfResult]" -c -s -r
    }
    
######### Output Table 1 header #################
    Mputs "\n\n\n\tTABLE 2: CONVERGENCE TEST RESULTS" -c -s -r
    Mputs "\t---------------------------------" -c -s -r
    set title "[format %-22s "t0 (SEC)"][format %-22s "t1 (SEC)"][format %-22s "CONVERGENCE (SEC)"][format %-12s P/F][format %-22s "MAC LEARNING (SEC)"][format %-12s P/F]"
    Mputs "\t$title" -c -s -r
    Mputs "\t[Underline [expr [string length $title] - 8] -]" -c -s -r
    
    
######### Compile Table 3 #################
    for {set x 1} {$x <= $iterationNum} {incr x} {
        if {$convMaxT3 < $resultsArray(iteration$x,T3converging)} {
            set convMaxT3 $resultsArray(iteration$x,T3converging)
        }
        if {$convMinT3 > $resultsArray(iteration$x,T3converging)} {
            set convMinT3 $resultsArray(iteration$x,T3converging)
        }
        if {$convMaxGap < $resultsArray(iteration$x,gapconverging)} {
            set convMaxGap $resultsArray(iteration$x,gapconverging)
        }
        if {$convMinGap > $resultsArray(iteration$x,gapconverging)} {
            set convMinGap $resultsArray(iteration$x,gapconverging)
        }
        set convTotalT3 [mpexpr $resultsArray(iteration$x,T3converging) + $convTotalT3]
        set convTotalGap [mpexpr $resultsArray(iteration$x,gapconverging) + $convTotalGap]
        
        #######  Determines Pass or Fail state
        
        if {$resultsArray(iteration$x,T3converging)>$::cCONVERGENCE_MAX_T3_TIME} {
            set convT3PassOrFail "FAIL"
        } elseif {$resultsArray(iteration$x,T3converging) == 0} {
            set convT3PassOrFail "N/A"
        } else {
            set convT3PassOrFail "PASS"
        }
        if {$resultsArray(iteration$x,gapconverging)>$::cCONVERGENCE_MAX_GAP_TIME} {
            set convGapPassOrFail "FAIL"
        } elseif {$resultsArray(iteration$x,gapconverging) == 0} {
            set convGapPassOrFail "N/A"
        } else {
            set convGapPassOrFail "PASS"
        }
######### Output Table 1 ########################
        set resultsArray(iteration$x,T1converging) [mpexpr ($resultsArray(iteration$x,T1converging)/(1000000000000*0.1)*0.1)]
        #set resultsArray(iteration$x,T2converging) [mpexpr ($resultsArray(iteration$x,T2converging)/(1000000000000*0.1)*0.1)]
        
        Mputs "\t[format %-22s $resultsArray(iteration$x,T1converging)][format %-22s $resultsArray(iteration$x,T2converging)][format %-22s $resultsArray(iteration$x,gapconverging)][format %-12s $convGapPassOrFail][format %-22s $resultsArray(iteration$x,T3converging)][format %-12s $convT3PassOrFail]" -c -s -r
    }
    
    ######### Output Table 2 header #################
    Mputs "\n\n\n\tTABLE 3: RE-CONVERGENCE TEST RESULTS" -c -s -r
    Mputs "\t------------------------------------" -c -s -r
    set title "[format %-22s "t0 (SEC)"][format %-22s "t1 (SEC)"][format %-22s "RECONVERGENCE (SEC)"][format %-12s P/F][format %-22s "MAC LEARNING (SEC)"][format %-12s P/F]"
    Mputs "\t$title" -c -s -r
    Mputs "\t[Underline [expr [string length $title] - 8] -]" -c -s -r
    
    for {set x 1} {$x <= $iterationNum} {incr x} {
                
        ########## Compile Table 3 #################        
        if {$reconvMaxT3 < $resultsArray(iteration$x,T3re-converging)} {
            set reconvMaxT3 $resultsArray(iteration$x,T3re-converging)
        }
        if {$reconvMinT3 > $resultsArray(iteration$x,T3re-converging)} {
            set reconvMinT3 $resultsArray(iteration$x,T3re-converging)
        }
        if {$reconvMaxGap < $resultsArray(iteration$x,gapre-converging)} {
            set reconvMaxGap $resultsArray(iteration$x,gapre-converging)
        }
        if {$reconvMinGap > $resultsArray(iteration$x,gapre-converging)} {
            set reconvMinGap $resultsArray(iteration$x,gapre-converging)
        }
        
        
        
        #######Maintains a running total of the gap and T3 time
        
        set reconvTotalT3 [mpexpr $resultsArray(iteration$x,T3re-converging) + $reconvTotalT3]
        set reconvTotalGap [mpexpr $resultsArray(iteration$x,gapre-converging) + $reconvTotalGap]
        
        #######Establishes Pass or Fail state
        if {$resultsArray(iteration$x,T3re-converging)>$::cCONVERGENCE_MAX_T3_TIME} {
            set reconvT3PassOrFail "FAIL"
        } elseif {$resultsArray(iteration$x,T3re-converging) == 0} {
            set reconvT3PassOrFail "N/A"
        } else {
            set reconvT3PassOrFail "PASS"
        }
        
        if {$resultsArray(iteration$x,gapre-converging)>$::cCONVERGENCE_MAX_GAP_TIME} {
            set reconvGapPassOrFail "FAIL"
        } elseif {$resultsArray(iteration$x,gapre-converging) == 0} {
            set reconvGapPassOrFail "N/A"
        } else {
            set reconvGapPassOrFail "PASS"
        }
        
        ########## Output Table 2 #################
        set resultsArray(iteration$x,T1re-converging) [mpexpr ($resultsArray(iteration$x,T1re-converging)/(1000000000000*0.1)*0.1)]
        ##set resultsArray(iteration$x,T2re-converging) [mpexpr ($resultsArray(iteration$x,T2re-converging)/(1000000000000*0.1)*0.1)]
        Mputs "\t[format %-22s $resultsArray(iteration$x,T1re-converging)][format %-22s $resultsArray(iteration$x,T2re-converging)][format %-22s $resultsArray(iteration$x,gapre-converging)][format %-12s $reconvGapPassOrFail][format %-22s $resultsArray(iteration$x,T3re-converging)][format %-12s $reconvT3PassOrFail]" -c -s -r
    }
    
    ######## Calculates Means of Gap and T3 times
    set convMeanT3 [mpexpr $convTotalT3 / $iterationNum]
    set convMeanGap [mpexpr $convTotalGap / $iterationNum]
    set reconvMeanT3 [mpexpr $reconvTotalT3 / $iterationNum]
    set reconvMeanGap [mpexpr $reconvTotalGap / $iterationNum]
 
    ######### Output Table 3 header #################
    Mputs "\n\n\n\tTABLE 4: SUMMARY OF CONVERGENCE TEST RESULTS" -c -s -r
    Mputs "\t--------------------------------------------" -c -s -r
    
    set titleTable3 "[format %-23s EVENT][format %20s "MIN (SEC)"][format %20s "MEAN (SEC)"][format %20s "MAX (SEC)"]"
    Mputs "\t$titleTable3" -c -s -r
    Mputs "\t[Underline [string length $titleTable3] -]" -c -s -r
    
    Mputs "\t[format %-23s "Convergence Time"][format %20s $convMinGap][format %20s $convMeanGap][format %20s $convMaxGap]" -c -s -r
    Mputs "\t[format %-23s "Reconvergence Time"][format %20s $reconvMinGap][format %20s $reconvMeanGap][format %20s $reconvMaxGap]" -c -s -r
    Mputs "\t[format %-23s "MAC Learning (conv)"][format %20s $convMinT3][format %20s $convMeanT3][format %20s $convMaxT3]" -c -s -r
    Mputs "\t[format %-23s "MAC Learning (reconv)"][format %20s $reconvMinT3][format %20s $reconvMeanT3][format %20s $reconvMaxT3]" -c -s -r
    
    Mputs "\n\n\tNote: Pass criteria for convergence and re-converenge set to [mpexpr $::cCONVERGENCE_MAX_GAP_TIME * 1000] milli-sec" -c -s -r
    
    
}
