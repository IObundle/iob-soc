//START_SWREG_TABLE axistream_in 
`IOB_SWREG_R(AXISTREAMIN_OUT, 9, 0) //Get next FIFO output, most significant bit is the TLAST signal (identifies if this byte is the last of the frame)
`IOB_SWREG_R(AXISTREAMIN_EMPTY, 1, 0) //Return if FIFO is empty
