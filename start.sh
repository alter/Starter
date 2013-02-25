#!/bin/bash
## m100 or gtlive
#screen -d -S taskServer -m ruby server.rb
## stats
#screen -d -m -S taskWebInterface -m ruby -rubygems /home/donkey/www/starter/index.rb -e production
screen -list
