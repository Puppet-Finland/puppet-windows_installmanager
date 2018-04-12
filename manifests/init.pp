# A simple wrapper class to Manage Windows updates and software from Microsoft knowledge base
#
# TODO: chocolatey packages, local packages from a known location, remote MS packages by url
#
# == Parameters:
#
# $update_schedule_range:: Schedule for all updates 
#
# $update_schedule_period:: How often update all software
#
# $security_update_schedule_range:: Schedule for security updates 
#
# $security update_schedule_period:: How often to update security updates
# 
# $install_all_updates:: Whether to install all available updates
#
# $install_all_security_updates:: whether to install all available security updates 
#
# $kbs_to_install:: Hash of Microdsoft Kwnowledge Base tagged packages to install (installed as
#
# $list_folder:: Folder where to list available updates
#
# $wsus_server_url:: URL of the WSUS server
class windows_installmanager
(
  Hash $kbs_to_install                    = {},
  String $update_schedule_range           = '0-5',
  String $update_schedule_weekday         = 'Saturday',
  String $security_update_schedule_range  = '0-5',
  String $security_update_schedule_period = 'daily',
  String $list_folder                     = 'c:\\updates',
  Boolean $list_available_updates         = false,
  Boolean $install_all_updates            = false,
  Boolean $install_all_security_updates   = false,
  Optional[String] $wsus_server_url       = undef,

)
{
  validate_string($update_schedule_range)
  validate_string($update_schedule_weekday)
  validate_string($security_update_schedule_range)
  validate_string($security_update_schedule_range)
  validate_bool($install_all_updates)
  validate_bool($install_all_security_updates)
  validate_string($wsus_server_url)
  validate_hash($kbs_to_install)

  class { '::windows_autoupdate':
    no_auto_reboot_with_logged_on_users => '1',
    no_auto_update                      => '1'
  }

  if $wsus_server_url {

    class { '::wsus_client':
      server_url           => $wsus_server_url,
      enable_status_server => true,
      auto_update_option   => undef,
      require              => Class['::windows_autoupdate'],
    }
  }

  schedule { 'Updates schedule':
    weekday => $update_schedule_weekday,
    range   => $update_schedule_range,
  }

  schedule { 'Security updates schedule':
    period => $security_update_schedule_period,
    range  => $security_update_schedule_range,
  }

  if $install_all_updates {

    ::windows_updates::list { 'Ensure presence of all available updates':
      ensure    => 'present',
      name_mask => '*',
      schedule  => 'Updates schedule',
      require   => Schedule['Updates schedule'],
    }
  }

  if $install_all_security_updates {

    ::windows_updates::list { 'Ensure presence of all available security updates':
      ensure    => 'present',
      name_mask => 'Security*',
      schedule  => 'Security updates schedule',
      require   => Schedule[ 'Security updates schedule' ],
    }
  }

  if $list_available_updates {

    file { $list_folder:
      ensure => directory,
    }

    windows_updates::list { 'List updates available':
      ensure    => 'present',
      dry_run   => 'C:\\UPDATES_AVAILABLE.txt',
      name_mask => '*',
      require   => File[$list_folder],
    }

    windows_updates::list { 'List security updates available':
      ensure    => 'present',
      dry_run   => 'C:\\SECURITY_UPDATES_AVAILABLE.txt',
      name_mask => 'Security*',
      require   => File[$list_folder],
    }
  }

  $kbs_to_install.each | String $description, String $kb | {

    notify { "Installing KB: ${description}: kb ${kb}": }

    ::windows_updates::kb { $kb:
      ensure   => 'present',
      kb       => $kb,
      schedule => 'Updates Schedule',
      require  => Schedule[ 'Updates schedule' ],
    }
  }
}


