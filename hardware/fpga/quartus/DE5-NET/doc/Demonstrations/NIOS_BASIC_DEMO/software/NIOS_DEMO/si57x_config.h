/*
 * si57x_config.h
 *
 *  Created on: 2014/7/11
 *      Author: Richard
 */

#ifndef SI57X_CONFIG_H_
#define SI57X_CONFIG_H_


typedef enum{
	SI57x_100M = 0,
	SI57x_125M,
	SI57x_156M25,
	SI57x_250M,
	SI57x_312M5,
	SI57x_322M265625,
	SI57x_500M,
	SI57x_625M,
	SI57x_644M53125

}SI57x_FREQ_ID;

bool SI57x_Config(SI57x_FREQ_ID FreqID, alt_u32 SI57x_I2C_SCLK_BASE, alt_u32 SI57x_I2C_SDAT_BASE, int SI57x_DeviceAddr);
bool SI57x_Config_Dump(alt_u32 SI57x_I2C_SCLK_BASE, alt_u32 SI57x_I2C_SDAT_BASE, int SI57x_DeviceAddr);


#endif /* SI57X_CONFIG_H_ */
