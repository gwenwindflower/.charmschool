# fisher installs fish plugins directly into the dotfiles repo,
# so there is no need to run it just to set up a new machine
# when you do find the need to run an update though, on a machine
# that is already set up and running fish, run this script
# If necessary to update
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
fisher install jorgebucaran/fisher
fisher update
