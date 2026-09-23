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

key=/etc/ssh/ssh_host_ed25519_key
[[ -f $key ]] || ssh-keygen -q -t ed25519 -N '' -f "$key"
printf 'confidential-debian: host key %s\n' "$(ssh-keygen -lf "$key.pub")"

exec /sbin/init
