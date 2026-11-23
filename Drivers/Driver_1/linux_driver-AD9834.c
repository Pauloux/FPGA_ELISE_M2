/*
 * Author: Paul ROUSSEAU
 * Date: november 2026
 *
 * To read a value:
 * sudo cat /sys/devices/platform/AD9834.0/frequency
 * To write a value:
 * echo "1000000" | sudo tee /sys/devices/platform/AD9834.0/frequency
 */

#include <linux/module.h>	// For all modules
#include <linux/kernel.h>	// For KERN_INFO
#include <linux/platform_device.h>	// For devices and drivers
#include <linux/ioport.h>       // For request_mem
#include <linux/io.h>           // For ioremap and writel
#include <linux/delay.h>	// For sleep

#define DDS_CLOCK_HZ 56000000	// 70 MHz by default but depends on the board
#define DDS_INCREMENT_SIZE 28
#define DDS_COMMAND_PREFIX 0b01	// FREQ0
#define DDS_COMMAND_INIT 0x2200

#define BASE_ADDRESS 0x41200000
#define MEMORY_REGION_SIZE 0x120
#define OFFSET_FREQ_DIR 0x4
#define OFFSET_FREQ_DATA 0x0
#define OFFSET_BUTTON_DIR 0xC
#define OFFSET_BUTTON_DATA 0x8

// Driver
static int driver_probe (struct platform_device *pdev);
static void driver_remove (struct platform_device *pdev);
// Device
static int __init my_device_init(void);
static void __exit my_device_exit(void);

// https://elixir.bootlin.com/linux/v7.0/source/include/linux/device.h#L123
ssize_t show1 (struct device *dev, struct device_attribute *attr, char *buf);
ssize_t store1 (struct device *dev, struct device_attribute *attr,
	const char *buf, size_t count);

// Custom functions
uint32_t get_increment (uint32_t f_out);
uint32_t get_MSWORD (uint32_t increment);
uint32_t get_LSWORD (uint32_t increment);
void DDS_send_word (uint32_t word);
void DDS_send_data (uint32_t increment);

void __iomem *mem_region;

// https://elixir.bootlin.com/linux/v7.0/source/include/linux/platform_device.h#L23
static struct platform_device *pdev;

// https://elixir.bootlin.com/linux/v7.0/source/include/linux/device.h#L157
// Creates a struct device_attribute named dev_attr_##_name (##_name is the
// 	first argument of DEVICE_ATTR)
static DEVICE_ATTR(frequency, 0660, show1, store1);

// https://elixir.bootlin.com/linux/v7.0/source/include/linux/platform_device.h#L234
static struct platform_driver platform_drv = {
	.probe = driver_probe,
	.remove = driver_remove,
	.driver = {
		.name = "AD9834"
	},
};

uint32_t target_freq = 0;	// Hz

static int driver_probe (struct platform_device *pdev)
{
	printk(KERN_INFO "AD9834 driver - Probe\n");

	// https://elixir.bootlin.com/linux/v7.0/source/drivers/base/core.c#L3043
	// Create communication pseudo-file
	device_create_file(&pdev->dev, &dev_attr_frequency);

	// https://elixir.bootlin.com/linux/v7.0/source/include/linux/ioport.h#L359
	if ((request_mem_region(BASE_ADDRESS, MEMORY_REGION_SIZE, "AD9834 mem"))
		== NULL) {
		printk(KERN_ERR "Error when requesting memory\
			(request_mem_region)\n");

		return -EBUSY;
	}
	else {
		// https://elixir.bootlin.com/linux/v7.0/source/arch/x86/mm/ioremap.c#L343
		mem_region = ioremap(BASE_ADDRESS, MEMORY_REGION_SIZE);
		if (mem_region == NULL) {
			printk(KERN_ERR "Error when requesting memory (ioremap)\
				\n");

			// Release memory region we just requested
			release_mem_region(BASE_ADDRESS, MEMORY_REGION_SIZE);

			return -ENOMEM;
		}

		// Declare ports as output
		// https://elixir.bootlin.com/linux/v7.0/source/arch/alpha/include/asm/io.h#L528
		writel(0xFFFFFFF, mem_region + OFFSET_FREQ_DIR);
		writel(0x1, mem_region + OFFSET_BUTTON_DIR);

		// Make sure the button is not pressed (inverted logic)
		printk(KERN_INFO "AD9834 driver - Send %u at offset %u\n", 0x1,\
			OFFSET_BUTTON_DATA);
		writel(0x1, mem_region + OFFSET_BUTTON_DATA);

		// Configure DDS
		DDS_send_word(DDS_COMMAND_INIT);

		printk(KERN_INFO "AD9834 driver - Initilization finished\n");
	}

	return 0;
}

