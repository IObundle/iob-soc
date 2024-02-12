#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "iob_timer.h"

uint32_t read_reg(int fd, uint32_t addr, uint32_t nbits, uint32_t *value) {
	ssize_t ret = -1;

	if (fd == 0) {
		perror("[User] Invalid file descriptor");
		return -1;
	}

	// Point to register address
	if (lseek(fd, addr, SEEK_SET) == -1) {
		perror("[User] Failed to seek to register");
		return -1;
	}

	// Read value from device
	switch (nbits) {
	case 8:
		uint8_t value8 = 0;
		ret = read(fd, &value8, sizeof(value8));
		if (ret == -1) {
			perror("[User] Failed to read from device");
		}
		*value = (uint32_t)value8;
		break;
	case 16:
		uint16_t value16 = 0;
		ret = read(fd, &value16, sizeof(value16));
		if (ret == -1) {
			perror("[User] Failed to read from device");
		}
		*value = (uint32_t)value16;
		break;
	case 32:
		uint32_t value32 = 0;
		ret = read(fd, &value32, sizeof(value32));
		if (ret == -1) {
			perror("[User] Failed to read from device");
		}
		*value = (uint32_t)value32;
		break;
	default:
		// unsupported nbits
		ret = -1;
		*value = 0;
		perror("[User] Unsupported nbits");
		break;
	}

	return ret;
}

uint32_t write_reg(int fd, uint32_t addr, uint32_t nbits, uint32_t value) {
	ssize_t ret = -1;

	if (fd == 0) {
		perror("[User] Invalid file descriptor");
		return -1;
	}

	// Point to register address
	if (lseek(fd, addr, SEEK_SET) == -1) {
		perror("[User] Failed to seek to register");
		return -1;
	}

	// Write value to device
	switch (nbits) {
	case 8:
		uint8_t value8 = (uint8_t)value;
		ret = write(fd, &value8, sizeof(value8));
		if (ret == -1) {
			perror("[User] Failed to write to device");
		}
		break;
	case 16:
		uint16_t value16 = (uint16_t)value;
		ret = write(fd, &value16, sizeof(value16));
		if (ret == -1) {
			perror("[User] Failed to write to device");
		}
		break;
	case 32:
		ret = write(fd, &value, sizeof(value));
		if (ret == -1) {
			perror("[User] Failed to write to device");
		}
		break;
	default:
		break;
	}

	return ret;
}

uint32_t timer_print_version(int fd) {
	uint32_t ret = -1;
	uint32_t version = 0;

	ret = read_reg(fd, IOB_TIMER_VERSION_ADDR, IOB_TIMER_VERSION_W, &version);
	if (ret == -1) {
		return ret;
	}

	printf("[User] Version: 0x%x\n", version);
	return ret;
}

uint32_t timer_reset(int fd) {
	if (write_reg(fd, IOB_TIMER_RESET_ADDR, IOB_TIMER_RESET_W, 1) == -1) {
		return -1;
	}
	if (write_reg(fd, IOB_TIMER_RESET_ADDR, IOB_TIMER_RESET_W, 0) == -1) {
		return -1;
	}
	return 0;
}

uint32_t timer_init(int fd) {
	uint32_t ret = -1;

	ret = timer_reset(fd);
	if (ret == -1) {
		return ret;
	}

	if (write_reg(fd, IOB_TIMER_ENABLE_ADDR, IOB_TIMER_ENABLE_W, 1) == -1) {
		return -1;
	}
	return 0;
}

