/*
 * si57x_config.c
 *
 *  Created on: 2014/7/11
 *      Author: Richard
 */


#include "terasic_includes.h"
#include "i2c.h"
#include "si57x_config.h"


typedef struct{
	int FreqID;
	int HS_DIV;
	int N1;
//	alt_u64 REFEQ;
	double FREQUENCY;
}Si57x_CONFIG;


Si57x_CONFIG gszGi57x_ConfigTable[] = {
		{SI57x_100M, 		5, 10, 100.0},
		{SI57x_125M, 		5, 8,  125.0},
		{SI57x_156M25, 		4, 8,  156.25},
		{SI57x_250M, 		5, 4,  250.0},
		{SI57x_312M5, 		4, 4,  312.5},
		{SI57x_322M265625,  4, 4, 322.265625},
		{SI57x_500M, 		5, 2, 500.0},
		{SI57x_625M, 		4, 2, 625.0},
		{SI57x_644M53125, 	4, 2, 644.53125},
};

bool si57x_find_DIV_NI(SI57x_FREQ_ID FreqID, alt_u32 *pnHS_DIV, alt_u32 *pnN1, double *pfFreq){
	bool bFind = FALSE;
	int i;

	for(i=0;i<sizeof(gszGi57x_ConfigTable)/sizeof(gszGi57x_ConfigTable[0]) && !bFind;i++){
		if (gszGi57x_ConfigTable[i].FreqID == FreqID){
			bFind = TRUE;
			*pnHS_DIV = gszGi57x_ConfigTable[i].HS_DIV;
			*pnN1 = gszGi57x_ConfigTable[i].N1;
			*pfFreq = gszGi57x_ConfigTable[i].FREQUENCY;
		}
	} // for

	return bFind;

}



