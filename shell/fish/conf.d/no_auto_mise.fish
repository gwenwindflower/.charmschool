# mise gets auto-activated by default with a brew+fish install,
# but this means my subsequent fish_add_path calls in my fish config
# get prepended above mise, exactly what we DON'T want, so we turn it off
# here in conf.d as early as possible, then activate mise manually at the end of the fish config
set -gx MISE_FISH_AUTO_ACTIVATE 0
