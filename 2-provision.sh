#!/bin/bash

set -euxo pipefail

### Provision VM from VM template ###

# Copy cloudinit user and network configuration to snippets directory in Proxmox storage
mkdir -p "${PROVISION_VM_STORAGE_PATH}/snippets/${PROVISION_VM_ID}/" && \
    cp "./provision/${PROVISION_VM_ID}/cloud-init.yml" "${PROVISION_VM_STORAGE_PATH}/snippets/${PROVISION_VM_ID}-cloud-init.yml" && \
    cp "./provision/${PROVISION_VM_ID}/netplan.yml" "${PROVISION_VM_STORAGE_PATH}/snippets/${PROVISION_VM_ID}-netplan.yml"

# Create full clone from template VM: https://www.reddit.com/r/Proxmox/comments/18dp3h6/should_i_use_linked_clones/
# Then resize root disk, configure resources and mount cloudinit snippet.
qm clone "${TEMPLATE_VM_ID}" "${PROVISION_VM_ID}" --name "${PROVISION_VM_NAME}" --storage "${PROVISION_VM_STORAGE}" --full true && \
    qm resize "${PROVISION_VM_ID}" scsi0 "${PROVISION_VM_DISK}" && \
    qm set "${PROVISION_VM_ID}" --memory "${PROVISION_VM_MEM}" --cores "${PROVISION_VM_CORES}" ${PROVISION_VM_NETWORKING} && \
    qm set "${PROVISION_VM_ID}" --cicustom "user=local:snippets/${PROVISION_VM_ID}-cloud-init.yml,network=local:snippets/${PROVISION_VM_ID}-netplan.yml" && \
    qm start "${PROVISION_VM_ID}" && \
    echo "VM ${PROVISION_VM_NAME} successfully created!"