bool SI57x_Config(SI57x_FREQ_ID FreqID, alt_u32 SI57x_I2C_SCLK_BASE, alt_u32 SI57x_I2C_SDAT_BASE, int SI57x_DeviceAddr){
	bool bSuccess;
	const alt_u8 CommandReg = 135;
	const alt_u8 FreezeDCOReg = 137;
	alt_u8 szReg[13];  //7~12
	double fFreq, fxtal, fdco;
	alt_u32 HS_DIV, HS_DIV_REG_VALUE, N1, N1_REG_VALUE;
	alt_u32 REFEQ_HI, REFEQ_LOW;
	alt_u64 REFEQ;
	alt_u8 Command;
	int n;
	// startup
	double startup_fFreq = 100.0, startup_fREFEQ;
	alt_u8 startup_HS_DIV, startup_N1;
	alt_u64 startup_REFEQ;

	bSuccess = si57x_find_DIV_NI(FreqID, &HS_DIV, &N1, &fFreq);
	if (!bSuccess){
		printf("This not my preset freq id (%d)\r\n", FreqID);
		return FALSE;
	}

	//////////////////////////////////////////
	// 1) Read start-up frequency configuration

	// reset
	bSuccess = I2C_Read(SI57x_I2C_SCLK_BASE, SI57x_I2C_SDAT_BASE, SI57x_DeviceAddr, CommandReg, &Command);
	if (!bSuccess){
		printf("Failed to perform I2C read, reg-%d\r\n", CommandReg);
	}else{
		Command |= 0x80; // assert reset
		bSuccess = I2C_Write(SI57x_I2C_SCLK_BASE, SI57x_I2C_SDAT_BASE, SI57x_DeviceAddr, CommandReg, Command);
		bSuccess = TRUE; // force it to success because it always return false due to i2c state machine is interrupt
		if (!bSuccess){
		}
		if (!bSuccess){
			printf("failed to reset\r\n");
		}else{
			//Asserting RST_REG will interrupt the I2C state machine.
			// richard note. wait i2c machine ready
			usleep(10*1000); // wait 10 ms

			// read startup reg value
			for(n=7;n<=12 && bSuccess;n++){
				bSuccess = I2C_Read(SI57x_I2C_SCLK_BASE, SI57x_I2C_SDAT_BASE, SI57x_DeviceAddr, n, &szReg[n]);
			}

			if (!bSuccess){
				printf("failed to read startup register value\r\n");
			}else{
				startup_HS_DIV = (szReg[7] >> 5) & 0x07;
				startup_HS_DIV += 4;

				startup_N1 = ((szReg[7] & 0x1F) << 2) | ((szReg[8] >> 6) & 0x03);
				startup_N1 += 1;

				startup_REFEQ = (alt_u64)szReg[12] | ((alt_u64)szReg[11] << 8) | ((alt_u64)szReg[10] << 16)  | ((alt_u64)szReg[9] << 24) |  (((alt_u64)szReg[8] & 0x3F) << 32);
				startup_fREFEQ = startup_REFEQ / (double)(0x01LL << 28);

				printf("startup:\r\nHS_DIV=%d,\r\nN1=%d,\r\nREFEQ=%llxh\r\nfREFEQ=%f\r\n", startup_HS_DIV, startup_N1, startup_REFEQ, startup_fREFEQ);

				//////////////////////////////////////////////////////////////////////
				// 2) Calculate the actual nominal crystal frequency where f0 is the start-up output frequency
				fxtal = (double)(startup_fFreq *  startup_HS_DIV * startup_N1) / startup_fREFEQ ; // ( f0 x HS_DIV x N1 ) / RFREQ
				printf("fxtal:%f MHz\r\n", fxtal);

				//3) Choose the new output frequency (f1).
				//      Output Frequency (f1) = 625.000000000 MHz
				// --> bSuccess = si57x_find_DIV_NI(FreqID, &HS_DIV, &N1, &fFreq);
				printf("Output Frequency (f1) =%f MHz\r\n", fFreq);

				//4) Choose the output dividers for the new frequency configuration (HS_DIV and N1) by ensuring the DCO oscillation frequency (fdco) is between 4.85 GHz and 5.67 GHz where fdco = f1 x HS_DIV x N1. See the Divider Combinations tab for more options.
				fdco = fFreq * HS_DIV * N1;  //MHz
				if (fdco < 4.85*1000.0){
					printf("fail: fdco(%f) < 4.8G\r\n", fdco);
					bSuccess = FALSE;
				}else if (fdco > 5.67*1000.0){
					printf("fail: fdco(%f) > 5.67G\r\n", fdco);
					bSuccess = FALSE;
				}else{
					printf("fdco:%f GHz\r\n", fdco/1000.0);
				}


				// 5) Calculate the new crystal frequency multiplication ratio (RFREQ) as RFREQ = fdco / fxtal
				REFEQ = (alt_u64)(fdco/fxtal * (double)(0x01LL << 28));
			}

		}
	}


	// calculate new REFEQ & configre
	if (bSuccess){
		REFEQ_HI = (REFEQ >> 32) & 0xFFFFFFFF;
		REFEQ_LOW = REFEQ & 0xFFFFFFFF;

		printf("HS_DIV=%xh, N1=%xh, REFEQ:%x-%xh\r\n", HS_DIV, N1, REFEQ_HI, REFEQ_LOW );

		switch(HS_DIV){
			case 4: HS_DIV_REG_VALUE = 0; break;
			case 5: HS_DIV_REG_VALUE = 1; break;
			case 6: HS_DIV_REG_VALUE = 2; break;
			case 7: HS_DIV_REG_VALUE = 3; break;
			case 9: HS_DIV_REG_VALUE = 5; break;
			case 11: HS_DIV_REG_VALUE = 7; break;
		}
		N1_REG_VALUE = N1-1;

		// build register content
		szReg[7]  = ((HS_DIV_REG_VALUE << 5) & 0xE0) | ((N1_REG_VALUE >> 2) & 0x1f);
		szReg[8]  = ((REFEQ_HI) & 0x3f) | ((N1_REG_VALUE << 6) & 0xc0);
		szReg[9]  = (REFEQ_LOW >> 24) & 0xff;
		szReg[10] = (REFEQ_LOW >> 16) & 0xff;
		szReg[11] = (REFEQ_LOW >>  8) & 0xff;
		szReg[12] = (REFEQ_LOW >>  0) & 0xff;


		// 6) Freeze the DCO by setting Freeze DCO = 1 (bit 4 of register 137).
		bSuccess = I2C_Write(SI57x_I2C_SCLK_BASE, SI57x_I2C_SDAT_BASE, SI57x_DeviceAddr, FreezeDCOReg, 0x10);
		if (!bSuccess)
			printf("failed to freeze DCO\r\n");

		// 7) Write the new frequency configuration (RFREQ, HS_DIV, and N1)
		for(n=7;n<=12 && bSuccess;n++){
			//printf("reg[%d] write:%02xh\r\n", n, szReg[n]);
			bSuccess = I2C_Write(SI57x_I2C_SCLK_BASE, SI57x_I2C_SDAT_BASE, SI57x_DeviceAddr, n, szReg[n]);
			if (!bSuccess)
				printf("Failed to perform I2C write, reg-%d with value %02x\r\n", n, szReg[n]);
		}

		// 8) Unfreeze the DCO by setting Freeze DCO = 0 and assert the NewFreq bit (bit 6 of register 135) within 10 ms.
		if (bSuccess){
			// remember current content of Command Register (register 135)
			bSuccess = I2C_Read(SI57x_I2C_SCLK_BASE, SI57x_I2C_SDAT_BASE, SI57x_DeviceAddr, CommandReg, &Command);
			if (!bSuccess)
				printf("Failed to perform I2C read, reg-%d\r\n", CommandReg);

			// Unfreeze the DCO by setting Freeze DCO = 0
			bSuccess = I2C_Write(SI57x_I2C_SCLK_BASE, SI57x_I2C_SDAT_BASE, SI57x_DeviceAddr, FreezeDCOReg, 0x00);
			if (!bSuccess)
				printf("failed to unfreeze DCO\r\n");

			// assert the NewFreq bit (bit 6 of register 135)
			if (bSuccess){
				Command |= 0x40;
				bSuccess = I2C_Write(SI57x_I2C_SCLK_BASE, SI57x_I2C_SDAT_BASE, SI57x_DeviceAddr, CommandReg, Command);
				if (!bSuccess){
					printf("Failed to perform I2C write, reg-%d with value %02x\r\n", CommandReg, Command);
				}else{
					printf("Reg-135, Reset?Freeze/Memory Control:%xh\r\n", Command);
					usleep(10*1000); // wait 10 ms to clock stable
					printf("Done\r\n");
				}
			}
		}
	}


	// re-config


	//
	return bSuccess;

}


