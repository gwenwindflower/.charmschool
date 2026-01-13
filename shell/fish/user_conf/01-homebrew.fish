# Sets $HOMEBREW_PREFIX
brew shellenv fish | source
# Turn off Homebrew hints
set -gx HOMEBREW_NO_ENV_HINTS 1

# Homebrew completions
# Because `fish` is installed via Homebrew,
# completion linking is handled automatically.
# Gosh I love fish.

# Homebrew services
## Postgres
### @16
# If you need to have postgresql@16 first in your PATH, run:
#   fish_add_path /usr/local/opt/postgresql@16/bin
#
# For compilers to find postgresql@16 you may need to set:
#   set -gx LDFLAGS "-L/usr/local/opt/postgresql@16/lib"
#   set -gx CPPFLAGS "-I/usr/local/opt/postgresql@16/include"
#
# For pkg-config to find postgresql@16 you may need to set:
#   set -gx PKG_CONFIG_PATH "/usr/local/opt/postgresql@16/lib/pkgconfig"
#
# To start postgresql@16 now and restart at login:
#   brew services start postgresql@16
# Or, if you don't want/need a background service you can just run:
#   LC_ALL="C" /usr/local/opt/postgresql@16/bin/postgres -D /usr/local/var/postgresql@16
