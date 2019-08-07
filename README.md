# installed_for.sh

Light Bash utility to calculate elapsed time since OS installation.

## Usage
Just execute the script:
`./installed_for.sh`

## Compatible distributions
* Red Hat Enterprise Linux derivatives (CentOS, RHEL, Scientific Linux etc.) (using `rpm -q basesystem`)
* Fedora and derivatives (using `rpm -q basesystem`)
* Arch Linux based distributions (using `/var/log/pacman.log`)
* Debian based that utilize the /var/log/installer directory (using `ls -lact --full-time /var/log/installer`)

The list is far from complete and I am currently trying to find standard ways to determine installation dates avoiding workarounds.

All other distributions are currently (until a better method is found) supported using the filesystem creation date: `ls -lact --full-time /etc`

## Implementation details
The script simply calculates the difference in seconds between current and installation datetime. There are some notable functions:

### function displaytime $1 $2 $3
This function converts seconds (provided by $1 parameter) to the following format:

`#a years #b days #c hours #d minutes #e seconds`

However, it calculates leap years, for the shake of completeness, in order to convert correctly. To do so, $2(INSTALL_YEAR) and $3(CURRENT_YEAR) parameters are needed.