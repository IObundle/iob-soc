VHDR+=iob_soc_boot.hex iob_soc_firmware.hex
include ../../software/sw_build.mk


IS_FPGA=1

TEST_LIST+=test1
test1:
	make -C $(ROOT_DIR) fpga-clean BOARD=$(BOARD)
	make -C $(ROOT_DIR) fpga-run TEST_LOG=">> test.log"

#board UART baud rate and core frequency of operation
BAUD=$(BOARD_BAUD)
FREQ=$(BOARD_FREQ)

#console start command
CONSOLE_CMD=$(PYTHON_DIR)/console.py -s /dev/usb-uart
ifeq ($(INIT_MEM),0)
CONSOLE_CMD+=-f
endif

#RULES

HEX:=$(NAME)_boot.hex
ifeq ($(INIT_MEM),1)
HEX+=$(NAME)_firmware.hex
endif

#
# Board access queue
#

QUEUE_FILE=/tmp/$(BOARD).queue
