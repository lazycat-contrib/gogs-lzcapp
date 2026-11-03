#!/bin/sh
# Seed Gogs configuration and the admin account, then hand over to the image's
# own entrypoint.
#
# Why this exists: Gogs ships an installer that asks for the domain and the
# first admin in a web form. Behind the LazyCat ingress the domain is only
# known at runtime, and a web installer left open on a public instance is a
# window where anybody can claim the admin account. So INSTALL_LOCK is set from
# the start and the admin is created here instead.
set -eu

CONF_DIR=/data/gogs/conf
CONF_FILE="$CONF_DIR/app.ini"
DATA_DIR=/data/gogs/data

mkdir -p "$CONF_DIR" "$DATA_DIR" /data/git/gogs-repositories

if [ ! -f "$CONF_FILE" ]; then
    # 64 hex chars: Gogs wants a stable SECRET_KEY or sessions break on restart.
    SECRET_KEY="$(head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n')"
    sed -e "s|__DOMAIN__|${GOGS_DOMAIN}|g" \
        -e "s|__SECRET_KEY__|${SECRET_KEY}|g" \
        /lzcapp/pkg/content/app.ini.tpl > "$CONF_FILE"
    chmod 600 "$CONF_FILE"
    echo "wrote $CONF_FILE for domain ${GOGS_DOMAIN}"
fi

# Create the admin only when the database has no users yet. `create-user`
# fails loudly if the name is taken, which is the signal to skip.
if [ ! -f "$DATA_DIR/.admin-seeded" ]; then
    if /app/gogs/gogs admin create-user \
        --name "$GOGS_ADMIN_USER" \
        --password "$GOGS_ADMIN_PASSWORD" \
        --email "$GOGS_ADMIN_EMAIL" \
        --admin \
        --config "$CONF_FILE"; then
        touch "$DATA_DIR/.admin-seeded"
        echo "created admin $GOGS_ADMIN_USER"
    else
        echo "admin not created (already exists?)" >&2
        touch "$DATA_DIR/.admin-seeded"
    fi
fi

exec /app/gogs/docker/start.sh "$@"