uint64_t timer_get_count(int fd) {
	uint32_t ret = -1;
	uint32_t data = 0;
	uint64_t count = 0;

	// Sample timer counter
	if (write_reg(fd, IOB_TIMER_SAMPLE_ADDR, IOB_TIMER_SAMPLE_W, 1) == -1) {
		return -1;
	}
	if (write_reg(fd, IOB_TIMER_SAMPLE_ADDR, IOB_TIMER_SAMPLE_W, 0) == -1) {
		return -1;
	}

	// Read sampled timer counter
	ret = read_reg(fd, IOB_TIMER_DATA_HIGH_ADDR, IOB_TIMER_DATA_HIGH_W, &data);
	if (ret == -1) {
		return -1;
	}
	count = ((uint64_t)data) << IOB_TIMER_DATA_LOW_W;
	ret = read_reg(fd, IOB_TIMER_DATA_LOW_ADDR, IOB_TIMER_DATA_LOW_W, &data);
	if (ret == -1) {
		return -1;
	}
	count |= (uint64_t)data;

	return count;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// Sysfs below

int sysfs_read_file(const char *filename, uint32_t *read_value) {
	// Open file for read
	FILE *file = fopen(filename, "r");
	if (file == NULL) {
		perror("[User] Failed to open the file");
		return -1;
	}

	// Read uint32_t value from file in ASCII
	ssize_t ret = fscanf(file, "%u", read_value);
	if (ret == -1) {
		perror("[User] Failed to read from file");
		fclose(file);
		return -1;
	}

	fclose(file);

	return ret;
}

int sysfs_write_file(const char *filename, uint32_t write_value) {
	// Open file for write
	FILE *file = fopen(filename, "w");
	if (file == NULL) {
		perror("[User] Failed to open the file");
		return -1;
	}

	// Write uint32_t value to file in ASCII
	ssize_t ret = fprintf(file, "%u", write_value);
	if (ret == -1) {
		perror("[User] Failed to write to file");
		fclose(file);
		return -1;
	}

	fclose(file);

	return ret;
}

uint32_t timer_reset_sysfs() {
	if (sysfs_write_file(FILE_RESET, 1) == -1) {
		return -1;
	}
	if (sysfs_write_file(FILE_RESET, 0) == -1) {
		return -1;
	}

	return 0;
}

uint32_t timer_init_sysfs() {
	if (timer_reset_sysfs()) {
		return -1;
	}

	if (sysfs_write_file(FILE_ENABLE, 1) == -1) {
		return -1;
	}

	return 0;
}

uint32_t timer_print_version_sysfs() {
	uint32_t ret = -1;
	uint32_t version = 0;

	ret = sysfs_read_file(FILE_VERSION, &version);
	if (ret == -1) {
		return ret;
	}

	printf("[User] Version: 0x%x\n", version);
	return 0;
}

uint64_t timer_get_count_sysfs() {
	uint32_t ret = -1;
	uint32_t data = 0;
	uint64_t count = 0;

	// Sample timer counter
	if (sysfs_write_file(FILE_SAMPLE, 1) == -1) {
		return -1;
	}
	if (sysfs_write_file(FILE_SAMPLE, 0) == -1) {
		return -1;
	}

	// Read sampled timer counter
	ret = sysfs_read_file(FILE_DATA_HIGH, &data);
	if (ret == -1) {
		return -1;
	}
	count = ((uint64_t)data) << IOB_TIMER_DATA_LOW_W;
	ret = sysfs_read_file(FILE_DATA_LOW, &data);
	if (ret == -1) {
		return -1;
	}
	count |= (uint64_t)data;

	return count;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

int main(int argc, char *argv[]) {
	printf("[User] IOb-Timer application\n");

	////////////////////////////////////////////////////
	// /dev test

	printf("\n[User] /dev test\n");

	int fd = 0;

	// Open device for read and write
	fd = open(DEVICE_FILE, O_RDWR);
	if (fd == -1) {
		perror("[User] Failed to open the device file");
		return EXIT_FAILURE;
	}

	if (timer_init(fd) == -1) {
		perror("[User] Failed to initialize timer");
		close(fd);
		return EXIT_FAILURE;
	}

	if (timer_print_version(fd) == -1) {
		perror("[User] Failed to print version");
		close(fd);
		return EXIT_FAILURE;
	}

	// read current timer count
	uint64_t elapsed = timer_get_count(fd);
	printf("\nExecution time: %lld clock cycles\n", elapsed);

	close(fd);

	////////////////////////////////////////////////////
	// Sysfs test

	printf("\n[User] Sysfs test\n");

	if (timer_init_sysfs()) {
		perror("[User] Failed to initialize timer");

		return EXIT_FAILURE;
	}

	if (timer_print_version_sysfs()) {
		perror("[User] Failed to print version");

		return EXIT_FAILURE;
	}

	// read current timer count
	elapsed = timer_get_count_sysfs();
	printf("\nExecution time: %lld clock cycles\n", elapsed);

	return EXIT_SUCCESS;
}

