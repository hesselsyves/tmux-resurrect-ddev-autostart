# tmux-resurrect-ddev-autostart
autostart script to launch ddev

works only when using tmux resurrect. 

Create the file ~/.tmux/scripts/ddev-autostart.sh with the contents of the one in this repo.
add this in ~/.tmux.conf

# Override resurrect hook AFTER tpm init to combine tmux-window-name's
# rename script with our ddev autostart (tmux-window-name overwrites this hook)
set -g @resurrect-hook-post-restore-all '/home/yves/.tmux/plugins/tmux-window-name/scripts/rename_session_windows.py --post_restore; bash /home/yves/.tmux/scripts/ddev-autostart.sh &'

# Set tmux resurrect
save the resurrect file from this repo for example: ~/your-dotfiles-repo/tmux_resurrect.txt
Then after a fresh install, restore it with:
mkdir -p ~/.local/share/tmux/resurrect
cp ~/your-dotfiles-repo/tmux_resurrect.txt ~/.local/share/tmux/resurrect/tmux_resurrect.txt
ln -sf tmux_resurrect.txt ~/.local/share/tmux/resurrect/last
After that, a prefix + Ctrl-r (resurrect restore) will rebuild all your windows and panes from that file.
