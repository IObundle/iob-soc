#######################################################
#                                                     #
# VERSAT: Encounter Place & Route Script              #
#
#######################################################

#lef libraries
set lib_path {/opt/ic_tools/pdk/faraday/umc130/LL/fsc0l_d/2009Q2v3.0/GENERIC_CORE/BackEnd/lef}

#libraries
set bootrom_lef [glob ../memory/bootrom/*.lef]
set bootram_lef [glob ../memory/bootram/*.lef]

set LEFLIB [list $lib_path/header8m2t_V55.lef $lib_path/fsc0l_d_generic_core.lef $lib_path/FSC0L_D_GENERIC_CORE_ANT_V55.6m2t.lef $bootrom_lef $bootram_lef]

set init_gnd_net GND
set init_lef_file $LEFLIB
set init_verilog ../synth/system_synth.v
set init_mmmc_file Default.view
set init_pwr_net VDD

init_design

setDesignMode -process 130

#floorPlan -site core -r 0.9987802253 0.698911 25.0 25.0 25.0 25.0
floorPlan -site core -r 2.0 2.0 25.0 25.0 25.0 25.0
uiSetTool select
getIoFlowFlag

globalNetConnect GND -type tielo -inst *
globalNetConnect VDD -type tiehi -inst *

addRing -center 1 -stacked_via_top_layer metal8 -around cluster -jog_distance 0.4 -threshold 0.4 -nets {VDD GND} -stacked_via_bottom_layer metal1 -layer {bottom metal1 top metal1 right metal2 left metal2} -width 10 -spacing 1 -offset 0.4

set sprCreateIeStripeNets {}
set sprCreateIeStripeLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeSpacing 2.0
set sprCreateIeStripeThreshold 1.0

addStripe -block_ring_top_layer_limit metal3 -max_same_layer_jog_length 0.8 -padcore_ring_bottom_layer_limit metal1 -number_of_sets 6 -stacked_via_top_layer metal8 -padcore_ring_top_layer_limit metal3 -spacing 1 -xleft_offset 20 -merge_stripes_value 0.4 -layer metal2 -block_ring_bottom_layer_limit metal1 -width 8 -nets {GND VDD} -stacked_via_bottom_layer metal1 -break_stripes_at_block_rings 1

sroute -connect {} -layerChangeRange { metal1 metal8 } -blockPinTarget { nearestTarget } -checkAlignedSecondaryPin 1 -allowJogging 1 -crossoverViaBottomLayer metal1 -allowLayerChange 1 -targetViaTopLayer metal8 -crossoverViaTopLayer metal8 -targetViaBottomLayer metal1 -nets { GND VDD }

setPlaceMode -reset
setPlaceMode -congEffort auto -timingDriven 1 -modulePlan 1 -clkGateAware 1 -powerDriven 0 -ignoreScan 1 -reorderScan 0 -ignoreSpare 1 -placeIOPins 1 -moduleAwareSpare 0 -checkPinLayerForAccess {  1 } -preserveRouting 0 -rmAffectedRouting 0 -checkRoute 0 -swapEEQ 0
setPlaceMode -fp false

placeDesign -prePlaceOpt

trialRoute -maxRouteLayer 8

timeDesign -preCTS

setOptMode -fixCap true -fixTran true -fixFanoutLoad false
optDesign -preCTS

setCTSMode -engine ck
createClockTreeSpec -bufferList {BUFCKHHD BUFCKIHD BUFCKJHD BUFCKKHD BUFCKLHD BUFCKMHD BUFCKNHD BUFCKQHD DELAKHD DELBKHD DELCKHD INVCKDHD INVCKGHD INVCKHHD INVCKIHD INVCKJHD INVCKKHD INVCKLHD INVCKMHD INVCKNHD INVCKQHD} -file Clock.ctstch

clockDesign -specFile Clock.ctstch -outDir clock_report -fixedInstBeforeCTS

setAnalysisMode -analysisType onChipVariation
setAnalysisMode -cppr both

update_io_latency

timeDesign -postCTS

optDesign -postCTS

redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null

timeDesign -postCTS -hold -pathReports -slackReports -numPaths 50 -prefix system_postCTS -outDir timingReports

setOptMode -fixCap true -fixTran true -fixFanoutLoad false

optDesign -postCTS -hold

timeDesign -postCTS

optDesign -postCTS -drv

##########################################
setNanoRouteMode -quiet -routeWithTimingDriven 1
setNanoRouteMode -quiet -routeWithSiDriven 1
setNanoRouteMode -quiet -routeTopRoutingLayer default
setNanoRouteMode -quiet -routeBottomRoutingLayer default
setNanoRouteMode -quiet -drouteEndIteration default
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -quiet -routeWithSiDriven true
routeDesign -globalDetail
##########################################


setExtractRCMode -engine postRoute
setExtractRCMode -effortLevel low

timeDesign -postRoute
timeDesign -postRoute -hold

setDelayCalMode -engine default -SIAware true

optDesign -postRoute
optDesign -postRoute -hold

setDelayCalMode -SIAware false
setDelayCalMode -engine signalStorm
timeDesign -signoff -si
timeDesign -signoff -si -hold

write_sdf system.sdf
reportGateCount
saveDesign system_par.enc
saveNetlist system_par.v
