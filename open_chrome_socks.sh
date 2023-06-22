tmux new -d -s 'SOCKS_SERVER1'  ssh -N -D 9090 jonatan@server1 -v
tmux new -d -s 'CHROME_SOCKS' -- /usr/bin/google-chrome --user-data-dir="$HOME/proxy-profile" --proxy-server="socks5://localhost:9090"
tmux ls

