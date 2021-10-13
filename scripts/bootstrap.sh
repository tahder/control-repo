#!/bin/bash
PUPPET_REPO=$1
HOSTNAME=$2
BRANCH=$3
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 PUPPET_REPO HOSTNAME BRANCH"
  exit 1
fi
hostname ${HOSTNAME}
echo ${HOSTNAME} >/etc/hostname
source /etc/lsb-release
sudo apt-key del 4096R/4BD6EC30
sudo apt-key del 4096R/EF8D349F
apt-key adv --fetch-keys http://apt.puppetlabs.com/DEB-GPG-KEY-puppet-20250406
wget http://apt.puppetlabs.com/puppetlabs-release-${DISTRIB_CODENAME}.deb
dpkg -i puppetlabs-release-${DISTRIB_CODENAME}.deb
apt-get update
apt-get -y install git puppet-agent
cd /etc/puppetlabs/code/environments
mv production production.orig
git clone ${PUPPET_REPO} production
cd production
git checkout ${BRANCH}
/opt/puppetlabs/puppet/bin/gem install r10k --no-rdoc --no-ri
/opt/puppetlabs/puppet/bin/r10k puppetfile install --verbose
/opt/puppetlabs/bin/puppet apply --environment=production /etc/puppetlabs/code/environments/production/manifests/
