# Introduction

The tools in this project help toy yo more easily create and delete VMs in Azure. The commands are wrappers around the `az` command and use individual VM configuration files that define what the VM should be like in Azure. It requires and existing source disk image file (.vhd) to use as  a template disk image for the newly created VM. The new VM's disk image file will reside in a Container (Blob storage) in an Azure Storage Account.

Additional tools that are useful to use in conjunction with these tools (also defined in the **https://github.com/roncterry/azure-course-tools** git repository).




# The vm-config.azvm Configuration File

A `vm-config.azvm` file is the file used to describe a VM that is to launched in Azure. Each VM to be launched will require its own file.

The configuration options are set as variable=value pairs. The following are the configuration options that must be set:

**REGION**

This variable contains the name of the Azure region in which the VM is to be launched.


**RESOURCE_GROUP**

This variable contains the name of the Resource Group that the VM will be a prt of.


**STORAGE_ACCOUNT**

This variable contains the name of the Storage Account where the Storage Container that will contain the VM's disk image will be created exists.


**STORAGE_CONTAINER_NAME**

This variable the name of the Storage Container in the Storage Account in which the VM's disk image (.vhd file) will be created.


**SOURCE_IMAGE_FILE**

This variable contains the name of the source VM disk image file (.vhd) that will be used as the template to create the disk image file for the VM defined in this file.


**SOURCE_IMAGE_URI**

This variable contains the URI of the source disk image file. It is pre-populated and with a value that should always work.


**OS_TYPE**

This specifies the OS that will be running in the VM defined by this file. 

Options: linux, windows


**VM_NAME**

This specifies the name of the VM that will be created.


**VM_SIZE**

This specifies the size (flavor) of VM to be created.

Options:

Name | Description
----- | ----------
Standard_D2s_v3  | 2 VCPU / 8GB RAM
Standard_D4s_v3  | 4 VCPU / 16GB RAM
Standard_D8s_v3  | 8 VCPU / 32GB RAM
Standard_D16s_v3 | 16 VCPU / 64GB RAM
Standard_D32s_v3 | 32 VCPU / 128GB RAM
Standard_D48s_v3 | 48 VCPU / 192GB RAM
Standard_D64s_v3 | 64 VCPU / 256GB RAM

Defailt: Standard_D4s_v3


**VM_DISK_SIZE**

This specifies the size of disk image in GB to creates for the VM. It is created in the storage container named STORAGE_CONTAINER_NAME. 

If left empty the size of the disk will be that of the SOURCE_IMAGE.

Example fro a 1TB disk: 1024 


**EPHEMERAL_OS_DISK**

Create the OS disk as an ephemeral disk on the compute host.

If set to TRUE then the OS disk is created on the compute host. This can improve local disk performance and faster VM/VMSS reimage times.

If you are creating a new VM and want to keep the image in your image library then set this to FALSE.

Options: TRUE,FALSE

If in doubt, use FALSE.

Default: FALSE


**AUTH_TYPE**

This is the authentication types ues to access the VM.

Options: password, ssh, all

Type | Description
----- | ----------
password | requires ADMIN_USERNAME and ADMIN_PASSWORD to be set
ssh | requires ADMIN_USERNAME to to be set and a public key value to be set in SSH_KEY_LIST
all | requires ADMIN_USERNAME and ADMIN_PASSWORD to be set and a public ssh key value to be set in SSH_KEY_LIST

Default: password


**ADMIN_USERNAME**

This is the user who's password will be set using the AMDIN_PASSWORD and will have SSH keys added to their ~/.ssh/authorized_keys file if set.

This is the user you will log into the VM as.

Default: tux


**ADMIN_PASSWORD**

This is the password that will be set for the admin user if AUTH_TYPE is set to password or all.

Default: d3faul7P@s5w0rd


**SSH_KEY_LIST**

This is a list of SSH public keys to append to the admin user's ~/.ssh/authorized_keys file.

This will be used if AUTH_TYPE is set to ssh or all.


**ENABLE_RDP**

Enable RDP access to Linux VMs

This only applies to Linux VMs.

By default RDP is enabled by default for Windows VMs so changing this value for Windows VMs will have no effect.


**ENABLE_SSH**

Enable SSH access to Windows VMs

This only applies to Windows VMs.

By default SSH is enabled by default for Linux VMs so changing this value for Linux VMs will have no effect.


**ADDITIONAL_OPEN_PORTS**

Space delimited list of additional ports to open.


**ADDITIONAL_CLI_ARGS**

Any additional CLI arguments can be listed here.



# Use the *create-azure-vm.sh* Script

## Intro:

This command is used to create/launch a VM in Azure as defined by a `vm-config.azvm` file: 



## Usage:
```
create-azure-vm.sh <VM_CONFIG_FILE> 
```


# Use the *delete-azure-vm.sh* Script

## Intro:

This command is used to delete a VM in Azure that was created/launched byt the `create-azure-vm.sh` script. It requires you to provide `vm-config.azvm` config file. 



## Usage:
```
delete-azure-vm.sh <VM_CONFIG_FILE> 
```

