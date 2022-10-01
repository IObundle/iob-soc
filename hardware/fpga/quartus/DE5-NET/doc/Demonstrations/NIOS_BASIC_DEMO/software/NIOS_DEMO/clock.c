#include "terasic_includes.h"
#include "clock.h"

bool CLOCK_Test(alt_u32 BaseAddr, alt_u32 TargetCnt, alt_u32 *pclk1, alt_u32 *pclk2){
    bool bSuccess = TRUE;
    const alt_u16 reg_start = 0;
    const alt_u16 reg_clk1 = 1;
    const alt_u16 reg_clk2 = 2;
    alt_u32 Status=1;
    const alt_u32 RunFlag;
    int cnt=0;
    // start
    IOWR(BaseAddr,reg_start, 0x0000);  // stop
    //IOWR(BaseAddr,reg_start, 0x03FF);  // start
    IOWR(BaseAddr,reg_start, TargetCnt);  // start
    usleep(100*1000);
    // wait finish
    while((Status & RunFlag) && cnt++ < 1000){
        Status = IORD(BaseAddr, reg_start);
    }    
    // check result
    if ((Status & RunFlag) == 0){     
        *pclk1 = IORD(BaseAddr, reg_clk1);
        *pclk2 = IORD(BaseAddr, reg_clk2);
    }else{
        *pclk1 = 0;
        *pclk2 = 0;
        bSuccess = FALSE;
    }        
    IOWR(BaseAddr,reg_start, 0x0000);  // stop
    return bSuccess;
}