bool SI57x_Config_Dump(alt_u32 SI57x_I2C_SCLK_BASE, alt_u32 SI57x_I2C_SDAT_BASE, int SI57x_DeviceAddr){
	bool bSuccess;
	alt_u8 szReg[13];  //7~12
	int n;
	// startup
	alt_u8 startup_HS_DIV, startup_N1;
	alt_u64 startup_REFEQ;


			// read startup reg value
			for(n=7;n<=12 && bSuccess;n++){
				bSuccess = I2C_Read(SI57x_I2C_SCLK_BASE, SI57x_I2C_SDAT_BASE, SI57x_DeviceAddr, n, &szReg[n]);
			}

			if (!bSuccess){
				printf("failed to read startup register value\r\n");
			}else{
				startup_HS_DIV = (szReg[7] >> 5) & 0x07;
				startup_HS_DIV += 4;

				startup_N1 = ((szReg[7] & 0x1F) << 2) | ((szReg[8] >> 6) & 0x03);
				startup_N1 += 1;

				startup_REFEQ = (alt_u64)szReg[12] | ((alt_u64)szReg[11] << 8) | ((alt_u64)szReg[10] << 16)  | ((alt_u64)szReg[9] << 24) |  (((alt_u64)szReg[8] & 0x3F) << 32);

				printf("startup:\r\nHS_DIV=%d,\r\nN1=%d,\r\nREFEQ=%llxh\r\n", startup_HS_DIV, startup_N1, startup_REFEQ);

				for(n=7;n<=12;n++){
					printf("reg[%d]=%02xh\r\n", n, szReg[n]);
				}

			}




	return bSuccess;


}
