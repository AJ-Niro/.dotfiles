## Install

* Download the binary from [GitHub Releases](https://github.com/jtroo/kanata/releases)
* Make it executable with `chmod +x kanata`
* Move the file to bin directory `sudo mv kanata /usr/local/bin/`
* Add kanata directory in `~/.config` `mkdir ~/.config/kanata`
* Create symbolic link for the config `ln -s ~/.dotfiles/kanata/kanata.kbd ~/.config/kanata/kanata.kbd`
* Implement kanata daemon:
    
    1. Create kanata.service
    
        `sudo nano /etc/systemd/system/kanata.service`

    2. Write the content for the service file

        ```
        [Unit]
        Description=Kanata keyboard remapper
        After=multi-user.target

        [Service]
        ExecStart=/usr/local/bin/kanata -c ~/.config/kanata/kanata.kbd
        Restart=always
        User=yourusername

        [Install]
        WantedBy=multi-user.target
        ```
    
    3. Enable and start the service
        ```
        sudo systemctl daemon-reload
        sudo systemctl enable kanata
        sudo systemctl start kanata
        ```
