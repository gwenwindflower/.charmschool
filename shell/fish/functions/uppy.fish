function uppy -d "Run all my custom tooling upgrade functions"
    echo " Running all tooling upgrade functions..."

    echo "󰄛 Updating kitty terminal emulator..."
    kittyup

    echo " Updating Homebrew packages..."
    brew update
    if test $status -ne 0
        echo " Homebrew update failed. Aborting remaining upgrades."
        return 1
    end
    brew upgrade
    if test $status -ne 0
        echo " Homebrew upgrade failed. Aborting remaining upgrades."
        return 1
    end
    brew cleanup
    if test $status -ne 0
        echo " Homebrew cleanup failed. Aborting remaining upgrades."
        return 1
    end

    echo " Updating fnm-managed Node.js..."
    fnmup
    if test $status -ne 0
        echo " Node updates via fnm failed. Aborting remaining upgrades."
        return 1
    end
    echo " Updating uv-managed Python versions..."
    uv python upgrade
    if test $status -ne 0
        echo " Python updates via uv failed. Aborting remaining upgrades."
        return 1
    end
    echo " Updating  Rust toolchain..."
    rustup up
    if test $status -ne 0
        echo " Rust toolchain update failed. Aborting remaining upgrades."
        return 1
    end
    echo " All custom tooling upgrade functions completed."
    return 0
end
