/* iob_timer_main.c: driver for iob_timer
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

#include "iob_class/iob_class_utils.h"
#include "iob_timer.h"

static int iob_timer_probe(struct platform_device *);
static int iob_timer_remove(struct platform_device *);

static ssize_t iob_timer_read(struct file *, char __user *, size_t, loff_t *);
static ssize_t iob_timer_write(struct file *, const char __user *, size_t,
                               loff_t *);
static loff_t iob_timer_llseek(struct file *, loff_t, int);
static int iob_timer_open(struct inode *, struct file *);
static int iob_timer_release(struct inode *, struct file *);

static struct iob_data iob_timer_data = {0};
DEFINE_MUTEX(iob_timer_mutex);

#include "iob_timer_sysfs.h"

static const struct file_operations iob_timer_fops = {
    .owner = THIS_MODULE,
    .write = iob_timer_write,
    .read = iob_timer_read,
    .llseek = iob_timer_llseek,
    .open = iob_timer_open,
    .release = iob_timer_release,
};

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

//
// Module init and exit functions
//
static int iob_timer_probe(struct platform_device *pdev) {
  struct resource *res;
  int result = 0;

  if (iob_timer_data.device != NULL) {
    pr_err("[Driver] %s: No more devices allowed!\n", IOB_TIMER_DRIVER_NAME);

    return -ENODEV;
  }

  pr_info("[Driver] %s: probing.\n", IOB_TIMER_DRIVER_NAME);

  // Get the I/O region base address
  res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
  if (!res) {
    pr_err("[Driver]: Failed to get I/O resource!\n");
    result = -ENODEV;
    goto r_get_resource;
  }

  // Request and map the I/O region
  iob_timer_data.regbase = devm_ioremap_resource(&pdev->dev, res);
  if (IS_ERR(iob_timer_data.regbase)) {
    result = PTR_ERR(iob_timer_data.regbase);
    goto r_ioremmap;
  }
  iob_timer_data.regsize = resource_size(res);

  // Alocate char device
  result =
      alloc_chrdev_region(&iob_timer_data.devnum, 0, 1, IOB_TIMER_DRIVER_NAME);
  if (result) {
    pr_err("%s: Failed to allocate device number!\n", IOB_TIMER_DRIVER_NAME);
    goto r_alloc_region;
  }

  cdev_init(&iob_timer_data.cdev, &iob_timer_fops);

  result = cdev_add(&iob_timer_data.cdev, iob_timer_data.devnum, 1);
  if (result) {
    pr_err("%s: Char device registration failed!\n", IOB_TIMER_DRIVER_NAME);
    goto r_cdev_add;
  }

  // Create device class // todo: make a dummy driver just to create and own the
  // class: https://stackoverflow.com/a/16365027/8228163
  if ((iob_timer_data.class =
           class_create(THIS_MODULE, IOB_TIMER_DRIVER_CLASS)) == NULL) {
    printk("Device class can not be created!\n");
    goto r_class;
  }

  // Create device file
  iob_timer_data.device =
      device_create(iob_timer_data.class, NULL, iob_timer_data.devnum, NULL,
                    IOB_TIMER_DRIVER_NAME);
  if (iob_timer_data.device == NULL) {
    printk("Can not create device file!\n");
    goto r_device;
  }

  result = iob_timer_create_device_attr_files(iob_timer_data.device);
  if (result) {
    pr_err("Cannot create device attribute file......\n");
    goto r_dev_file;
  }

  dev_info(&pdev->dev, "initialized.\n");
  goto r_ok;

r_dev_file:
  iob_timer_remove_device_attr_files(&iob_timer_data);
r_device:
  class_destroy(iob_timer_data.class);
r_class:
  cdev_del(&iob_timer_data.cdev);
r_cdev_add:
  unregister_chrdev_region(iob_timer_data.devnum, 1);
r_alloc_region:
  // iounmap is managed by devm
r_ioremmap:
r_get_resource:
r_ok:

  return result;
}

static int iob_timer_remove(struct platform_device *pdev) {
  iob_timer_remove_device_attr_files(&iob_timer_data);
  class_destroy(iob_timer_data.class);
  cdev_del(&iob_timer_data.cdev);
  unregister_chrdev_region(iob_timer_data.devnum, 1);
  // Note: no need for iounmap, since we are using devm_ioremap_resource()

  dev_info(&pdev->dev, "exiting.\n");

  return 0;
}

static int __init test_counter_init(void) {
  pr_info("[Driver] %s: initializing.\n", IOB_TIMER_DRIVER_NAME);

  return platform_driver_register(&iob_timer_driver);
}

static void __exit test_counter_exit(void) {
  pr_info("[Driver] %s: exiting.\n", IOB_TIMER_DRIVER_NAME);
  platform_driver_unregister(&iob_timer_driver);
}

//
// File operations
//

static int iob_timer_open(struct inode *inode, struct file *file) {
  pr_info("[Driver] iob_timer device opened\n");

  if (!mutex_trylock(&iob_timer_mutex)) {
    pr_info("Another process is accessing the device\n");

    return -EBUSY;
  }

  return 0;
}

static int iob_timer_release(struct inode *inode, struct file *file) {
  pr_info("[Driver] iob_timer device closed\n");

  mutex_unlock(&iob_timer_mutex);

  return 0;
}

static ssize_t iob_timer_read(struct file *file, char __user *buf, size_t count,
                              loff_t *ppos) {
  int size = 0;
  u32 value = 0;

  /* read value from register */
  switch (*ppos) {
  case IOB_TIMER_DATA_LOW_ADDR:
    value = iob_data_read_reg(iob_timer_data.regbase, IOB_TIMER_DATA_LOW_ADDR,
                              IOB_TIMER_DATA_LOW_W);
    size = (IOB_TIMER_DATA_LOW_W >> 3); // bit to bytes
    pr_info("[Driver] Read data low!\n");
    break;
  case IOB_TIMER_DATA_HIGH_ADDR:
    value = iob_data_read_reg(iob_timer_data.regbase, IOB_TIMER_DATA_HIGH_ADDR,
                              IOB_TIMER_DATA_HIGH_W);
    size = (IOB_TIMER_DATA_HIGH_W >> 3); // bit to bytes
    pr_info("[Driver] Read data high!\n");
    break;
  case IOB_TIMER_VERSION_ADDR:
    value = iob_data_read_reg(iob_timer_data.regbase, IOB_TIMER_VERSION_ADDR,
                              IOB_TIMER_VERSION_W);
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

  return count;
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
    iob_data_write_reg(iob_timer_data.regbase, value, IOB_TIMER_RESET_ADDR,
                       IOB_TIMER_RESET_W);
    pr_info("[Driver] Reset iob_timer: 0x%x\n", value);
    break;
  case IOB_TIMER_ENABLE_ADDR:
    size = (IOB_TIMER_ENABLE_W >> 3); // bit to bytes
    if (read_user_data(buf, size, &value))
      return -EFAULT;
    iob_data_write_reg(iob_timer_data.regbase, value, IOB_TIMER_ENABLE_ADDR,
                       IOB_TIMER_ENABLE_W);
    pr_info("[Driver] Enable iob_timer: 0x%x\n", value);
    break;
  case IOB_TIMER_SAMPLE_ADDR:         // sample counter
    size = (IOB_TIMER_SAMPLE_W >> 3); // bit to bytes
    if (read_user_data(buf, size, &value))
      return -EFAULT;
    iob_data_write_reg(iob_timer_data.regbase, value, IOB_TIMER_SAMPLE_ADDR,
                       IOB_TIMER_SAMPLE_W);
    pr_info("[Driver] Sample iob_timer: 0x%x\n", value);
    break;
  default:
    pr_info("[Driver] Invalid write address 0x%x\n", (unsigned int)*ppos);
    // invalid address - no bytes written
    return 0;
  }

  return count;
}

/* Custom lseek function
 * check: lseek(2) man page for whence modes
 */
static loff_t iob_timer_llseek(struct file *filp, loff_t offset, int whence) {
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

module_init(test_counter_init);
module_exit(test_counter_exit);

MODULE_LICENSE("Dual MIT/GPL");
MODULE_AUTHOR("IObundle");
MODULE_DESCRIPTION("IOb-Timer Drivers");
MODULE_VERSION("0.10");
