#!/usr/bin/env bash

set -e  # exit immediately on error
set -u  # fail on undeclared variables

# Grab the directory of the scripts, in case the script is invoked from a different path
SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
# Useful routines in common.sh
. "${SCRIPTS_DIR}/common.sh"

CICD_SCRIPTS_SRC=${CICD_SCRIPTS_SRC:-"${SCRIPTS_DIR}/../cicd-tools"}
CLOUD_INIT=${CLOUD_INIT:-"${SCRIPTS_DIR}/cloud.init"}
VM_MEM=${VM_MEM:-12G}
VM_DISK=${VM_DISK:-50G}
VM_CPUS=${VM_CPUS:-4}

# need mutlipass to launch the vm
exit_no_multipass

# Only create the VM if it doesn't exist
if vm_exists ${SINGLE_VM_NAME} ; then
  exit_error "${SINGLE_VM_NAME} already exists! Exiting."
else
  info "CREATING ${SINGLE_VM_NAME}"
  multipass launch \
      --name ${SINGLE_VM_NAME} \
      --mem ${VM_MEM} \
      --disk ${VM_DISK} \
      --cpus ${VM_CPUS} \
      --cloud-init "${CLOUD_INIT}" \
      ${VM_IMAGE}
  # Where "permanent data" will be stored
  info "MOUNTING HOST:${STORAGE_SRC} --> VM:${STORAGE_DST}"
  ensure_host_storage
  multipass mount ${STORAGE_SRC} ${SINGLE_VM_NAME}:${STORAGE_DST}

  # Where the scripts are stored 
  info "MOUNTING HOST:${CICD_SCRIPTS_SRC} --> VM:${CICD_SCRIPTS_DST}"
  multipass mount ${CICD_SCRIPTS_SRC} ${SINGLE_VM_NAME}:${CICD_SCRIPTS_DST}
fi
