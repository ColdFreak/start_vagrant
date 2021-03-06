#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e 
function show() {
    echo "\$ $@"
    eval "$@"
}

# login as root

#7.4のvim を入れるために
show add-apt-repository ppa:pi-rho/dev -y
# 新しいnginxを入れるため
show add-apt-repository ppa:nginx/stable -y
# 新しいnodejsをインストールため
show add-apt-repository ppa:chris-lea/node.js -y

show add-apt-repository ppa:chris-lea/redis-server -y

show wget http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
show dpkg -i erlang-solutions_1.0_all.deb
show rm erlang-solutions_1.0_all.deb

# update erlang repository
show apt-get update

show aptitude install -y nginx php5-fpm php5-xdebug
#show update-rc.d -f nginx remove


cp -a /vagrant/default /etc/nginx/sites-enabled/default
cp -a /vagrant/php.ini  /etc/php5/fpm/php.ini
cp -a /vagrant/www.conf /etc/php5/fpm/pool.d/www.conf
cp -a /vagrant/index.html /usr/share/nginx/html/index.html

show service php5-fpm restart
show service nginx restart

# this will also install apache2
show aptitude install -y php5
show aptitude install -y apache2

service apache2 stop
# remove all the symbolic link 
update-rc.d -f apache2 remove


#古いvimをアンインストー
show aptitude remove -y vim vim-runtime vim-tiny vim-common

show aptitude install -y vim tmux git-core


# disable postgresql in all the run levels
show aptitude install -y postgresql
#show update-rc.d -f postgresql remove

su postgres << EOF
psql -c "CREATE USER adp_test_user WITH PASSWORD 'abc123';"
EOF

su postgres << EOF
psql -c "ALTER USER adp_test_user WITH SUPERUSER; "
EOF

su postgres << EOF
psql -c "CREATE DATABASE adp_test_bid WITH OWNER adp_test_user ENCODING 'UTF8';"
EOF

su postgres << EOF
psql -c "CREATE DATABASE adp_test_manage WITH OWNER adp_test_user ENCODING 'UTF8';"
EOF

su postgres << EOF
psql -c "CREATE DATABASE adp_test_users WITH OWNER adp_test_user ENCODING 'UTF8';"
EOF

show aptitude install -y erlang

## install elixir from git
#show git clone https://github.com/elixir-lang/elixir.git
#show cd elixir
#show make clean test

show aptitude install -y rabbitmq-server

show aptitude install -y most
#
show aptitude install -y nodejs

show aptitude install -y exuberant-ctags
show git clone git://github.com/amix/vimrc.git /home/vagrant/.vim_runtime
show sh /home/vagrant/.vim_runtime/install_awesome_vimrc.sh
show git clone git://github.com/joonty/vdebug.git /home/vagrant/.vim_runtime/sources_forked/vdebug
show cp -a /vagrant/my_configs.vim /home/vagrant/.vim_runtime/my_configs.vim
show chown -R vagrant:vagrant /home/vagrant/.vim_runtime
show mv /root/.vimrc /home/vagrant/
show chown vagrant:vagrant /home/vagrant/.vimrc
show rm -rf /home/vagrant/.vim_runtime/sources_non_forked/vim-zenroom2/

debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password root'
show aptitude install -y mysql-server-5.5
show update-rc.d -f mysql remove
show service mysql stop

show aptitude install -y redis-server
show service redis-server stop

