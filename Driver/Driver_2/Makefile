MODULE = Driver_2
HOSTBIN = /home/mbld/Documents/lib/buildroot-2026.08_redpit/output/host/bin
KERNEL_DIR = /home/mbld/Documents/lib/buildroot-2026.08_redpit/output/build/linux-custom

obj-m += $(MODULE).o
all:
	PATH=$(HOSTBIN):$$PATH $(MAKE) ARCH=arm CROSS_COMPILE=arm-linux- -C $(KERNEL_DIR) M=$(shell pwd -P) modules

ssh:
	ssh root@192.168.2.200

transfer: $(MODULE).ko
	mkdir -p /home/mbld/nfs/kernel/sys/5_dds
	cp $(MODULE).ko /home/mbld/nfs/kernel/sys/5_dds/

clean:
	PATH=$(HOSTBIN):$$PATH $(MAKE) ARCH=arm CROSS_COMPILE=arm-linux- -C $(KERNEL_DIR) M=$(shell pwd -P) clean
