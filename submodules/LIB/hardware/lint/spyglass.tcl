#grab TOP from environment variable NAME in tcl
set TOP $env(NAME)
set CSR_IF $env(CSR_IF)

puts "TOP: $TOP"
puts "CSR_IF: $CSR_IF"

new_project spyglass -projectwdir .

##Data Import Section

read_file -type sourcelist $TOP\_files.list

#delete file if it exsists
if {[file exists spyglass.sgdc]} {
    file delete spyglass.sgdc
}
set fp [open spyglass.sgdc a]
puts $fp "current_design $TOP"
puts $fp "sdcschema -type ../syn/umc130/$TOP\_dev.sdc ../syn/src/$TOP.sdc ../syn/src/$TOP\_$CSR_IF.sdc ../syn/$TOP\_tool.sdc"

read_file -type sgdc spyglass.sgdc

##Common Options Section

#set_option projectwdir .
set_option language_mode mixed
#set_option designread_enable_synthesis no
#set_option designread_disable_flatten no
set_option enableV05 yes
set_option top $TOP
set_option incdir { . ../src }
#set_option active_methodology $SPYGLASS_HOME/GuideWare/latest/block/rtl_handoff
set_option pragma { synopsys synthesis }
#set_option sdc2sgdc yes
set_option enableSV no


##Goal Setup Section

current_methodology $SPYGLASS_HOME/GuideWare/latest/block/rtl_handoff

current_goal lint/lint_rtl -top $TOP

read_file -type awl spyglass_waiver.awl

set_goal_option default_waiver_file spyglass_waiver.awl

set_goal_option addrules { ImproperRangeIndex-ML NonResetFSM-ML SameControlNDataNet-ML NoConstSourceInAlways-ML NonConstShift-ML FSMNonConstDefault-ML UndrivenInTerm-ML PartConnPort-ML HangingInstInput-ML UseLogic-ML PortType PortTypeMismatch-ML CheckModulesWithoutPorts-ML EnumStateDecl-ML TwoStateData-ML NoRealFunc-ML FlopFeedbackRace-ML MultiAssign-ML MixedResetEdges-ML SetBeforeRead-ML ConstWithoutValue-ML SigAssignX-ML SigAssignZ-ML NoOpen-ML NullOthers-ML NullPort-ML OneModule-ML NoInoutPort-ML PortConnToInout-ML NoWidthInBasedNum-ML NoSigCaseX-ML NoDisableInTask-ML NoDisableInFunc-ML BitRangeUsedParam-ML UnpackedStructUsed-ML CheckLocalParam-ML NonReusableParametricModule-ML ParamValueOverride-ML ParamOverrideMismatch-ML ParamWidthMismatch-ML DetectParamTruncate-ML UnInitParam-ML ChkSensExprPar-ML NoExprInPort-ML UseBusWidth-ML BitOrder-ML SigAsgnDelay-ML CondSigAsgnDelay-ML NoAssignX-ML RegInput-ML CAPA-ML ComplexExpr-ML AsgnToOneBit-ML UnloadedOutTerm-ML UndrivenOutPort-ML UnloadedInPort-ML UnloadedNet-ML ResetFlop-ML SignedUnsignedExpr-ML DuplicateCaseLabel-ML DisallowXInCaseZ-ML UndrivenNUnloaded-ML UndrivenNet-ML DisallowCaseZ-ML DisallowCaseX-ML DiffTimescaleUsed-ML SelfAssignment-ML UseParamWidthInOverriding-ML }

set_goal_option addrules { BufClock IntReset NoGates NoTopGates IncompleteType DefaultState UseDefine ModConst RegOutputs NoDup ExprParen NoTopLogic InferLatch LatchGatedClock GatedClock OneStmtLine FlopDataConstant FlopClockConstant FlopSRConst SigVarInit OnePortLine WRN_48 sim_race01 sim_race02 NotReqSens LoopBound CaseOverIf UseDefine badimplicitSM1 badimplicitSM4 IntGeneric SynthIfStmt ForLoopWait BothPhase ResFunction PreDefAttr LatchEnableConstant AllocExpr LinkagePort NoTimeOut ArrayEnumIndex MultipleWait UseMuxBusses UserDefAttr ClockStyle LogNMux FloatingInputs ArrayIndex }

