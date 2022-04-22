//START_SWREG_TABLE axistream_in 
`IOB_SWREG_W(AXISTREAMIN_NEXT, 1, 0) //Go to next FIFO output
`IOB_SWREG_R(AXISTREAMIN_OUT, 8, 0) //Get FIFO output
`IOB_SWREG_R(AXISTREAMIN_TLAST, 1, 0) //Current FIFO output is last from stream
`IOB_SWREG_R(AXISTREAMIN_EMPTY, 1, 0) //Return if FIFO is empty
