#include "terasic_includes.h"
#include "mem_verify.h"


//#define SHOW_PROGRESS


bool TMEM_Verify(alt_u32 BaseAddr, alt_u32 ByteLen, alt_u32 InitValue, bool bShowMessage){
    bool bPass = TRUE;
    typedef alt_u32 my_data;
    my_data szData[257];
    int i, nRemainedLen, nAccessLen;
    my_data *pDes, *pSrc;
    int nItemNum, nPos;
    const int my_data_size = sizeof(my_data);
    int nProgressIndex=0;
    alt_u32 szProgress[10];
    
    if (bShowMessage){
        for(i=0;i<10;i++){
            szProgress[i] = ByteLen/10*(i+1);     
        }
    }        
    
    
    nItemNum = sizeof(szData)/sizeof(szData[0]);
    for(i=0;i<nItemNum;i++){
        if (i == 0)
            szData[i] = InitValue;
        else     
            szData[i] = szData[i-1] * 13;
    }
    szData[nItemNum-1] = 0xAAAAAAAA;
    szData[nItemNum-2] = 0x55555555;
    szData[nItemNum-3] = 0x00000000;
    szData[nItemNum-4] = 0xFFFFFFFF;

    if (bShowMessage)    
        printf("write...\n");
    // write
    pDes = (my_data *)BaseAddr;
    nAccessLen = sizeof(szData);
    nItemNum = nAccessLen / my_data_size;
    nPos = 0;
    while(nPos < ByteLen){
        nRemainedLen = ByteLen - nPos;
        if (nAccessLen > nRemainedLen){
            nAccessLen = nRemainedLen;
            nItemNum = nAccessLen / my_data_size;
        }    
        memcpy(pDes, szData, nAccessLen);
        pDes += nItemNum;
        nPos += nAccessLen;
        
        if (bShowMessage){
            if (nProgressIndex <= 9 && nPos >= szProgress[nProgressIndex]){
                nProgressIndex++;
                printf("%02d%% ", nProgressIndex*10);
            }
        }            
    } 
    
    alt_dcache_flush_all();
    
    if (bShowMessage){
        nProgressIndex = 0;
        printf("\nread/verify...\n");
    }        
    
    // read & verify
    pSrc = (my_data *)BaseAddr;
    nAccessLen = sizeof(szData);
    nItemNum = nAccessLen / my_data_size;
    nPos = 0;
    while(bPass && nPos < ByteLen){
        nRemainedLen = ByteLen - nPos;
        if (nAccessLen > nRemainedLen){
            nAccessLen = nRemainedLen;
            nItemNum = nAccessLen / my_data_size;
        }            
        pDes = szData;
        for(i=0;i<nItemNum && bPass;i++){
            if (*pSrc++ != *pDes++){ 
                if (bShowMessage)        
                    printf("verify ng, read=%08Xh, expected=%08Xh, WordIndex=%Xh\n", (int)*(pSrc-1), (int)szData[i], (nPos/my_data_size)+i);
                bPass = FALSE;
            }    
        }
        nPos += nAccessLen;
        if (bShowMessage){
            if (nProgressIndex <= 9 && nPos >= szProgress[nProgressIndex]){
                nProgressIndex++;
                printf("%02d%% ", nProgressIndex*10);
            }
        }            
    }     

    if (bShowMessage)    
        printf("\n");
    
    return bPass;
}


bool TMEM_QuickVerify(alt_u32 BaseAddr, alt_u32 DataSize, alt_u32 DataWidth, alt_u32 AddrWidth){
    bool bPass = TRUE;
    const alt_u32 TestNum = 1024*1024*2;
    const alt_u32 TestPattern = 0xAA;
    alt_u32 mask, Read32, Addr32, TestData32, TestAddr32;
    int i;
    
    //alt_u32 *pMem = (alt_u32 *)BaseAddr;
    // test address line
    mask = 0x01;
    for(i=0;i<AddrWidth && bPass;i++){
        //*(pMem + mask) = TestPattern;
        IOWR(BaseAddr, mask, TestPattern);
        //if (*(pMem + mask) != TestPattern)
        Read32 = IORD(BaseAddr, mask);
        if (Read32 != TestPattern)
            bPass = FALSE;
        mask <<= 1;    
    }
    
    // test data line
    mask = 0x01;
    for(i=0;i<DataWidth && bPass;i++){
        //*(pMem+i/32) = mask;
        Addr32 = i*13;
        IOWR(BaseAddr, Addr32, mask);
        Read32 = IORD(BaseAddr, Addr32);
        //if (*(pMem+i/32) != mask)
        if (Read32 != mask)
            bPass = FALSE;
        mask <<= 1;
        if (mask == 0x00)
            mask = 0x01;    
    }
    
    // random data test
    srand(alt_nticks());
    for(i=0;i<TestNum && bPass;i++){
        TestAddr32 = rand()%(DataSize/4);
        TestData32 = rand();
        IOWR(BaseAddr, TestAddr32, TestData32);
        Read32 = IORD(BaseAddr, TestAddr32);
        if (Read32 != TestData32)
            bPass = FALSE;        
        
    }
    
    return bPass;
}
