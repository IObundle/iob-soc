// ============================================================================
// Copyright (c) 2016 by Terasic Technologies Inc.
// ============================================================================
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
// ============================================================================
//           
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//  
//  
//                     web: http://www.terasic.com/  
//                     email: support@terasic.com
//
// ============================================================================
//

#ifndef _INC_TERASIC_PCIE_H
#define _INC_TERASIC_PCIE_H

#include <windows.h>

#ifdef __cplusplus
extern "C"{
#endif

#define PCIE_API __cdecl
typedef void *PCIE_HANDLE;
typedef UINT64 PCIE_ADDRESS;
typedef UINT64 PCIE_LOCAL_ADDRESS;
typedef UINT64 PCIE_LOCAL_FIFO_ID;

#define DEFAULT_PCIE_VID 0x1172
#define DEFAULT_PCIE_DID 0xE003


typedef enum
{
    PCIE_BAR0 = 0,  // do not change it
    PCIE_BAR1,
    PCIE_BAR2,
    PCIE_BAR3,
    PCIE_BAR4,
    PCIE_BAR5
}PCIE_BAR;

typedef enum{
    DMA_AVMM = 0x01
}DMA_ENGINE_TYPE;

typedef struct
{
    DWORD dwCounter;   // number of interrupts received
    DWORD dwLost;      // number of interrupts not yet dealt with
    BOOL fStopped;     // was interrupt disabled during wait
} PCIE_INT_RESULT;



//================================================================================
// function prototype used for "static load DLL"
#if 0
PCIE_HANDLE PCIE_API PCIE_Open(WORD wVendorID, WORD wDeviceID, WORD wCardNum);
void PCIE_API PCIE_Close(PCIE_HANDLE hFPGA);
BOOL PCIE_API PCIE_Read32 (PCIE_HANDLE hFPGA, PCIE_BAR PciBar, PCIE_ADDRESS PciAddress, DWORD *pdwData);
BOOL PCIE_API PCIE_Write32 (PCIE_HANDLE hFPGA, PCIE_BAR PciBar, PCIE_ADDRESS PciAddress, DWORD dwData);
BOOL PCIE_API PCIE_DmaRead (PCIE_HANDLE hFPGA, PCIE_LOCAL_ADDRESS LocalAddress, void *pBuffer, DWORD dwBufSize);
BOOL PCIE_API PCIE_DmaWrite (PCIE_HANDLE hFPGA, PCIE_LOCAL_ADDRESS LocalAddress, void *pData, DWORD dwDataSize);
BOOL PCIE_API PCIE_ConfigRead32 (PCIE_HANDLE hFPGA, DWORD Offset, DWORD *pData32);
#endif

//================================================================================
// function prototype used for "dynamic load DLL"
typedef PCIE_HANDLE (PCIE_API *LPPCIE_Open)(WORD wVendorID, WORD wDeviceID, WORD wCardNum);
typedef void (PCIE_API *LPPCIE_Close)(PCIE_HANDLE hFPGA);
typedef BOOL (PCIE_API *LPPCIE_Read32)(PCIE_HANDLE hFPGA, PCIE_BAR PciBar, PCIE_ADDRESS PciAddress, DWORD *pdwData);
typedef BOOL (PCIE_API *LPPCIE_Write32)(PCIE_HANDLE hFPGA, PCIE_BAR PciBar, PCIE_ADDRESS PciAddress, DWORD dwData);
typedef BOOL (PCIE_API *LPPCIE_DmaRead) (PCIE_HANDLE hFPGA, PCIE_LOCAL_ADDRESS LocalAddress, void *pBuffer, DWORD dwBufSize);
typedef BOOL (PCIE_API *LPPCIE_DmaWrite) (PCIE_HANDLE hFPGA, PCIE_LOCAL_ADDRESS LocalAddress, void *pData, DWORD dwDataSize);
typedef BOOL (PCIE_API *LPPCIE_ConfigRead32) (PCIE_HANDLE hFPGA, DWORD Offset, DWORD *pdwData);





#ifdef __cplusplus
}
#endif



#endif /* _INC_TERASIC_PCIE_H */

