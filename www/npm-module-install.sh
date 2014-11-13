#!/bin/bash

# Setup of NPM modules for installation of Grunt .
module_list_file="grunt-modules.txt"

# gets the list of plugin modules to install from our text file.
modules=( `cat $module_list_file | tr '\n' ' '` )

echo "************"
echo "installing grunt modules..."
echo "************"
for module in "${modules[@]}"; do
  npm install "$module"
done