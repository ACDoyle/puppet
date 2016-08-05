# Class: apache
# ===========================
#
# Full description of class apache here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'apache':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2016 Your name here, unless otherwise noted.
#


#puppet manifest using conditional statements to support multiple platforms

class apache {
case $operatingsystem {
 centos: {
  $webserver='httpd'
  $confpath="/etc/$webserver/conf/$webserver.conf"
  $htmlpath="/var/www/html/index.html"
 }
 ubuntu: {
  $webserver='apache2'
  $confpath="/etc/$webserver/$webserver.conf"
  $htmlpath="/var/www/index.html"
 }
 default: {
  fail("Unsupported OS")
 }
}

package { 'apache':
 name => $webserver,
 ensure => installed,
}

package { 'browser':
 name => elinks,
 ensure => installed,
}

file {'apacheconf':
 name => $confpath,
 ensure => file,
 mode => 600,
 source => "puppet:///modules/apache/$webserver.conf",
 require => Package['apache'],
}

service {'apache':
 name => $webserver,
 ensure => running,
 enable => true,
 subscribe => File['apacheconf'],
}
file {'apachecontent':
 name => $htmlpath,
 ensure => file,
 mode => 644,
 content => template('apache/index.html.erb'),
 require => Service['apache'],
}

}


# puppet apply -d --noop > blind run to check if OK
# require check if Package is installed, prior configuration file implementaion
# subscribe - puppet monitor the target resource for changes, perform action in respons (for service, restart after change occured)
# before and notify are the opposite to require and subscribe - respectively
# -> before, require
# ~> notify,subscribe
# MOAR manifest order analysis of resources

#facter - generates a list of variables that describes server characteristics that are referred to as facts

