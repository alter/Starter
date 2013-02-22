#!/bin/bash
#screen -d -S taskServer -m ruby server.rb
screen -d -m -S taskWebInterface -m ruby -rubygems /home/donkey/www/starter/index.rb -e production
screen -list
