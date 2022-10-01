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
#include "I2C.h"
#include "clock.h"
#include "si57x_config.h"


typedef bool (*LP_VERIFY_FUNC)(void);


bool TEST_Temperature(void);
bool TEST_CDCM(void);
bool TEST_Si570(void);

typedef struct{
    LP_VERIFY_FUNC func;
    char szName[128];
}FUNC_INFO;

FUNC_INFO szFuncList[] = {
    {TEST_Temperature, "Temperature"}, //ok
    {TEST_CDCM, "CDCM61004"}, // ok
    {TEST_Si570, "Si570"} // ok
};


void GUI_ShowMenu(void){
    int nNum,i;
    
    nNum = sizeof(szFuncList)/sizeof(szFuncList[0]);
    printf("======= Stratix V Demo Program =======\r\n");
    for(i=0;i<nNum;i++){
        printf("[%d] %s\r\n", i, szFuncList[i].szName);
    }
    printf("Input your chioce:");
}

int GUI_QueryUser(void){
    int nChoice = 0;
    scanf("%d", &nChoice);
    printf("%d\r\n", nChoice);
    return nChoice;
}

//===============================================================
int main(void){
    int nChoice;
    int nNum;
    bool bPass;
    
    nNum = sizeof(szFuncList)/sizeof(szFuncList[0]);
    while(1){
    	GUI_ShowMenu();
        nChoice = GUI_QueryUser();
        if (nChoice >= 0 && nChoice < nNum){
            bPass = szFuncList[nChoice].func();
            printf("%s Test:%s\r\n", szFuncList[nChoice].szName, bPass?"PASS":"NG");
        }            
    }     
    
}


bool TEST_Temperature(void){
    bool bPass = FALSE;
    const alt_u8 DeviceAddr = 0x30;
    alt_u8 LocalTemp, RemoteTemp;

    bPass = I2C_Read(TEMP_SCL_BASE, TEMP_SDA_BASE, DeviceAddr, 0x00, &LocalTemp);
    if (bPass)
        bPass = I2C_Read(TEMP_SCL_BASE, TEMP_SDA_BASE, DeviceAddr, 0x01, &RemoteTemp);

    if (bPass){
        printf("Local Temperature:%d\r\n", (char)LocalTemp);
        printf("Remote Temperature:%d\r\n", (char)RemoteTemp);
    }else{
        printf("Failed to read temperature\r\n");
    }        
    return bPass;
}




//===============================================================
bool TEST_CDCM(void){

	typedef struct{
		alt_u8 CLK_SETTING;
		float FREQUENCY;
	}CDCM_CONFIG;

	// input is 25 MHZ
	CDCM_CONFIG szConfig[] = {
		{2, 62.5}, // 0010
		{3, 75.0},//0011
		{4, 100.0},//0100
		{5, 125.0},//0101
		{6, 150.0},//0110
		{7, 156.25},//0111
		{8, 187.5},//1000
		{9, 200.0},//1001
		{10, 250.0},//1010
		{11, 312.5},//1011
		{12, 625.0}//1100
	};

	bool bPass = TRUE, bSuccess;
	int nNum, i, c;
	const int nTargetCnt = 1000;
	const int nTol = 3;
	alt_u32 clk1, clk2, ScaledClk2;
	alt_u32 sfp1g_ref_clk_ctrl, sata_ref_clk_ctrl, total_ref_clk_ctrl;
	



	nNum = sizeof(szConfig)/sizeof(szConfig[0]);
	
	// show menu
	for(i=0;i<nNum;i++){
		printf("%d: %.3f MHz\r\n",i, szConfig[i].FREQUENCY);
	}
	printf("Other:exit\r\n");
	printf("please select:");
	scanf("%d",&i);

	if (i>=nNum)
		return FALSE;



	printf("===== CDCM61004 Programming =====\r\n");

		printf("%.3f MHz Test Result:\r\n", szConfig[i].FREQUENCY);
		/////////////////
		// programming

		//{clk3_set_wr, clk2_set_wr, clk1_set_wr} <= s_writedata[11:0];
		sfp1g_ref_clk_ctrl = 1; // disable
		sata_ref_clk_ctrl = szConfig[i].CLK_SETTING;
		total_ref_clk_ctrl = (sata_ref_clk_ctrl << 4) | sfp1g_ref_clk_ctrl;
		IOWR(CDCM_BASE, 0x00, total_ref_clk_ctrl );

		// wait stable
		usleep(300*1000);

		/////////////////
		// measure
		bSuccess =  CLOCK_Test(REF_CLOCK_SATA_COUNT_BASE, nTargetCnt, &clk1, &clk2);
		if (!bSuccess){
			bPass = FALSE;
			printf("  %s ref clock test NG\r\n", "SATA");
		}else{
			ScaledClk2 = (int)((float) clk2 * 50.0 / szConfig[i].FREQUENCY);
			if (abs(nTargetCnt-clk1)<nTol && abs(clk1-ScaledClk2)<nTol){
				printf("  %s ref clock test PASS (clk1=%d, clk2=%d)\r\n", "SATA", (int)clk1, (int)clk2);
			}else{
				printf("  %s ref clock test NG (clk1=%d, clk2=%d)\r\n", "SATA", (int)clk1, (int)clk2);
				bPass = FALSE;
			}
		}



    return bPass;

}


