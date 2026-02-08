# Notes on 1password SSH setup

When setting up 1password on a new machine, it's a little easier to type and think about the 1password ssh-agent if you create a symlink to it in your home directory. I don't think this will exist to symlink until you've set up the 1password GUI and activated the ssh-agent, so it's not part of the automated setup, but here's what to do:

```fish
mkdir -p ~/.1password
ln -s ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock ~/.1password/agent.sock
```

Then follow the steps here: <https://developer.1password.com/docs/ssh/get-started#step-4-configure-your-ssh-or-git-client>

Once that's working, confirm that everything lines up with your SSH clients correctly, and your signed commits are good (it all should just work because you're not creating new keys as you would have to on a new machine otherwise).
