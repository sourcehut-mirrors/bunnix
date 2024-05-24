boot(7)

# NAME

boot - information about booting Bunnix

# DESCRIPTION

Bunnix supports both legacy and EFI boot on x86_64.

In the iso environment, both bootloaders are included in /boot.

## LEGACY BOOT

Legacy boot is supported via any multiboot-compatible bootloader, such as grub
or syslinux. _/boot/bunnixboot.mb_ is a multiboot-compatible bootloader.

The user should provide the kernel as the first multiboot module
(_/boot/bunnix_), and, if desirable, an initrd as the second multiboot module.

## EFI BOOT

An EFI-compatible bootloader is included at _/boot/EFI/boot/bootx64.efi_. This
can be executed by any EFI-compatible environment (such as directly from the
firmware, from the EFI shell, or via grub chainload) to boot Bunnix. It loads
the kernel from _/boot/bunnix_ on the boot filesystem and the initrd, if
desired, from _/boot/modules/initrd_.

## KERNEL COMMAND LINE

The kernel command line recognizes the following inputs:

*init*=_path_
	Specify the initial command to run on boot. Default: _/sbin/init_

*root*=_device_
	Specify the device which contains the root filesystem, e.g. sata0a.

*rootfstype*=_name_
	Root filesystem type. Supported filesystems are _ext4_ and _memfs_.

*ro*
	Mount root filesystem read-only.

If an initrd is provided by the bootloader, *root* is ignored.
