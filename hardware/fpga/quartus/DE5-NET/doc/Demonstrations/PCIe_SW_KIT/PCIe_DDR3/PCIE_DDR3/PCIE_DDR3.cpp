// PCIE_DDR3.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include "PCIE.h"


#define DEMO_PCIE_USER_BAR			PCIE_BAR4
#define DEMO_PCIE_IO_LED_ADDR		0x4000010
#define DEMO_PCIE_IO_BUTTON_ADDR	0x4000020
#define DEMO_PCIE_ONCHIP_MEM_ADDR	0x00000000
#define DEMO_PCIE_DDR3A_MEM_ADDR	0x100000000
#define DEMO_PCIE_DDR3B_MEM_ADDR	0x200000000

#define ONCHIP_MEM_TEST_SIZE		(512*1024) //512KB
#define DDR3A_MEM_TEST_SIZE	    	(2*1024*1024*1024) //2GB
#define DDR3B_MEM_TEST_SIZE		    (2*1024*1024*1024) //2GB


typedef enum{
	MENU_LED = 0,
	MENU_BUTTON,
	MENU_LINK_INFO,
	MENU_DMA_ONCHIP_MEMORY,
	MENU_DMA_DDR3A_MEMORY,
	MENU_DMA_DDR3B_MEMORY,
	MENU_QUIT = 99
}MENU_ID;

void UI_ShowMenu(void){
	printf("==============================\r\n");
	printf("[%d]: Led control\r\n", MENU_LED);
	printf("[%d]: Button Status Read\r\n", MENU_BUTTON);
	printf("[%d]: Link Info\r\n", MENU_LINK_INFO);
	printf("[%d]: DMA On-Chip Memory Test\r\n", MENU_DMA_ONCHIP_MEMORY);
	printf("[%d]: DMA DDR3-A Sodimm Memory Test\r\n", MENU_DMA_DDR3A_MEMORY);
	printf("[%d]: DMA DDR3-B Sodimm Memory Test\r\n", MENU_DMA_DDR3B_MEMORY);
	printf("[%d]: Quit\r\n", MENU_QUIT);
	printf("Plesae input your selection:");
}

int UI_UserSelect(void){
	int nSel;
	scanf("%d",&nSel);
	return nSel;
}


BOOL TEST_LED(PCIE_HANDLE hPCIe){
	BOOL bPass;
	int	Mask;
	
	printf("Please input led conrol mask:");
	scanf("%d", &Mask);

	bPass = PCIE_Write32(hPCIe, DEMO_PCIE_USER_BAR, DEMO_PCIE_IO_LED_ADDR,(DWORD)Mask);
	if (bPass)
		printf("Led control success, mask=%xh\r\n", Mask);
	else
		printf("Led conrol failed\r\n");

	
	return bPass;
}

BOOL TEST_BUTTON(PCIE_HANDLE hPCIe){
	BOOL bPass = TRUE;
	DWORD Status;

	bPass = PCIE_Read32(hPCIe, DEMO_PCIE_USER_BAR, DEMO_PCIE_IO_BUTTON_ADDR,&Status);
	if (bPass)
		printf("Button status mask:=%xh\r\n", Status);
	else
		printf("Failed to read button status\r\n");

	
	return bPass;
}


BOOL TEST_LINK_INFO(PCIE_HANDLE hPCIe){
	BOOL bPass = TRUE;
	DWORD Status;
	DWORD Data32;

	// read config - id
	if (PCIE_ConfigRead32(hPCIe,  0x00, &Data32)){
		printf("Vender ID:%04Xh\r\n", Data32 & 0xFFFF);
		printf("Device ID:%04Xh\r\n", (Data32 >> 16) & 0xFFFF);
	}else{
		bPass = false;
	}


	// read config - link status
	if (PCIE_ConfigRead32(hPCIe,  0x90, &Data32)){
		switch((Data32 >> 16) & 0x0F){
                case 1:
                    printf("Current Link Speed is Gen1\r\n");
                    break;
                case 2:
                    printf("Current Link Speed is Gen2\r\n");
                    break;
                case 3:
                    printf("Current Link Speed is Gen3\r\n");
                    break;
                default:
                    printf("Current Link Speed is Unknown\r\n");
                    break;
		}
		switch((Data32 >> 20) & 0x3F){
                case 1:
                    printf("Negotiated Link Width is x1\r\n");
                    break;
                case 2:
                    printf("Negotiated Link Width is x2\r\n");
                    break;
                case 4:
                    printf("Negotiated Link Width is x4\r\n");
                    break;
                case 8:
                    printf("Negotiated Link Width is x8\r\n");
                    break;
                case 16:
                    printf("Negotiated Link Width is x16\r\n");
                    break;
                default:
                    printf("Negotiated Link Width is Unknown\r\n");
                    break;
		}
	}else{
		bPass = false;
	}

	// read config - id
	if (PCIE_ConfigRead32(hPCIe,  0x88, &Data32)){
		switch((Data32 >> 5) & 0x0007){
                case 0:
                    printf("Maximum Payload Size is 128-byte\r\n");
                    break;
                case 1:
                    printf("Maximum Payload Size is 256-byte\r\n");
                    break;
                case 2:
                    printf("Maximum Payload Size is 512-byte\r\n");
                    break;
                case 3:
                    printf("Maximum Payload Size is 1024-byte\r\n");
                    break;
                case 4:
                    printf("Maximum Payload Size is 2048-byte\r\n");
                    break;
                default:
                    printf("Maximum Payload Size is Unknown\r\n");
                    break;
		}
	}else{
		bPass = false;
	}


	
	return bPass;
}

