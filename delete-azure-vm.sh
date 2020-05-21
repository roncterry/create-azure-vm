#!/bin/bash
#
# Version: 1.0.0
# Date: 2020-05-21

######### Default Values #################
DEFAULT_CLI_ARGS=""
DEFAULT_REGION="westus"
##########################################

### Colors ###
RED='\e[0;31m'
LTRED='\e[1;31m'
BLUE='\e[0;34m'
LTBLUE='\e[1;34m'
GREEN='\e[0;32m'
LTGREEN='\e[1;32m'
ORANGE='\e[0;33m'
YELLOW='\e[1;33m'
CYAN='\e[0;36m'
LTCYAN='\e[1;36m'
PURPLE='\e[0;35m'
LTPURPLE='\e[1;35m'
GRAY='\e[1;30m'
LTGRAY='\e[0;37m'
WHITE='\e[1;37m'
NC='\e[0m'
##############

# echo -e "${LTGREEN}COMMAND: ${GRAY}${NC}"
# echo -e "${LTBLUE}${NC}"
#
#

usage() {
  echo
  echo "Usage: ${0} <vm_config_file> [delete-vhd]"
  echo
}

if [ -z ${1} ]
then
  usage
  exit 0
fi

if [ -e ${1} ]
then
  source ${1}

  if [ -z ${REGION} ]
  then
    REGION=${DEFAULT_REGION}
  fi

  if [ -z ${RESOURCE_GROUP} ]
  then
    echo -e "${RED}ERROR: You must provide the resource group the VM is in. Exiting.${NC}"
    echo
    exit 1
  fi

  if [ -z ${STORAGE_ACCOUNT} ]
  then
    echo -e "${RED}ERROR: You must provide the storage account where the VM's vhd disk is located. Exiting.${NC}"
    echo
    exit 1
  fi

else
  echo -e "${RED}ERROR: The VM config file specified does not exist. Exiting.${NC}"
  exit 1
fi

#############################################################################

get_vm_public_ip_list() {
  export VM_PUBLIC_IP_LIST="$(az network public-ip list -o table 2> /dev/null | grep ${VM_NAME} | awk '{ print $1 }')"
  echo -e "${LTPURPLE}VM_PUBLIC_IP_LIST=${GRAY}${VM_PUBLIC_IP_LIST}${NC}"
}

get_vm_nic_list() {
  export VM_NIC_LIST="$(az network nic list -o table 2> /dev/null | grep ${VM_NAME} | awk '{ print $5 }')"
  if echo ${VM_NIC_LIST} | grep -q Success
  then
    export VM_NIC_LIST="$(az network nic list -o table 2> /dev/null | grep ${VM_NAME} | awk '{ print $4 }')"
  fi
  echo -e "${LTPURPLE}VM_NIC_LIST=${GRAY}${VM_NIC_LIST}${NC}"
}

get_vm_nsg() {
  export VM_NSG_NAME="$(az network nsg list -o table 2> /dev/null | grep ${VM_NAME} | awk '{ print $2 }')"
  echo -e "${LTPURPLE}VM_NSG_NAME=${GRAY}${VM_NSG_NAME}${NC}"
}

get_vm_managed_disk_list() {
  export VM_MANAGED_DISK_LIST="$(az disk list -o table 2> /dev/null | grep ${VM_NAME} | awk '{ print $1 }')"
  echo -e "${LTPURPLE}VM_MANAGED_DISK_LIST=${GRAY}${VM_MANAGED_DISK_LIST}${NC}"
}

get_storage_account_key() {
  export STORAGE_ACCOUNT_KEY="$(az storage account keys list --account-name ${STORAGE_ACCOUNT} -o table 2> /dev/null | grep key1 | awk '{ print $3 }')"
}

delete_vm() {
  echo -e "${LTBLUE}Deleting the VM ...${NC}"
  echo -e "${LTGREEN}COMMAND: ${GRAY} az vm delete --resource-group ${RESOURCE_GROUP} --name ${VM_NAME} --yes${NC}"
  az vm delete --resource-group ${RESOURCE_GROUP} --name ${VM_NAME} --yes --verbose 2> /dev/null
  echo;echo
}

