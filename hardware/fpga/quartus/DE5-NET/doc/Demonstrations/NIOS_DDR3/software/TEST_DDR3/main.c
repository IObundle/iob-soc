// --------------------------------------------------------------------
// Copyright (c) 2012 by Terasic Technologies Inc.
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development
//   Kits made by Terasic.  Other use of this code, including the selling
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use
//   or functionality of this code.
//
// --------------------------------------------------------------------
//
//                     Terasic Technologies Inc
//                     E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------

#include "terasic_includes.h"
#include "mem_verify.h"


#define STATUS_BIT_DONE 	0x01
#define STATUS_BIT_FAIL 	0x02
#define STATUS_BIT_SUCCESS 	0x04


int main()
{
	bool bPass, bLoop;
	int TestIndex ;
	alt_u32 InitValue = 0x01;
	bool bShowMessage = TRUE;
	alt_u32 TimeStart, TimeElapsed;
	alt_u8 Status,ButtonStatus;
	const alt_u8 ButtonMask = 0x0F; // 4 button



	printf("===== DDR3 Test! Size=%dMB (CPU Clock:%d)=====\r\n", MEM_IF_DDR3_EMIF_SPAN/1024/1024, ALT_CPU_CPU_FREQ);
	Status = IORD(DDR3_STATUS_BASE, 0x00);

	while(1){
        printf("\n==========================================================\n");
        printf("Press any BUTTON to start test [BUTTON0 for continued test] \n");
        ButtonStatus = ButtonMask;
        while((ButtonStatus & ButtonMask) == ButtonMask){
        	ButtonStatus = IORD(BUTTON_BASE, 0);
        }

        if ((ButtonStatus & 0x01) == 0x00){
            bLoop = TRUE;
        }else{
            bLoop = FALSE;
        }

		//
        bPass = TRUE;
        TestIndex = 0;

        do{
        	TestIndex++;
        	printf("=====> DDR3 Testing, Iteration: %d\n", TestIndex);
        	TimeStart = alt_nticks();

        	if ((Status & STATUS_BIT_DONE) != STATUS_BIT_DONE){
        		printf("local init done: fail\r\n");
        		bPass = FALSE;
        	}

        	if (bPass && (((Status & STATUS_BIT_FAIL) == STATUS_BIT_FAIL) || ((Status & STATUS_BIT_SUCCESS) != STATUS_BIT_SUCCESS))){
        		printf("local init: fail\r\n");
        		bPass = FALSE;
        	}

        	if (bPass)
        		bPass = TMEM_Verify(MEM_IF_DDR3_EMIF_BASE, MEM_IF_DDR3_EMIF_SPAN, InitValue,  bShowMessage);

        	TimeElapsed = alt_nticks() - TimeStart;
        	printf("DDR3 test:%s, %d seconds\r\n", bPass?"Pass":"NG", (int)(TimeElapsed/alt_ticks_per_second()));


            if (bPass && bLoop){  // is abort loop?
            	ButtonStatus = IORD(BUTTON_BASE, 0);
            	if ((ButtonStatus & ButtonMask) != ButtonMask)
            		bLoop = FALSE; // press any key to abort continued test
            }

        }while(bLoop && bPass);
	} // while(1)

    return 0;
}


