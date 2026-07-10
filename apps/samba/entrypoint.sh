#!/bin/sh
set -eu

# Create users from /config/users.conf (format: username:uid:gid:group)
if [ -f /config/users.conf ]; then
    # `|| [ -n "$name" ]` picks up the last line when it has no trailing newline
    while IFS=: read -r name uid gid group || [ -n "$name" ]; do
        [ -z "$name" ] && continue
        addgroup -g "$gid" "$group" 2>/dev/null || true
        adduser -D -H -u "$uid" -G "$group" -s /sbin/nologin "$name" 2>/dev/null || true
        if [ -f "/run/secrets/$name" ]; then
            printf '%s\n%s\n' "$(cat "/run/secrets/$name")" "$(cat "/run/secrets/$name")" | smbpasswd -a -s "$name"
        fi
    done < /config/users.conf
fi

exec smbd --foreground --no-process-group --debuglevel="${SAMBA_LOG_LEVEL:-1}"
