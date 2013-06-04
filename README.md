# windows-hostname cookbook

Sets hostname and FQDN of a windows node.

# Requirements

A node running Windows

# Usage

Set `set_fqdn` to the desired FQDN on the node and include `recipe[windows-hostname]` in its runlist.

NOTE: WINDOWS WILL RESTART

# Attributes

set_fqdn - FQDN to set.

# Recipes

## default

# Author

Author:: Shay Bergmann (<shaybergmann@gmail.com>)
