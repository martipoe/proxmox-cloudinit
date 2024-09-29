#!/bin/bash

set -euxo pipefail

### Create a Debian Cloud-Init Ready VM Template ###

wget -O "${TEMPLATE_IMAGE_NAME}" --continue "${TEMPLATE_IMAGE_URL}/${TEMPLATE_IMAGE_NAME}" && \
    qm create "${TEMPLATE_VM_ID}" --name "${TEMPLATE_VM_NAME}" --memory "${TEMPLATE_VM_MEM}" ${TEMPLATE_VM_NETWORKING} && \
    qm importdisk "${TEMPLATE_VM_ID}" "${TEMPLATE_IMAGE_NAME}" "${TEMPLATE_STORAGE}" && \
    qm set "${TEMPLATE_VM_ID}" --scsihw virtio-scsi-pci --scsi0 "${TEMPLATE_STORAGE}:vm-${TEMPLATE_VM_ID}-disk-0" && \
    qm set "${TEMPLATE_VM_ID}" --ide2 "${TEMPLATE_STORAGE}:cloudinit" && \
    qm set "${TEMPLATE_VM_ID}" --boot c --bootdisk scsi0 && \
    qm set "${TEMPLATE_VM_ID}" --serial0 socket --vga serial0 && \
    qm template "${TEMPLATE_VM_ID}" && \
    echo "TEMPLATE ${TEMPLATE_VM_NAME} successfully created!"
