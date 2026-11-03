#!/bin/bash
set -euo pipefail

fail() { printf 'confidential-debian: %s\n' "$*" >&2; exit 1; }

[[ $$ == 1 ]] || fail 'must run as PID 1'

umask 077
printf '%s\n' "${SSH_KEYS:?SSH_KEYS is required}" > /run/authorized_keys
ssh-keygen -lf /run/authorized_keys >/dev/null 2>&1 || fail 'SSH_KEYS has no usable public key'
umask 022

echo workspace > /etc/hostname
hostname workspace

key=/etc/ssh/ssh_host_ecdsa_key
attested=/run/tinfoil/keys/host-ssh/private_key.pem
[[ -f $attested ]] || fail 'attested host-ssh key is missing'
install -m 0600 "$attested" "$key"
ssh-keygen -yf "$key" > "$key.pub"
printf 'confidential-debian: host key %s\n' "$(ssh-keygen -lf "$key.pub")"

ldconfig  # pick up the driver libs the nvidia runtime mounts in
exec /sbin/init
