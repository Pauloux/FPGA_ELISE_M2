# Author: Paul ROUSSEAU
# Date: November 2026
#
# Before running "make", please update your PATH so arm-linux-gcc can be found.

MODULE_NAME = linux_driver-AD9834

BUILDROOT_DIR = /home/pauloux/buildroot-2026.08-rc1
NFS_DIR = /home/pauloux/Documents/0CMI/0Semestre9/Microcontroleur/TP/nfs

obj-m += $(MODULE_NAME).o

all: $(MODULE_NAME).ko

$(MODULE_NAME).ko: $(MODULE_NAME).c
	make ARCH=arm CROSS_COMPILE=arm-linux- -C $(BUILDROOT_DIR)/output/build/linux-custom M=$(PWD) modules

load: $(MODULE_NAME).ko
	cp $(MODULE_NAME).ko $(NFS_DIR)/$(MODULE_NAME).ko

clean:
	make ARCH=arm CROSS_COMPILE=arm-linux- -C $(BUILDROOT_DIR)/output/build/linux-custom M=$(PWD) clean