delete_vm_nics() {
  echo -e "${LTBLUE}Deleting the VM's NICs ...${NC}"
  for VM_NIC in ${VM_NIC_LIST}
  do
    echo -e "${LTGREEN}COMMAND: ${GRAY} az network nic delete --resource-group ${RESOURCE_GROUP} --name ${VM_NIC}${NC}"
    az network nic delete --resource-group ${RESOURCE_GROUP} --name ${VM_NIC} --verbose 2> /dev/null
  done
  echo;echo
}

delete_vm_public_ips() {
  echo -e "${LTBLUE}Deleting the VM's Public IPs ...${NC}"
  for VM_PUBLIC_IP in ${VM_PUBLIC_IP_LIST}
  do
    echo -e "${LTGREEN}COMMAND: ${GRAY} az network public-ip delete --resource-group ${RESOURCE_GROUP} --name ${VM_PUBLIC_IP}${NC}"
    az network public-ip delete --resource-group ${RESOURCE_GROUP} --name ${VM_PUBLIC_IP} --verbose 2> /dev/null
  done
  echo;echo
}

delete_vm_nsg() {
  echo -e "${LTBLUE}Deleting the VM's NSGs ...${NC}"
  for VM_NSG in ${VM_NSG_NAME}
  do
    echo -e "${LTGREEN}COMMAND: ${GRAY} az network nsg delete --resource-group ${RESOURCE_GROUP} --name ${VM_NSG} ${NC}"
    az network nsg delete --resource-group ${RESOURCE_GROUP} --name ${VM_NSG} --verbose 2> /dev/null
  done
  echo;echo
}

delete_vm_managed_disks() {
  echo -e "${LTBLUE}Deleting the VM's Managed Disks ...${NC}"
  for VM_MANAGED_DISK in ${VM_MANAGED_DISK_LIST}
  do
    echo -e "${LTGREEN}COMMAND: ${GRAY} az disk delete --resource-group ${RESOURCE_GROUP} --name ${VM_MANAGED_DISK} --yes --no-wait${NC}"
    az disk delete --resource-group ${RESOURCE_GROUP} --name ${VM_MANAGED_DISK} --yes --no-wait --verbose 2> /dev/null
  done
  echo;echo
}

delete_vm_vhd() {
  echo -e "${LTBLUE}Deleting the VM's vhd Disk ...${NC}"
  echo -e "${LTGREEN}COMMAND: ${GRAY} az storage blob delete --account-name ${STORAGE_ACCOUNT} --account-key \"${STORAGE_ACCOUNT_KEY}\" --container-name ${STORAGE_CONTAINER_NAME} --name ${VM_NAME}-disk.vhd --delete-snapshots include${NC}"
  az storage blob delete --account-name "${STORAGE_ACCOUNT}" --account-key "${STORAGE_ACCOUNT_KEY}" --container-name ${STORAGE_CONTAINER_NAME} --name "${VM_NAME}-disk.vhd" --delete-snapshots include 2> /dev/null

  echo;echo
}

#############################################################################

main() {
  echo
  echo -e "${LTBLUE}=======================================================================${NC}"
  echo -e "${LTBLUE}            Deleting Azure VM: ${GRAY}${VM_NAME}${NC}"
  echo -e "${LTBLUE}=======================================================================${NC}"
  echo
  get_vm_nic_list
  get_vm_public_ip_list
  get_vm_nsg
  get_vm_managed_disk_list
  echo -e "${LTPURPLE}VM_VHD_DISK=${GRAY}${VM_NAME}-disk.vhd${NC}"
  get_storage_account_key
  echo -e "${LTPURPLE}STORAGE_ACCOUNT_KEY=${GRAY}${STORAGE_ACCOUNT_KEY}${NC}"
  echo;echo

  delete_vm
  delete_vm_nics
  delete_vm_public_ips
  delete_vm_nsg
  delete_vm_managed_disks

  if echo ${*} | grep "delete-vhd"
  then
    delete_vm_vhd
  fi

  echo -e "${LTBLUE}=======================================================================${NC}"
}

#############################################################################

main ${*}