set_goal_option addrules { STARC-1.3.1.6 STARC-1.3.2.1 STARC-1.4.3.4 STARC-2.1.4.6 STARC-2.8.1.4 STARC-2.8.3.5 STARC-2.8.4.1a STARC-2.9.2.1 STARC-2.1.3.4 STARC-2.11.3.1 STARC-2.11.1.3 STARC-3.2.2.1 STARC-3.1.3.1 STARC-3.5.6.3a STARC-2.1.2.6 STARC-2.2.1.3 STARC-2.2.3.2 STARC-2.2.3.3 STARC-2.10.6.1 STARC-2.10.1.5b STARC-3.1.3.4a STARC-1.1.1.1 STARC-3.2.3.1 STARC-3.1.3.4b STARC-1.1.1.3a STARC-3.1.4.5 STARC-2.7.3.4 STARC-3.2.2.2 STARC-1.6.2.2 STARC-2.2.3.2 STARC-2.3.1.4 STARC-2.3.2.2 STARC-2.3.6.1 STARC-2.8.1.5 STARC-2.3.4.3 STARC-2.8.5.2 }

set_goal_option addrules { STARC05-3.3.6.2 STARC05-2.1.4.5 STARC05-2.6.1.2 STARC05-1.3.1.3 STARC05-2.11.1.2 STARC05-2.1.3.1 STARC05-3.2.3.2 STARC05-2.1.2.2a STARC05-2.1.2.5 STARC05-1.1.1.1 STARC05-1.1.1.5 STARC05-2.2.1.2 STARC05-1.1.4.2a STARC05-3.2.3.1 STARC05-3.1.3.4b STARC05-1.1.1.3 STARC05-3.5.6.2 STARC05-2.1.5.1 STARC05-2.10.3.2b STARC05-2.10.4.6 STARC05-2.3.2.2 STARC05-2.3.2.1 STARC05-2.1.3.2 STARC05-2.1.1.2 STARC05-2.1.3.5 STARC05-2.4.1.4 STARC05-2.5.1.9 STARC05-2.3.1.7a STARC05-2.8.3.3 STARC05-2.3.1.2b STARC05-2.5.1.4 STARC05-2.3.4.2 STARC05-1.3.1.7 }

set_goal_option addrules { W17 W18 W182c W182g W182h W182k W182n W391 W528 W156 W701 W503 W122 W190 W245 W259 W392 W438 W43 W34 W280 W287a W287b W162 W328 W164a W164b W428L W345 W429L W416 W116 W443 W238 W395 W415a W424 W425 W456 W468 W489 W480 W502 W575 W422 W146 W423 W110a W430 W494 W494a W250 W527 W444 W159 W397 W391 W191 W192 W213 W253 W491 W241 W450L W481a W210 W464 W427 W551 W294 W254 W226 W143 W154 }

## CAST Naming Convention
set_goal_option addrules { InstanceNameRequired-ML InterfaceNameConflicts-ML FSMNextStateName-ML ParamName ConstName RegOutName ClkHierName NameLength PortName ProcName STARC-1.1.1.2 STARC-1.1.2.1a STARC05-1.1.2.1a STARC-1.1.2.1b STARC05-1.1.1.7 STARC05-1.1.5.2a STARC05-1.1.5.2b }

## Ignore Rules
set_goal_option ignorerules { NoParamMultConcat-ML NonBlockingCounters-ML ValueSizeOverFlow-ML W110a UnInitTopDuParam-ML STARC-1.1.1.8 STARC05-3.1.3.3v STARC-3.1.3.3 RegInName HardConst STARC-3.5.3.1 }

set_parameter line_length_max 100
set_parameter clock_string "/clk_/i or /clk/i"
set_parameter check_task_ports -default
set_parameter snake_length 15
set_parameter name_max_length 40
set_parameter check_next_state nxt
set_parameter starc2005_negative_str _X,_N,N
set_parameter report_all_connections yes
set_parameter depth_ml 2
set_parameter ignore_comb_logic yes
set_parameter buf_count 1
set_parameter starc2005_max_mod_ent_length 40
set_parameter starc_max_mod_ent_length 40
#set_parameter starc_inst_name /^U_/
set_parameter starc2005_reset_string "/rst_i/ or /reset_i/ or /resetn_i/ or /rstn_i"
set_parameter ignore_fsm_counter yes
set_parameter starc_max_inst_length 40
set_parameter no_strict -default
set_parameter param_string {/^[A-Z][A-Z0-9_]*$/ and /^.{1,100}$/ and not /__/}
set_parameter constname {/^[A-Z][A-Z0-9_]*$/ and /^.{1,100}$/ and not /__/}
set_parameter paramname {/^[A-Z][A-Z0-9_]*$/ and /^.{1,100}$/ and not /__/}
set_parameter portname {/^[a-z][a-z0-9_]*$/ and /^*$/ and /^.{1,100}$/ and not /__/}
set_parameter regoutname /^(.*)_o/
set_parameter nesting_level 5
set_parameter num_max_bit_changes 3
set_parameter OperatorCount 12

run_goal

save_project
close_project

exit -force