tmux_conf=$(cat <<EOF 
# https://github.com/seebi/tmux-colors-solarized/blob/master/tmuxcolors-256.conf
set-option -g status-bg colour235 #base02
set-option -g status-fg colour136 #yellow
set-option -g status-attr default

# set window split
bind-key v split-window -h
bind-key b split-window

# default window title colors
set-window-option -g window-status-fg colour244 #base0
set-window-option -g window-status-bg default
#set-window-option -g window-status-attr dim

# active window title colors
set-window-option -g window-status-current-fg colour166 #orange
set-window-option -g window-status-current-bg default
#set-window-option -g window-status-current-attr bright

# pane border
set-option -g pane-border-fg colour235 #base02
set-option -g pane-active-border-fg colour240 #base01

# message text
set-option -g message-bg colour235 #base02
set-option -g message-fg colour166 #orange

# pane number display
set-option -g display-panes-active-colour colour33 #blue
set-option -g display-panes-colour colour166 #orange
# clock
set-window-option -g clock-mode-colour green #green


set -g status-interval 1
set -g status-justify centre # center align window list
set -g status-right-length 20
set -g status-left-length 140
set -g status-right '#[fg=green]#H #[fg=black]• #[fg=green,bright]#(uname -r | cut -c 1-6)#[default]'
set -g status-left '#[fg=green,bg=default,bright]#(tmux-mem-cpu-load 1) #[fg=red,dim,bg=default]#(uptime | cut -f 4-5 -d " " | cut -f 1 -d ",") #[fg=white,bg=default]%a%l:%M:%S %p#[default] #[fg=green]%Y-%m-%d'

# C-b is not acceptable -- Vim uses it
set-option -g prefix C-a
bind-key C-a last-window

# Start numbering at 1
set -g base-index 1

# Allows for faster key repetition
set -s escape-time 0

# Rather than constraining window size to the maximum size of any client
# connected to the *session*, constrain window size to the maximum size of any
# client connected to *that window*. Much more reasonable.
setw -g aggressive-resize on

# Allows us to use C-a a <command> to send commands to a TMUX session inside
# another TMUX session
bind-key a send-prefix

# Activity monitoring
setw -g monitor-activity on
set -g visual-activity on

# Vi copypaste mode
set-window-option -g mode-keys vi
bind-key -t vi-copy 'v' begin-selection
bind-key -t vi-copy 'y' copy-selection

# hjkl pane traversal
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

bind-key C command-prompt -p "Name of new window: " "new-window -n '%%'"

# reload config
bind r source-file ~/.tmux.conf \; display-message "Config reloaded..."

# auto window rename
set-window-option -g automatic-rename

# rm mouse mode fail
set -g mode-mouse off

# color
set -g default-terminal "screen-256color"

# status bar
set-option -g status-utf8 on

# https://github.com/edkolev/dots/blob/master/tmux.conf
# Updates for tmux 1.9's current pane splitting paths.
if-shell "[[ `tmux -V` == *1.9* ]]" 'unbind c; bind c new-window -c "#{pane_current_path}"'
if-shell "[[ `tmux -V` == *1.9* ]]" 'unbind s; bind s split-window -v -c "#{pane_current_path}"'
if-shell "[[ `tmux -V` == *1.9* ]]" "unbind '\"'; bind '\"' split-window -v -c '#{pane_current_path}'"
if-shell "[[ `tmux -V` == *1.9* ]]" 'unbind v; bind v split-window -h -c "#{pane_current_path}"'
if-shell "[[ `tmux -V` == *1.9* ]]" 'unbind %; bind % split-window -h -c "#{pane_current_path}"'
EOF
)

test -f /home/vagrant/.tmux.conf ||  echo "${tmux_conf}" > /home/vagrant/.tmux.conf

bashrc=$(cat <<EOF
export EDITOR='vim'
alias ll='ls -la'
alias l='ll'

# Custom bash prompt via kirsle.net/wizards/ps1.html
export PS1="\[\$(tput bold)\]\[\$(tput setaf 6)\]\t \[\$(tput setaf 2)\][\[\$(tput setaf 3)\]\u\[\$(tput setaf 5)\] => \[\$(tput setaf 1)\]\w\[\$(tput setaf 2)\]]\[\$(tput setaf 4)\]\n\\$ \[\$(tput sgr0)\]"

export CLICOLOR=1
export LSCOLORS=gxfxcxdxbxegedabagaced

# use most to display color man pages
export PAGER="most"
EOF

)
echo "${bashrc}" >> /home/vagrant/.bashrc

echo "Enjoy ^^"
