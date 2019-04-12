`timescale 1ns / 1ps
`include "spi_defines.vh"

module spi_top (
		input 			 rst, 
		input 			 clk,
		input 			 sclk,

		//spi master control
		input [`SPI_ADDR_W-1:0]  m_address,
		input [`SPI_DATA_W-1:0]  m_data_in,
		input 			 m_sel,
		input 			 m_read,
		input 			 m_write,
		output [`SPI_DATA_W-1:0] m_data_out,
		output 			 m_interrupt,

		//spi slave control
		input [`SPI_ADDR_W-1:0]  s_address, 
		input 			 s_sel,
		input 			 s_read, 
		input 			 s_write, 
		output [`SPI_DATA_W-1:0] s_data_out,
		input [`SPI_DATA_W-1:0]  s_data_in, 
		output			 s_interrupt
		);
	  
   //spi signals
   wire 				 miso;
   wire 				 mosi;
   wire 				 ss;   
   

   // Instantiate the Units Under Test (UUTs)
   spi_master spi_m (
		     .clk		(clk),
		     .rst		(rst),
		     
		     // SPI 
		     .ss		(ss),
		     .mosi		(mosi),
		     .sclk		(sclk),
		     .miso		(miso),
		     
		     // CONTROL
		     .data_in		(m_data_in),
		     .address		(m_address),
		     .data_out		(m_data_out),
		     .interrupt		(m_interrupt),
		     .sel		(m_sel),
		     .read		(m_read),
		     .write		(m_write)
                     );
   
   spi_slave spi_s (
		    .clk		(clk),
		    .rst		(rst),

		    // SPI 
		    .miso		(miso),
		    .sclk		(sclk),
		    .ss			(ss),
		    .mosi		(mosi),
		    
		    // CONTROL
		    .data_out		(s_data_out[`SPI_DATA_W-1:0]),
		    .interrupt		(s_interrupt),
		    .data_in		(s_data_in[`SPI_DATA_W-1:0]),
		    .address		(s_address[`SPI_ADDR_W-1:0]),
		    .sel		(s_sel),
		    .read		(s_read),
		    .write		(s_write)
                    );

 
endmodule

