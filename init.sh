#!/bin/sh
#
# Initial cleanup and configuration for new droplets that will be autoconfigured
# by freebsd-digitalocean.
# This script is intended to be run by the pre-installed cloudinit via user-data
# or manually on a freshly deployed droplet originating from a default DO-image.
# Don't run this script on an already modified system unless you fully understand
# everything it does, as it might have undesired side-effects on existing 
# configurations (esp. rc.conf).

. $(dirname "$0")/digitalocean.conf

# check if we need to initialize the droplet or exit gracefully
grep -c "# DigitalOcean Dynamic Configuration" /etc/rc.conf || exit 0

# we want a clean base system, so remove all packages except pkg
pkg delete -yqa

# cleanup cloudinit and DO-specific configs
rm -f /usr/local/etc/rc.d/digitalocean*
rm -f /usr/local/etc/rc.conf.d/digitalocean.conf
rm -rf /usr/local/etc/cloud

# remove extra user created on DO-droplets
rmuser -y freebsd

# cleanup rc.conf
sed -i '' -e '/hostname/d' -e '/cloudinit/d' -e '/digitalocean/d' -e '/DigitalOcean Dynamic Configuration/,$d' /etc/rc.conf

# install freebsd-digitalocean scripts
sh $(dirname "$0")/install.sh

# enable the service
if [ ! $(grep "digitalocean_enable=" /etc/rc.conf) ] && [ ! $(grep "digitalocean_enable=" /etc/rc.conf.local) ]; then
        [ -f /etc/rc.conf.local ] && echo "digitalocean_enable=YES" >> /etc/rc.conf.local || echo "digitalocean_enable=YES" >> /etc/rc.conf
fi