//===============================================================

bool TEST_Si570(void){
	typedef struct{
		int FreqID;
		float FREQUENCY;
	}Si57x_CONFIG;


	Si57x_CONFIG szConfig[] = {
		{SI57x_100M, 100.0},
		{SI57x_125M, 125.0},
		{SI57x_156M25, 156.25},
		{SI57x_250M, 250.0},
		{SI57x_312M5, 312.5},
		{SI57x_322M265625, 322.265625},
		{SI57x_644M53125, 644.53125}
	};

	const alt_u8 DeviceAddr = 0x00;
	bool bPass;
	alt_u32 clk1, clk2,ScaledClk2;
	const int nTargetCnt=1000;
	const int nTol = 3;  //tolerance
	int i, nNum;
	nNum = sizeof(szConfig)/sizeof(szConfig[0]);


	// show menu
	printf("===== Si570 Programming =====\r\n");
	for(i=0;i<nNum;i++){
		printf("[%d] %.6f MHz\r\n",i, szConfig[i].FREQUENCY);
	}
	printf("[%d] Dump Register\r\n", nNum);
	printf("[Other] exit\r\n");
	printf("please select:");
	i = GUI_QueryUser();

	if (i> nNum)
		return FALSE;

	if (i == nNum){  // dump register

		bPass = SI57x_Config_Dump(CLK_I2C_SCL_BASE, CLK_I2C_SDA_BASE, DeviceAddr);
		return bPass;
	}

	// testing...


	bPass = SI57x_Config(szConfig[i].FreqID, CLK_I2C_SCL_BASE, CLK_I2C_SDA_BASE, DeviceAddr);


	if (bPass){
			// wait
			//usleep(200*1000);

			// measure
			bPass =  CLOCK_Test(REF_CLOCK_10G_COUNT_BASE, nTargetCnt, &clk1, &clk2);
			if (bPass){
				ScaledClk2 = (int)((float) clk2 * 50.0 / szConfig[i].FREQUENCY);
				if (abs(nTargetCnt-clk1)<=nTol && abs(clk1-ScaledClk2)<=nTol){
					printf("Si570/%.6fMHz clock test PASS (clk1=%d, clk2=%d, expected clk2=%d)\r\n",  szConfig[i].FREQUENCY, (int)clk1, (int)clk2, (int)((float)clk1*szConfig[i].FREQUENCY/50.0));
				}else{
					printf("Si570/%.6fMHz clock test NG (clk1=%d, clk2=%d, expected clk2=%d)\r\n",  szConfig[i].FREQUENCY, (int)clk1, (int)clk2, (int)((float)clk1*szConfig[i].FREQUENCY/50.0));
					bPass = FALSE;
				}
			}else{
				printf("Failed to perform CLOCK_Test\r\n");
			}
	}



	return bPass;

}


