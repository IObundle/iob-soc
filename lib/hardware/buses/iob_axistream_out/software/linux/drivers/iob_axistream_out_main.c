/*
 * SPDX-FileCopyrightText: 2024 IObundle
 *
 * SPDX-License-Identifier: MIT
 */

/* iob_axistream_out_main.c: driver for iob_axistream_out
 * using device platform. No hardcoded hardware address:
 * 1. load driver: insmod iob_axistream_out.ko
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

#include "iob_axistream_out.h"
#include "iob_class/iob_class_utils.h"

static int iob_axistream_out_probe(struct platform_device *);
static int iob_axistream_out_remove(struct platform_device *);

static ssize_t iob_axistream_out_read(struct file *, char __user *, size_t,
                                      loff_t *);
static ssize_t iob_axistream_out_write(struct file *, const char __user *,
                                       size_t, loff_t *);
static loff_t iob_axistream_out_llseek(struct file *, loff_t, int);
static int iob_axistream_out_open(struct inode *, struct file *);
static int iob_axistream_out_release(struct inode *, struct file *);

static struct iob_data iob_axistream_out_data = {0};
DEFINE_MUTEX(iob_axistream_out_mutex);

#include "iob_axistream_out_sysfs.h"

static const struct file_operations iob_axistream_out_fops = {
    .owner = THIS_MODULE,
    .write = iob_axistream_out_write,
    .read = iob_axistream_out_read,
    .llseek = iob_axistream_out_llseek,
    .open = iob_axistream_out_open,
    .release = iob_axistream_out_release,
};

static const struct of_device_id of_iob_axistream_out_match[] = {
    {.compatible = "iobundle,axistream_out0"},
    {},
};

static struct platform_driver iob_axistream_out_driver = {
    .driver =
        {
            .name = "iob_axistream_out",
            .owner = THIS_MODULE,
            .of_match_table = of_iob_axistream_out_match,
        },
    .probe = iob_axistream_out_probe,
    .remove = iob_axistream_out_remove,
};

//
// Module init and exit functions
//
static int iob_axistream_out_probe(struct platform_device *pdev) {
  struct resource *res;
  int result = 0;

  if (iob_axistream_out_data.device != NULL) {
    pr_err("[Driver] %s: No more devices allowed!\n",
           IOB_AXISTREAM_OUT_DRIVER_NAME);

    return -ENODEV;
  }

  pr_info("[Driver] %s: probing.\n", IOB_AXISTREAM_OUT_DRIVER_NAME);

  // Get the I/O region base address
  res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
  if (!res) {
    pr_err("[Driver]: Failed to get I/O resource!\n");
    result = -ENODEV;
    goto r_get_resource;
  }

  // Request and map the I/O region
  iob_axistream_out_data.regbase = devm_ioremap_resource(&pdev->dev, res);
  if (IS_ERR(iob_axistream_out_data.regbase)) {
    result = PTR_ERR(iob_axistream_out_data.regbase);
    goto r_ioremmap;
  }
  iob_axistream_out_data.regsize = resource_size(res);

  // Alocate char device
  result = alloc_chrdev_region(&iob_axistream_out_data.devnum, 0, 1,
                               IOB_AXISTREAM_OUT_DRIVER_NAME);
  if (result) {
    pr_err("%s: Failed to allocate device number!\n",
           IOB_AXISTREAM_OUT_DRIVER_NAME);
    goto r_alloc_region;
  }

  cdev_init(&iob_axistream_out_data.cdev, &iob_axistream_out_fops);

  result =
      cdev_add(&iob_axistream_out_data.cdev, iob_axistream_out_data.devnum, 1);
  if (result) {
    pr_err("%s: Char device registration failed!\n",
           IOB_AXISTREAM_OUT_DRIVER_NAME);
    goto r_cdev_add;
  }

  // Create device class // todo: make a dummy driver just to create and own the
  // class: https://stackoverflow.com/a/16365027/8228163
  if ((iob_axistream_out_data.class =
           class_create(THIS_MODULE, IOB_AXISTREAM_OUT_DRIVER_CLASS)) == NULL) {
    printk("Device class can not be created!\n");
    goto r_class;
  }

  // Create device file
  iob_axistream_out_data.device = device_create(
      iob_axistream_out_data.class, NULL, iob_axistream_out_data.devnum, NULL,
      IOB_AXISTREAM_OUT_DRIVER_NAME);
  if (iob_axistream_out_data.device == NULL) {
    printk("Can not create device file!\n");
    goto r_device;
  }

  result =
      iob_axistream_out_create_device_attr_files(iob_axistream_out_data.device);
  if (result) {
    pr_err("Cannot create device attribute file......\n");
    goto r_dev_file;
  }

  dev_info(&pdev->dev, "initialized.\n");
  goto r_ok;

r_dev_file:
  iob_axistream_out_remove_device_attr_files(&iob_axistream_out_data);
r_device:
  class_destroy(iob_axistream_out_data.class);
r_class:
  cdev_del(&iob_axistream_out_data.cdev);
r_cdev_add:
  unregister_chrdev_region(iob_axistream_out_data.devnum, 1);
r_alloc_region:
  // iounmap is managed by devm
r_ioremmap:
r_get_resource:
r_ok:

  return result;
}

static int iob_axistream_out_remove(struct platform_device *pdev) {
  iob_axistream_out_remove_device_attr_files(&iob_axistream_out_data);
  class_destroy(iob_axistream_out_data.class);
  cdev_del(&iob_axistream_out_data.cdev);
  unregister_chrdev_region(iob_axistream_out_data.devnum, 1);
  // Note: no need for iounmap, since we are using devm_ioremap_resource()

  dev_info(&pdev->dev, "exiting.\n");

  return 0;
}

static int __init iob_axistream_out_init(void) {
  pr_info("[Driver] %s: initializing.\n", IOB_AXISTREAM_OUT_DRIVER_NAME);

  return platform_driver_register(&iob_axistream_out_driver);
}

static void __exit iob_axistream_out_exit(void) {
  pr_info("[Driver] %s: exiting.\n", IOB_AXISTREAM_OUT_DRIVER_NAME);
  platform_driver_unregister(&iob_axistream_out_driver);
}

//
// File operations
//

static int iob_axistream_out_open(struct inode *inode, struct file *file) {
  pr_info("[Driver] iob_axistream_out device opened\n");

  if (!mutex_trylock(&iob_axistream_out_mutex)) {
    pr_info("Another process is accessing the device\n");

    return -EBUSY;
  }

  return 0;
}

static int iob_axistream_out_release(struct inode *inode, struct file *file) {
  pr_info("[Driver] iob_axistream_out device closed\n");

  mutex_unlock(&iob_axistream_out_mutex);

  return 0;
}

static ssize_t iob_axistream_out_read(struct file *file, char __user *buf,
                                      size_t count, loff_t *ppos) {
  int size = 0;
  u32 value = 0;

  /* read value from register */
  switch (*ppos) {
  case IOB_AXISTREAM_OUT_FIFO_FULL_ADDR:
    value = iob_data_read_reg(iob_axistream_out_data.regbase,
                              IOB_AXISTREAM_OUT_FIFO_FULL_ADDR,
                              IOB_AXISTREAM_OUT_FIFO_FULL_W);
    size = (IOB_AXISTREAM_OUT_FIFO_FULL_W >> 3); // bit to bytes
    pr_info("[Driver] Read FIFO_FULL!\n");
    break;
  case IOB_AXISTREAM_OUT_FIFO_EMPTY_ADDR:
    value = iob_data_read_reg(iob_axistream_out_data.regbase,
                              IOB_AXISTREAM_OUT_FIFO_EMPTY_ADDR,
                              IOB_AXISTREAM_OUT_FIFO_EMPTY_W);
    size = (IOB_AXISTREAM_OUT_FIFO_EMPTY_W >> 3); // bit to bytes
    pr_info("[Driver] Read FIFO_EMPTY!\n");
    break;
  case IOB_AXISTREAM_OUT_FIFO_LEVEL_ADDR:
    value = iob_data_read_reg(iob_axistream_out_data.regbase,
                              IOB_AXISTREAM_OUT_FIFO_LEVEL_ADDR,
                              IOB_AXISTREAM_OUT_FIFO_LEVEL_W);
    size = (IOB_AXISTREAM_OUT_FIFO_LEVEL_W >> 3); // bit to bytes
    pr_info("[Driver] Read FIFO_LEVEL!\n");
    break;
  case IOB_AXISTREAM_OUT_VERSION_ADDR:
    value = iob_data_read_reg(iob_axistream_out_data.regbase,
                              IOB_AXISTREAM_OUT_VERSION_ADDR,
                              IOB_AXISTREAM_OUT_VERSION_W);
    size = (IOB_AXISTREAM_OUT_VERSION_W >> 3); // bit to bytes
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

static ssize_t iob_axistream_out_write(struct file *file,
                                       const char __user *buf, size_t count,
                                       loff_t *ppos) {
  int size = 0;
  u32 value = 0;

  switch (*ppos) {
  case IOB_AXISTREAM_OUT_SOFT_RESET_ADDR:
    size = (IOB_AXISTREAM_OUT_SOFT_RESET_W >> 3); // bit to bytes
    if (read_user_data(buf, size, &value))
      return -EFAULT;
    iob_data_write_reg(iob_axistream_out_data.regbase, value,
                       IOB_AXISTREAM_OUT_SOFT_RESET_ADDR,
                       IOB_AXISTREAM_OUT_SOFT_RESET_W);
    pr_info("[Driver] SOFT_RESET iob_axistream_out: 0x%x\n", value);
    break;
  case IOB_AXISTREAM_OUT_ENABLE_ADDR:
    size = (IOB_AXISTREAM_OUT_ENABLE_W >> 3); // bit to bytes
    if (read_user_data(buf, size, &value))
      return -EFAULT;
    iob_data_write_reg(iob_axistream_out_data.regbase, value,
                       IOB_AXISTREAM_OUT_ENABLE_ADDR,
                       IOB_AXISTREAM_OUT_ENABLE_W);
    pr_info("[Driver] ENABLE iob_axistream_out: 0x%x\n", value);
    break;
  case IOB_AXISTREAM_OUT_DATA_ADDR:
    size = (IOB_AXISTREAM_OUT_DATA_W >> 3); // bit to bytes
    if (read_user_data(buf, size, &value))
      return -EFAULT;
    iob_data_write_reg(iob_axistream_out_data.regbase, value,
                       IOB_AXISTREAM_OUT_DATA_ADDR, IOB_AXISTREAM_OUT_DATA_W);
    pr_info("[Driver] DATA iob_axistream_out: 0x%x\n", value);
    break;
  case IOB_AXISTREAM_OUT_MODE_ADDR:
    size = (IOB_AXISTREAM_OUT_MODE_W >> 3); // bit to bytes
    if (read_user_data(buf, size, &value))
      return -EFAULT;
    iob_data_write_reg(iob_axistream_out_data.regbase, value,
                       IOB_AXISTREAM_OUT_MODE_ADDR, IOB_AXISTREAM_OUT_MODE_W);
    pr_info("[Driver] MODE iob_axistream_out: 0x%x\n", value);
    break;
  case IOB_AXISTREAM_OUT_NWORDS_ADDR:
    size = (IOB_AXISTREAM_OUT_NWORDS_W >> 3); // bit to bytes
    if (read_user_data(buf, size, &value))
      return -EFAULT;
    iob_data_write_reg(iob_axistream_out_data.regbase, value,
                       IOB_AXISTREAM_OUT_NWORDS_ADDR,
                       IOB_AXISTREAM_OUT_NWORDS_W);
    pr_info("[Driver] NWORDS iob_axistream_out: 0x%x\n", value);
    break;
  case IOB_AXISTREAM_OUT_FIFO_THRESHOLD_ADDR:
    size = (IOB_AXISTREAM_OUT_FIFO_THRESHOLD_W >> 3); // bit to bytes
    if (read_user_data(buf, size, &value))
      return -EFAULT;
    iob_data_write_reg(iob_axistream_out_data.regbase, value,
                       IOB_AXISTREAM_OUT_FIFO_THRESHOLD_ADDR,
                       IOB_AXISTREAM_OUT_FIFO_THRESHOLD_W);
    pr_info("[Driver] FIFO_THRESHOLD iob_axistream_out: 0x%x\n", value);
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
static loff_t iob_axistream_out_llseek(struct file *filp, loff_t offset,
                                       int whence) {
  loff_t new_pos = -1;

  switch (whence) {
  case SEEK_SET:
    new_pos = offset;
    break;
  case SEEK_CUR:
    new_pos = filp->f_pos + offset;
    break;
  case SEEK_END:
    new_pos = (1 << IOB_AXISTREAM_OUT_CSRS_ADDR_W) + offset;
    break;
  default:
    return -EINVAL;
  }

  // Check for valid bounds
  if (new_pos < 0 || new_pos > iob_axistream_out_data.regsize) {
    return -EINVAL;
  }

  // Update file position
  filp->f_pos = new_pos;

  return new_pos;
}

module_init(iob_axistream_out_init);
module_exit(iob_axistream_out_exit);

MODULE_LICENSE("Dual MIT/GPL");
MODULE_AUTHOR("IObundle");
MODULE_DESCRIPTION("IOb-AXISTREAM-OUT Drivers");
MODULE_VERSION("0.10");
