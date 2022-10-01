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
#include "i2c.h"

#define LED_STAY_DUR 	(150*1000)

typedef struct{
	alt_u8 mask;
	bool left_shift;
	alt_u8 led_num;
	alt_u32 avmm_base;
}LED_STATUS;

void LED_Play(LED_STATUS *pStatus){

	IOWR(pStatus->avmm_base, 0x00, ~pStatus->mask);

	if (pStatus->left_shift){
		pStatus->mask <<= 1;
		if (pStatus->mask == (0x01 << pStatus->led_num)){
			pStatus->mask = 0x01 << (pStatus->led_num-1);
			pStatus->left_shift = FALSE;
		}
	}else{
		pStatus->mask >>= 1;
		if (pStatus->mask == 0x00){
			pStatus->mask = 0x01;
			pStatus->left_shift = TRUE;
		}
	}
}

void TEMPERATURE_Display(void){
    bool bPass = FALSE;
    const alt_u8 DeviceAddr = 0x30;
    alt_8 LocalTemp, RemoteTemp;

    // hex map
    static    unsigned char szMap[] = {
            63, 6, 91, 79, 102, 109, 125, 7,
            127, 111, 119, 124, 57, 94, 121, 113
        };  // 0,1,2,....9, a, b, c, d, e, f
    const alt_u8 negative_id = 0x40;

    // read temperature

    bPass = I2C_Read(TEMP_SCL_BASE, TEMP_SDA_BASE, DeviceAddr, 0x00, &LocalTemp);
    if (bPass)
        bPass = I2C_Read(TEMP_SCL_BASE, TEMP_SDA_BASE, DeviceAddr, 0x01, &RemoteTemp);

    if (bPass){
        printf("FPGA/Board Temperature:%d/%d\r\n", (char)RemoteTemp, (char)LocalTemp);
    }else{
        printf("Failed to read temperature\r\n");
    }

    // display temperature
    if (bPass){
    	if (RemoteTemp > 99)
    		RemoteTemp = 99;
    	if (RemoteTemp >= 0){
    		IOWR(HEX0_BASE, 0, ~szMap[RemoteTemp%10]);
    		IOWR(HEX1_BASE, 0, ~szMap[(RemoteTemp/10)%10]);
    	}else{
    		if (RemoteTemp < -9)
    			RemoteTemp = -9;
    		RemoteTemp = -RemoteTemp;

      		IOWR(HEX0_BASE, 0, ~szMap[RemoteTemp%10]);
       		IOWR(HEX1_BASE, 0, ~negative_id); // negative
    	}

    }else{
		IOWR(HEX0_BASE, 0, ~negative_id); // negative
		IOWR(HEX1_BASE, 0, ~negative_id); // negative
    }
}


void DisplayInfo(void){
	alt_u8 *pData = (alt_u8 *)EXT_FLASH_BASE + 0x10000;
	int i;
	printf("[Flash]\r\n");
	printf("SN=");
	for(i=0;i<15;i++)
		printf("%c", *(pData+i));
	printf("\r\n");
	printf("TERASIC_END\r\n");
}


int main()
{
#if 0
	DisplayInfo();
	return 0;
#endif

	LED_STATUS LED_USER =    {0x01, TRUE, 3, LED_BASE};
	LED_STATUS LED_BRACKET = {0x01, TRUE, 4, LED_BRACKET_BASE};
	LED_STATUS LED_RJ45 =    {0x01, TRUE, 2, LED_RJ45_BASE};

	printf("Terasic - Parallel Flash Loader!\n");
	while(1){
		// led run
		LED_Play(&LED_USER);
		LED_Play(&LED_BRACKET);
		LED_Play(&LED_RJ45);

		// show fpga temperature
		TEMPERATURE_Display();

		// delay
		usleep(LED_STAY_DUR);

	}

	return 0;
}
