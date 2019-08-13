# iob-rv32-mig-native-axi
OUTDATED:
User simple guide (any question feel free to contact 96 205 71 03 (João Roque)):

1. Create a Vivado Project (2017.4 preferable), select the board: xcku040-fbva676-1-c; 

2. Add sources (and constraint), select the folders inside of the "rtl" folder (click "Copy sources into project" box). Although if you're able to use the IP Catalog to add the IPs to your project, you may skip the folder "vivado_ip" and add the DDR4 MIG yourself, has it will be shown on the following steps (although adding this folder should work, but better safe than sorry);
    (Do not forget to make "Set as Top" the "top_system.v" (in the Sources>Hierarchy Window));
3. In "simulation" folder: make boot.hex;

(If necessary, also make: make firmware.hex (though it will not be used here))

4. Click add sources (All files) and add the .dat that are in the "simulation" folder (do Not "Copy sources into project", so this way Vivado uploads the .dat everytime they change, good for simulation);

5. Since I found some problems with adding the Out-of-context DDR4 to the project, it's better for the user to add it him/herself:

	- IP Catalog > Memories & Storage Elements > External Memory Interface > DDR4 SDRAM (MIG);

	-Basic:

		- Component Name: ddr4_0;

		- Mode and Interface: Controller and physical layer, AXI4 Interface;

		- Clocking:
		  - Memory Device Interface Speed(ps): 1250;
		  - Refenrece Input Clock Speed (ps): 4000 (250 Mhz);

		- Controller Options:
		  - Configuration: Components*;
		  - Memory Part: EDY4016AABG-DR-F;
		  - Slot: Single*;
		  - IO Memory Voltage: 1.2V*;
		  - Data Width: 32;
		  - Data Mask and DBI: DM NO DBI*;
		  - Memory Address Map: ROW COLUMN BANK*;
		  - Ordering: Normal*;
		  - Cas Latency: 11;
		  - Cas Write Latency: 11;
	
	-AXI Options:
	
		  - Data Width: 32;
		  - Arbitration Scheme: RD PRI REG;
		  - ID Width: 4*;
		  - Address Width: 30*;

	 -Advanced Clocking:

		  - System Clock Option:
		  - Reference Input Clock Configuration: Differential;	

	 - Advanced Options:

		  - leave everything by default;

	(* - Means default value);
		
		Ok > Generate Out-of-Context (so you don't need to waste 10 minutes everythime you synthetize your project).
		
6. Run Synthesis > Implementation > Generate Bitstream (or just click Generate Bitstream and it will queue them all) 
7. After generating the bitstream, you need to load your board with 2 object:
	- top_system.bit (the bit file generated);
	- top_system.ltx (the DDR calibration probe);

	This files are inside of *your_project_*/*your_project_*.runs/impl_1/

8. Before loading the .bit to the board, open Picocom (or cat to see the information that will come through the UART):
	- picocom /dev/ttyUSB0 -b 115200 --imap lfcrlf
9. After opening the picocom and load the 2 objects to the FPGA, you should see:
	Load Program throught UART to Main Memory...
10. In "simulation" folder, if you already made the firmware.hex (or alter it to your desire), do: make uart_loader
11. Profit!

In Simulation folder, the suffix "uart" is for when the user uses the picosoc's UART (currently used).
The UART is selected in the parameter (in system.vh) PICOSOC_UART. If selected, it will use the simpleuart of the Picorv32 repo, a lower quality UART, otherwise it will use the IOB UART. This way the user can debug changes in the UARTs.
For Simulation, since the program can't be loaded from the UART, the user will use the AUX_MEM, using the boot.hex from boot_simple.c (make boot_simple.hex).

boot_simple: uses AUX_MEM to load the program to the Main Memory
firmware_test: a simple program that writes a counter in each corresponding position, good to check the performance to the cache.
uart_file_loader.c: program to load the program throught the UART to the main Memory (DDR4).

Check Makefile to check how to compile each combination of .hex (though you can compile them seperately by using Make *name of hex needed*.hex).

The Cache functions are currently only being used in firmware_test_uart.c, a header needs to be created (cache.h).

top_system.v connects the system.v (evnironment) to the (controller/MIG) Main Memory (DDR).

there are some .v that are not being used but can be of service (they work), like: iob_uart_axi.v; iob_axi_interconnect.v, etc...

iob_native_interconnect.v isn't using the memory_mapped_par.vh (the addresses are written at the end of the .v file).

If using Vivado, after making the .hex of the necessary programs (boot and firmware), add as source, to your Vivado project,  the .dat files that are created by the Makefile (do not click the "include to project",
this way it automatically updates when you make new .dat.

