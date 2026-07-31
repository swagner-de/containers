#!/bin/bash
# Lean Tailscale subnet-router entrypoint for MikroTik Container.
# No sshd — manage via RouterOS `/container/shell`. Honors the TS_* env list.

STATE_DIR="${TS_STATE_DIR:-/var/lib/tailscale}"
mkdir -p "$STATE_DIR" /var/run/tailscale

# Accept RAs and keep SLAAC addresses even with forwarding on (exit node needs
# accept_ra=2). Set before enabling forwarding so the SLAAC address isn't flushed.
for i in /proc/sys/net/ipv6/conf/*/accept_ra; do echo 2 > "$i" 2>/dev/null || true; done

# Best-effort forwarding (namespaced sysctls; may be denied inside the container).
sysctl -w net.ipv4.ip_forward=1 2>/dev/null || true
sysctl -w net.ipv6.conf.all.forwarding=1 2>/dev/null || true

# tailscaled is the main process; keep it in the foreground via wait.
/usr/local/bin/tailscaled \
  --state="${STATE_DIR}/tailscaled.state" \
  --socket=/var/run/tailscale/tailscaled.sock \
  ${TS_TAILSCALED_EXTRA_ARGS} &
TAILSCALED_PID=$!

# Wait for the daemon socket, then bring the node up ONCE. No --reset: persisted
# state (on the mount) is reused across restarts and the authkey is only consumed
# on first registration.
for n in $(seq 1 30); do [ -S /var/run/tailscale/tailscaled.sock ] && break; sleep 0.5; done
/usr/local/bin/tailscale up \
  --authkey="${TS_AUTH_KEY}" \
  ${TS_ROUTES:+--advertise-routes="${TS_ROUTES}"} \
  ${TS_EXTRA_ARGS} || echo "tailscale up failed (check TS_AUTH_KEY / persisted state)"

wait "$TAILSCALED_PID"
