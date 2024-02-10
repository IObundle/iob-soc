/* iob_timer.c: driver for iob_timer
 * using device platform. No hardcoded hardware address:
 * 1. load driver: insmod iob_timer.ko
 * 2. run user app: ./user/user
 */

#include <linux/cdev.h>
#include <linux/fs.h>
#include <linux/io.h>
#include <linux/ioport.h>
#include <linux/kernel.h>
#include <linux/mod_devicetable.h>
#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/uaccess.h>

#include "iob_timer.h"

static struct {
  dev_t devnum;
  struct cdev cdev;
  void __iomem *regbase;
  resource_size_t regsize;
  struct class *timer_class;
} iob_timer_data;

static u32 iob_timer_read_reg(u32 addr, u32 nbits) {
  u32 value = 0;
  switch (nbits) {
  case 8:
    value = (u32)ioread8(iob_timer_data.regbase + addr);
    break;
  case 16:
    value = (u32)ioread16(iob_timer_data.regbase + addr);
    break;
  default:
    value = ioread32(iob_timer_data.regbase + addr);
    break;
  }
  return value;
}

static void iob_timer_write_reg(u32 value, u32 addr, u32 nbits) {
  switch (nbits) {
  case 8:
    iowrite8(value, iob_timer_data.regbase + addr);
    break;
  case 16:
    iowrite16(value, iob_timer_data.regbase + addr);
    break;
  default:
    iowrite32(value, iob_timer_data.regbase + addr);
    break;
  }
}

static ssize_t iob_timer_read(struct file *file, char __user *buf, size_t count,
                              loff_t *ppos) {
  int size = 0;
  u32 value = 0;

  /* read value from register */
  switch (*ppos) {
  case IOB_TIMER_DATA_LOW_ADDR:
    value = iob_timer_read_reg(IOB_TIMER_DATA_LOW_ADDR, IOB_TIMER_DATA_LOW_W);
    size = (IOB_TIMER_DATA_LOW_W >> 3); // bit to bytes
    pr_info("[Driver] Read data low!\n");
    break;
  case IOB_TIMER_DATA_HIGH_ADDR:
    value = iob_timer_read_reg(IOB_TIMER_DATA_HIGH_ADDR, IOB_TIMER_DATA_HIGH_W);
    size = (IOB_TIMER_DATA_HIGH_W >> 3); // bit to bytes
    pr_info("[Driver] Read data high!\n");
    break;
  case IOB_TIMER_VERSION_ADDR:
    value = iob_timer_read_reg(IOB_TIMER_VERSION_ADDR, IOB_TIMER_VERSION_W);
    size = (IOB_TIMER_VERSION_W >> 3); // bit to bytes
    pr_info("[Driver] Read version!\n");
    break;
  default:
    // invalid address - no bytes read
    return 0;
  }

  // Read min between count and REG_SIZE
  if (size > count)
    size = count;

  if (copy_to_user(buf, &value, size))
    return -EFAULT;
  *ppos += size;

  return size;
}

/* read 1-4 bytes from char array into u32
 * NOTE: assumes bytes[] at least nbytes long
 * */
static u32 char_to_u32(char *bytes, u32 nbytes) {
  u32 value = 0;
  while (nbytes--) {
    value = (value << 8) | ((u32)bytes[nbytes]);
  }
  return value;
}

/* read `size` bytes from user `buf` into `value`
 * return 0 on success, -EFAULT on error
 */
static int read_user_data(const char *buf, int size, u32 *value) {
  char kbuf[4] = {0}; // max 32 bit value
  if (copy_from_user(&kbuf, buf, size))
    return -EFAULT;
  *value = char_to_u32(kbuf, size);
  return 0;
}

static ssize_t iob_timer_write(struct file *file, const char __user *buf,
                               size_t count, loff_t *ppos) {
  int size = 0;
  u32 value = 0;

  switch (*ppos) {
  case IOB_TIMER_RESET_ADDR:
    size = (IOB_TIMER_RESET_W >> 3); // bit to bytes
    if (read_user_data(buf, size, &value))
      return -EFAULT;
    iob_timer_write_reg(value, IOB_TIMER_RESET_ADDR, IOB_TIMER_RESET_W);
    pr_info("[Driver] Reset iob_timer: 0x%x\n", value);
    break;
  case IOB_TIMER_ENABLE_ADDR:
    size = (IOB_TIMER_ENABLE_W >> 3); // bit to bytes
    if (read_user_data(buf, size, &value))
      return -EFAULT;
    iob_timer_write_reg(value, IOB_TIMER_ENABLE_ADDR, IOB_TIMER_ENABLE_W);
    pr_info("[Driver] Enable iob_timer: 0x%x\n", value);
    break;
  case IOB_TIMER_SAMPLE_ADDR:         // sample counter
    size = (IOB_TIMER_SAMPLE_W >> 3); // bit to bytes
    if (read_user_data(buf, size, &value))
      return -EFAULT;
    iob_timer_write_reg(value, IOB_TIMER_SAMPLE_ADDR, IOB_TIMER_SAMPLE_W);
    pr_info("[Driver] Sample iob_timer: 0x%x\n", value);
    break;
  default:
    pr_info("[Driver] Invalid write address 0x%x\n", (unsigned int)*ppos);
    // invalid address - no bytes written
    return 0;
  }

  return size;
}

