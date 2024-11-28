## Install

* Download the binary from [GitHub Releases](https://github.com/jtroo/kanata/releases)
* Make it executable with `chmod +x kanata`
* Move the file to bin directory `sudo mv kanata /usr/local/bin/`
* Add kanata directory in `~/.config` `mkdir ~/.config/kanata`
* Create symbolic link for the config `ln -s ~/.dotfiles/kanata/kanata.kbd ~/.config/kanata/kanata.kbd`
* Execute `sudo kanata -c ~/.config/kanata/kanata.kbd`