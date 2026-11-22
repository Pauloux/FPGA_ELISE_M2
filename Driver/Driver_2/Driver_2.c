/* dds_driver.c — un seul module, un seul device
 * insmod dds_driver.ko
 * echo 1090000 > /sys/bus/platform/devices/dds_ad9834.0/frequency
 * echo trig    > /sys/bus/platform/devices/dds_ad9834.0/waveform
 * rmmod dds_driver
 */
#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/io.h>
#include <linux/delay.h>
#include <linux/math64.h>
#include <linux/string.h>

#define DDS_PHYS 0x41200000
#define DDS_DATA 0x00
#define DDS_DATA_DIR 0x04
#define DDS_START 0x08
#define DDS_START_DIR 0x0C
#define MASTER_CLOCK 56537411

static void __iomem *base;
static u32 freq_hz;
static u32 increment;
static u16 ctrl = 0x2200;

static struct platform_device *pdev;

static void dds_frame(u16 word)
{
	printk(KERN_INFO "dds_frame: 0x%04x\n", word);
	/* Écrit le mot dans le registre de données */
	writel(word, base + DDS_DATA);
	udelay(100);
	/* Toggle i_N_start */
	writel(0, base + DDS_START);
	udelay(100);
	writel(1, base + DDS_START);
	udelay(1000);
}

static void dds_program(void)
{
	dds_frame(ctrl);
	dds_frame(0x4000 | (increment & 0x3fff));
	dds_frame(0x4000 | ((increment >> 14) & 0x3fff));
}

/* Gestion de la frequency */
static ssize_t frequency_show(struct device *dev, struct device_attribute *attr, char *buf)
{/* Affiche la dernière frequency enregistrée */
	printk(KERN_INFO "frequency_show: %u\n", freq_hz);
	return sprintf(buf, "%u\n", freq_hz);
}

static ssize_t frequency_store(struct device *dev, struct device_attribute *attr,const char *buf, size_t count)
{/* Enregistre la nouvelle frequency */

	/* Convertit la chaîne de caractères en entier et vérifie si la frequency est valide */
	if (kstrtouint(buf, 10, &freq_hz) || freq_hz > MASTER_CLOCK / 2)
		return -EINVAL; /* Retourne une erreur si la frequency n'est pas valide */

	/* Calcule l'increment */
	increment = div_u64((u64)freq_hz << 28, MASTER_CLOCK);
	printk(KERN_INFO "increment: %u\n", increment);
	/* Programme le DDS */
	dds_program();
	return count;
}

/* Gestion de la waveform */
static ssize_t waveform_show(struct device *dev, struct device_attribute *attr, char *buf)
{
	printk(KERN_INFO "waveform_show: %x\n", ctrl);
	if (ctrl == 0x2202)
		return sprintf(buf, "trig\n");
	return sprintf(buf, "sin\n");
}

static ssize_t waveform_store(struct device *dev, struct device_attribute *attr,
			      const char *buf, size_t count)
{
	printk(KERN_INFO "waveform_store: %s\n", buf);
	if (sysfs_streq(buf, "sin"))
		ctrl = 0x2200;
	else if (sysfs_streq(buf, "trig"))
		ctrl = 0x2202;
	else
		return -EINVAL;

	dds_program();
	return count;
}


#undef VERIFY_OCTAL_PERMISSIONS   // avoid warning about macro redefinition
#define VERIFY_OCTAL_PERMISSIONS(p) (p)

static DEVICE_ATTR(frequency,0666,frequency_show,frequency_store);
static DEVICE_ATTR(waveform,0666,waveform_show,waveform_store);



static int dds_probe(struct platform_device *pdev)
{
	printk(KERN_INFO "dds_probe\n");
	base = ioremap(DDS_PHYS, 4096);

	writel(0, base + DDS_START_DIR);  /* start en sortie */
	writel(0, base + DDS_DATA_DIR);   /* data en sortie */
	writel(1, base + DDS_START);      /* i_N_start au repos à 1 */

	device_create_file(&pdev->dev, &dev_attr_frequency);
	device_create_file(&pdev->dev, &dev_attr_waveform);
	return 0;
}

static void dds_remove(struct platform_device *pdev)
{
	printk(KERN_INFO "dds_remove\n");
	device_remove_file(&pdev->dev, &dev_attr_waveform);
	device_remove_file(&pdev->dev, &dev_attr_frequency);
	iounmap(base);
}

static struct platform_driver dds_driver = {
	.probe = dds_probe,
	.remove = dds_remove,
	.driver = { .name = "dds_ad9834" },
};

static int __init dds_init(void)
{
	int ret;

	printk(KERN_INFO "dds_init\n");
	ret = platform_driver_register(&dds_driver);
	if (ret)
		return ret;

	pdev = platform_device_register_simple("dds_ad9834", 0, NULL, 0);
	if (IS_ERR(pdev)) {
		platform_driver_unregister(&dds_driver);
		return PTR_ERR(pdev);
	}
	return 0;
}

static void __exit dds_exit(void)
{
	printk(KERN_INFO "dds_exit\n");
	platform_device_unregister(pdev);
	platform_driver_unregister(&dds_driver);
}

module_init(dds_init);
module_exit(dds_exit);

MODULE_LICENSE("GPL");