char PAT_GEN(int nIndex){
	char Data;
	Data = nIndex & 0xFF;
	return Data;
}

BOOL TEST_DMA_MEMORY(PCIE_HANDLE hPCIe, PCIE_LOCAL_ADDRESS LocalAddr, UINT32 nTestSize){
	BOOL bPass = TRUE;
	int i;
	char *pWrite;
	char *pRead;
	char szError[256];

	printf("DMA Memory Test, size=%udBytes...\r\n", nTestSize);
	pWrite = (char *)malloc(nTestSize);
	pRead = (char *)malloc(nTestSize);
	if (!pWrite || !pRead){
		bPass = FALSE;
		sprintf(szError, "DMA Memory:malloc failed\r\n");
	}
	

	// init test pattern
	printf("Generate Test Pattern...\r\n");
	for(i=0;i<nTestSize && bPass;i++)
		*(pWrite+i) = PAT_GEN(i);

	// write test pattern
	if (bPass){
		printf("DMA Write...\r\n");
		bPass = PCIE_DmaWrite(hPCIe, LocalAddr, pWrite, nTestSize);
		if (!bPass)
			sprintf(szError, "DMA Memory:PCIE_DmaWrite failed\r\n");
	}		

	// read back test pattern and verify
	if (bPass){
		printf("DMA Read...\r\n");
		bPass = PCIE_DmaRead(hPCIe, LocalAddr, pRead, nTestSize);

		if (!bPass){
			sprintf(szError, "DMA Memory:PCIE_DmaRead failed\r\n");
		}else{
			printf("Readback Data Verify...\r\n");
			for(i=0;i<nTestSize && bPass;i++){
				if (*(pRead+i) != PAT_GEN(i)){
					bPass = FALSE;
					sprintf(szError, "DMA Memory:Read-back verify unmatch, index = %d, read=%xh, expected=%xh\r\n", i, *(pRead+i), PAT_GEN(i));
				}
			}
		}
	}


	// free resource
	if (pWrite)
		free(pWrite);
	if (pRead)
		free(pRead);
	
	if (!bPass)
		printf("%s", szError);
	else
		printf("DMA-Memory (Size = %ud byes) pass\r\n", nTestSize);


	return bPass;
}


int main(int argc, _TCHAR* argv[])
{
	void *lib_handle;
	PCIE_HANDLE hPCIE;
	BOOL bQuit = FALSE;
	int nSel;

	printf("== Terasic: PCIe Demo Program ==\r\n");

	lib_handle = PCIE_Load();
	if (!lib_handle){
		printf("PCIE_Load failed!\r\n");
		return 0;
	}

	hPCIE = PCIE_Open(DEFAULT_PCIE_VID,DEFAULT_PCIE_DID,0);
	if (!hPCIE){
		printf("PCIE_Open failed\r\n");
	}else{
		while(!bQuit){
			UI_ShowMenu();
			nSel = UI_UserSelect();
			switch(nSel){	
				case MENU_LED:
					TEST_LED(hPCIE);
					break;
				case MENU_BUTTON:
					TEST_BUTTON(hPCIE);
					break;
				case MENU_LINK_INFO:
					TEST_LINK_INFO(hPCIE);
					break;
				case MENU_DMA_ONCHIP_MEMORY:
					TEST_DMA_MEMORY(hPCIE, DEMO_PCIE_ONCHIP_MEM_ADDR, ONCHIP_MEM_TEST_SIZE);
					break;
				case MENU_DMA_DDR3A_MEMORY:
					TEST_DMA_MEMORY(hPCIE, DEMO_PCIE_DDR3A_MEM_ADDR, DDR3A_MEM_TEST_SIZE);
					break;
				case MENU_DMA_DDR3B_MEMORY:
					TEST_DMA_MEMORY(hPCIE, DEMO_PCIE_DDR3B_MEM_ADDR, DDR3B_MEM_TEST_SIZE);
					break;
				case MENU_QUIT:
					bQuit = TRUE;
					printf("Bye!\r\n");
					break;
				default:
					printf("Invalid selection\r\n");
			} // switch

		}// while

		PCIE_Close(hPCIE);

	}

	PCIE_Unload(lib_handle);
	return 0;

}

