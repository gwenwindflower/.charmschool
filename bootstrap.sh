# We need Rust to then install Rotz, which will install the rest of the dotfiles.
if command -v cargo &>/dev/null; then
	echo "Already installed rust toolchain."
else
	echo "Installing rust..." && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi
cargo install rotz