/* Custom lseek function
 * check: lseek(2) man page for whence modes
 */
loff_t iob_timer_llseek(struct file *filp, loff_t offset, int whence) {
  loff_t new_pos = -1;

  switch (whence) {
  case SEEK_SET:
    new_pos = offset;
    break;
  case SEEK_CUR:
    new_pos = filp->f_pos + offset;
    break;
  case SEEK_END:
    new_pos = (1 << IOB_TIMER_SWREG_ADDR_W) + offset;
    break;
  default:
    return -EINVAL;
  }

  // Check for valid bounds
  if (new_pos < 0 || new_pos > iob_timer_data.regsize) {
    return -EINVAL;
  }

  // Update file position
  filp->f_pos = new_pos;

  return new_pos;
}

static const struct file_operations iob_timer_fops = {
    .owner = THIS_MODULE,
    .write = iob_timer_write,
    .read = iob_timer_read,
    .llseek = iob_timer_llseek,
};

static int iob_timer_probe(struct platform_device *pdev) {
  struct resource *res;
  int result = 0;

  pr_info("[Driver] %s: probing.\n", IOB_TIMER_DRIVER_NAME);

  // Get the I/O region base address
  res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
  if (!res) {
    pr_err("[Driver]: Failed to get I/O resource!\n");
    result = -ENODEV;
    goto ret_platform_get_resource;
  }

  // Request and map the I/O region
  iob_timer_data.regbase = devm_ioremap_resource(&pdev->dev, res);
  if (IS_ERR(iob_timer_data.regbase)) {
    result = PTR_ERR(iob_timer_data.regbase);
    goto ret_devm_ioremmap_resource;
  }
  iob_timer_data.regsize = resource_size(res);

  // Alocate char device
  result =
      alloc_chrdev_region(&iob_timer_data.devnum, 0, 1, IOB_TIMER_DRIVER_NAME);
  if (result) {
    pr_err("%s: Failed to allocate device number!\n", IOB_TIMER_DRIVER_NAME);
    goto ret_err_alloc_chrdev_region;
  }

  // Create device class
  if ((iob_timer_data.timer_class =
           class_create(THIS_MODULE, IOB_TIMER_DRIVER_NAME)) == NULL) {
    printk("Device class can not be created!\n");
    goto class_error;
  }

  // create device file
  if (device_create(iob_timer_data.timer_class, NULL, iob_timer_data.devnum,
                    NULL, IOB_TIMER_DRIVER_NAME) == NULL) {
    printk("Can not create device file!\n");
    goto file_error;
  }

  cdev_init(&iob_timer_data.cdev, &iob_timer_fops);

  result = cdev_add(&iob_timer_data.cdev, iob_timer_data.devnum, 1);
  if (result) {
    pr_err("%s: Char device registration failed!\n", IOB_TIMER_DRIVER_NAME);
    goto ret_err_cdev_add;
  }

  dev_info(&pdev->dev, "initialized.\n");
  goto ret_ok;

ret_err_cdev_add:
  device_destroy(iob_timer_data.timer_class, iob_timer_data.devnum);
file_error:
  class_destroy(iob_timer_data.timer_class);
class_error:
  unregister_chrdev_region(iob_timer_data.devnum, 1);
ret_err_alloc_chrdev_region:
  // iounmap is managed by devm
ret_devm_ioremmap_resource:
ret_platform_get_resource:
ret_ok:
  return result;
}

static int iob_timer_remove(struct platform_device *pdev) {
  // Note: no need for iounmap, since we are using devm_ioremap_resource()
  device_destroy(iob_timer_data.timer_class, iob_timer_data.devnum);
  class_destroy(iob_timer_data.timer_class);
  cdev_del(&iob_timer_data.cdev);
  unregister_chrdev_region(iob_timer_data.devnum, 1);
  dev_info(&pdev->dev, "exiting.\n");
  return 0;
}

static const struct of_device_id of_iob_timer_match[] = {
    {.compatible = "iobundle,timer0"},
    {},
};

static struct platform_driver iob_timer_driver = {
    .driver =
        {
            .name = "iob_timer",
            .owner = THIS_MODULE,
            .of_match_table = of_iob_timer_match,
        },
    .probe = iob_timer_probe,
    .remove = iob_timer_remove,
};

/* Replaces module_init() and module_exit() */
module_platform_driver(iob_timer_driver);

MODULE_LICENSE("Dual MIT/GPL");
MODULE_AUTHOR("IObundle");
MODULE_DESCRIPTION("IOb-Timer Drivers");
MODULE_VERSION("0.10");
