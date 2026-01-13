# uv doesn't use this, but it's helpful to me for consistency and convenience
set -gx UV_HOME (uv python dir)
# As much as possible I try to limit Python installs to those from uv,
# exceptions being the stock macOS Python and Homebrew dependency Pythons.
set -gx UV_MANAGED_PYTHON true