static void driver_remove (struct platform_device *pdev)
{
	printk(KERN_INFO "AD9834 driver - Remove\n");

	// https://elixir.bootlin.com/linux/v7.0/source/arch/x86/mm/ioremap.c#L456
	iounmap(mem_region);

	// https://elixir.bootlin.com/linux/v7.0/source/include/linux/ioport.h#L373
	release_mem_region(BASE_ADDRESS, MEMORY_REGION_SIZE);

	// https://elixir.bootlin.com/linux/v7.0/source/drivers/base/core.c#L3067
	// Remove communication pseudo-file
	device_remove_file(&pdev->dev, &dev_attr_frequency);
}

static int __init my_device_init(void)
{
	int ret;

	printk(KERN_INFO "AD9834 driver - Init\n");

	// https://elixir.bootlin.com/linux/v7.0/source/include/linux/platform_device.h#L259
	// and
	// https://elixir.bootlin.com/linux/v7.0/source/drivers/base/platform.c#L901
	// and
	// https://elixir.bootlin.com/linux/v7.0/source/drivers/base/driver.c#L225
	ret = platform_driver_register(&platform_drv);
	if (ret < 0) {
		printk(KERN_ERR "Error when registering the driver\n");
		return ret;
	}
	
	// https://elixir.bootlin.com/linux/v7.0/source/include/linux/platform_device.h#L169
	pdev = platform_device_register_simple("AD9834",
		0, NULL, 0);
	if (IS_ERR(pdev)) {
		printk(KERN_ERR "Error when registering the device\n");

		// Remove the driver that have been registered just before
		platform_driver_unregister(&platform_drv);

		return PTR_ERR(pdev);
	}

	return 0;
}

static void __exit my_device_exit(void)
{
	printk(KERN_INFO "AD9834 driver - Exit\n");

	// https://elixir.bootlin.com/linux/v7.0/source/drivers/base/platform.c#L831
	platform_device_unregister(pdev);

	// https://elixir.bootlin.com/linux/v7.0/source/drivers/base/platform.c#L915
	platform_driver_unregister(&platform_drv);
}

ssize_t show1 (struct device *dev, struct device_attribute *attr, char
	*buf)
{
	return sprintf(buf, "Target DDS frequency is %u Hz\n", target_freq);
}

ssize_t store1 (struct device *dev, struct device_attribute *attr,
	const char *buf, size_t count)
{
	int ret;
	uint32_t increment;

	ret = sscanf(buf, "%u", &target_freq);
	if (ret != 1) {
		printk(KERN_ERR "Error when storing data: %s\n", buf);
		return -EINVAL;
	}

	increment = get_increment(target_freq);
	printk(KERN_INFO "AD9834 driver - Increment = %u\n", increment);

	if (increment != 0) {
		DDS_send_data(increment);
	}

	return count;
}

uint32_t get_increment (uint32_t f_out)
{
	// increment = 2^n * f_out / f_clk
	uint64_t tmp = (1ULL << DDS_INCREMENT_SIZE) * f_out;
	// https://elixir.bootlin.com/linux/v7.0/source/include/asm-generic/div64.h#L31
	do_div(tmp, DDS_CLOCK_HZ);
	return (uint32_t) tmp;
}

uint32_t get_MSWORD (uint32_t increment)
{
	return ((DDS_COMMAND_PREFIX << 14) | ((increment >> 14) & 0x3FFF));
}

uint32_t get_LSWORD (uint32_t increment)
{
	return ((DDS_COMMAND_PREFIX << 14) | (increment & 0x3FFF));
}

void DDS_send_word (uint32_t word)
{
	// https://elixir.bootlin.com/linux/v7.0/source/arch/alpha/include/asm/io.h#L528
	// Send first word
	printk(KERN_INFO "AD9834 driver - Send %u at offset %u\n", word,\
		OFFSET_FREQ_DATA);
	writel(word, mem_region + OFFSET_FREQ_DATA);
	udelay(100);

	// Button press
	printk(KERN_INFO "AD9834 driver - Send %u at offset %u\n", 0x0,\
		OFFSET_BUTTON_DATA);
	writel(0x0, mem_region + OFFSET_BUTTON_DATA);
	udelay(1000);
	
	// Button release
	printk(KERN_INFO "AD9834 driver - Send %u at offset %u\n", 0x1,\
		OFFSET_BUTTON_DATA);
	writel(0x1, mem_region + OFFSET_BUTTON_DATA);
	udelay(100);
}

void DDS_send_data (uint32_t increment)
{
	DDS_send_word(get_LSWORD(increment));
	DDS_send_word(get_MSWORD(increment));
}

module_init(my_device_init);
module_exit(my_device_exit);

MODULE_DESCRIPTION("AD9834 (DDS) driver via the PL of the Red Pitaya");
MODULE_LICENSE("GPL");
