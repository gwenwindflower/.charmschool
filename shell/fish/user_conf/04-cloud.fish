# Google Cloud SDK

# The Python interpreter used by Google Cloud SDK,
# at present it requires Python 3.12.x - I want to make sure it uses uv's
# not the Homebrew dependency one, just for troubleshooting clarity
set -gx CLOUDSDK_PYTHON .local/share/uv/python/cpython-3.12.11-macos-x86_64-none/bin/python3.12

# gcloud doesn't use this env var, but it's helpful to me for consistency and convenience
set -gx GCLOUD_HOME $HOMEBREW_PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/

fish_add_path $GCLOUD_HOME/bin
# This is cleaner than the fish script that gcloud wants you to source, which
# hilariously contains a comment to the effect of "this is wildly convoluted bc I don't understand fish"
# For posterity, what they want you to do is:
# `source $HOMEBREW_PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.fish.inc`
# Which uses like 15 lines to accomplish the same thing (albeit more dynamically)
