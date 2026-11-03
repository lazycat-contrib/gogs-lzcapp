; Gogs configuration for LazyCat.
;
; Mounted at /data/gogs/conf/app.ini by content/entrypoint.sh, which fills in
; the placeholders below (domain and secret key) at first boot. With
; INSTALL_LOCK=true Gogs never shows the web installer, so the admin has to be
; seeded on the command line instead.

APP_NAME = Gogs
RUN_USER = git
RUN_MODE = prod

[database]
DB_TYPE = sqlite3
PATH = /data/gogs/data/gogs.db

[repository]
ROOT = /data/git/gogs-repositories

[server]
PROTOCOL = http
DOMAIN = __DOMAIN__
HTTP_ADDR = 0.0.0.0
HTTP_PORT = 3000
ROOT_URL = https://__DOMAIN__/
DISABLE_SSH = true
OFFLINE_MODE = true
APP_DATA_PATH = /data/gogs/data

[security]
INSTALL_LOCK = true
SECRET_KEY = __SECRET_KEY__
DISABLE_GIT_HOOKS = true

[service]
DISABLE_REGISTRATION = true
REQUIRE_SIGNIN_VIEW = true
ENABLE_NOTIFY_MAIL = false

[mailer]
ENABLED = false

[log]
MODE = console
LEVEL = Info
ROOT_PATH = /data/gogs/log

[session]
PROVIDER = file
PROVIDER_CONFIG = /data/gogs/data/sessions
