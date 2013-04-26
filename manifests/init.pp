# == Class: repose
#
# This class is able to install or remove repose on a node.
#
# [Add description - What does this module do on a node?] FIXME/TODO
#
#
# === Parameters
#
# [*ensure*]
# String. Controls if the managed resources shall be <tt>present</tt> or
# <tt>absent</tt>. If set to <tt>absent</tt>:
# * The managed software packages are being uninstalled.
# * Any traces of the packages will be purged as good as possible. This may
# include existing configuration files. The exact behavior is provider
# dependent. Q.v.:
# * Puppet type reference: {package, "purgeable"}[http://j.mp/xbxmNP]
# * {Puppet's package provider source code}[http://j.mp/wtVCaL]
# * System modifications (if any) will be reverted as good as possible
# (e.g. removal of created users, services, changed log settings, ...).
# * This is thus destructive and should be used with care.
# Defaults to <tt>present</tt>.
#
# [*enable*]
# Bool/String. Controls if the managed service shall be running(<tt>true</tt>),
# stopped(<tt>false</tt>), or <tt>manual</tt>. This affects the service state
# at both boot and during runtime.  If set to <tt>manual</tt> Puppet will
# ignore the state of the service.
# Defaults to <tt>true</tt>.
#
# [*autoupgrade*]
# Boolean. If set to <tt>true</tt>, any managed package gets upgraded
# on each Puppet run when the package provider is able to find a newer
# version than the present one. The exact behavior is provider dependent.
# Q.v.:
# * Puppet type reference: {package, "upgradeable"}[http://j.mp/xbxmNP]
# * {Puppet's package provider source code}[http://j.mp/wtVCaL]
# Defaults to <tt>false</tt>.
#
# The default values for the parameters are set in repose::params. Have
# a look at the corresponding <tt>params.pp</tt> manifest file if you need more
# technical information about them.
#
#
# === Examples
#
# * Installation:
#
# class { 'repose': }
#
# * Removal/decommissioning:
#
# class { 'repose': ensure => 'absent' }
#
#
# === Authors
#
# * Ra Cker <mailto:ra.cker@rackspace.com>
# * c/o Team <mailto:team@rackspace.com>
#
#
# [ NO empty lines allowed between this and definition below for rdoc ]
class repose (
  $ensure      = $repose::params::ensure,
  $enable      = $repose::params::enable,
  $autoupgrade = $repose::params::autoupgrade,
  $anothervar  = hiera('anothervar', 'default value')
) inherits repose::params {

### Validate parameters

## ensure
  if ! ($ensure in [ present, absent ]) {
    fail("\"${ensure}\" is not a valid ensure parameter value")
  } else {
    $file_ensure = $ensure ? {
      present => file,
      absent  => absent,
    }
  }
  if $::debug {
    if $ensure != $repose::params::ensure {
      debug('$ensure overridden by class parameter')
    }
    debug("\$ensure = '${ensure}'")
  }

## enable - we don't validate because all standard options are acceptable
  if $::debug {
    if $enable != $repose::params::enable {
      debug('$enable overridden by class parameter')
    }
    debug("\$enable = '${enable}'")
  }

## autoupgrade
  validate_bool($autoupgrade)
  if $::debug {
    if $autoupgrade != $repose::params::autoupgrade {
      debug('$autoupgrade overridden by class parameter')
    }
    debug("\$autoupgrade = '${autoupgrade}'")
  }

### Manage actions

## package(s)
  class { 'repose::package': }

## service(s)
  class { 'repose::service': }

## files/directories
  file { $repose::params::configdir:
    ensure  => directory,
    mode    => $repose::params::dirmode,
    owner   => $repose::params::owner,
    group   => $repose::params::group,
    require => Package[$repose::params::package],
  }

  file { $repose::params::configfile:
    ensure  => file,
    mode    => $repose::params::mode,
    owner   => $repose::params::owner,
    group   => $repose::params::group,
    require => Package[$repose::params::package],
  }

}
