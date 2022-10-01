// --------------------------------------------------------------------
// Copyright (c) 2010 by Terasic Technologies Inc. 
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
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//

#ifndef _INC_PCIE_H
#define _INC_PCIE_H

#include "TERASIC_PCIE_AVMM.h"


#ifdef __cplusplus
extern "C"{
#endif

void *PCIE_Load(void);
void PCIE_Unload(void *lib_handle);

//
extern	LPPCIE_Open 		PCIE_Open;
extern	LPPCIE_Close 		PCIE_Close;
extern	LPPCIE_Read32 		PCIE_Read32;
extern	LPPCIE_Write32 		PCIE_Write32;
extern	LPPCIE_DmaWrite		PCIE_DmaWrite;
extern	LPPCIE_DmaRead		PCIE_DmaRead;
extern	LPPCIE_ConfigRead32	PCIE_ConfigRead32;


#ifdef __cplusplus
}
#endif



#endif /* _INC_PCIE_H */

