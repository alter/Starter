#!/bin/bash
screen -d -S taskServer -m ruby server.rb
screen -d -S taskWebInterface -m ruby -rubygems index.rb -e production
screen -list
