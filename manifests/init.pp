# A simple wrapper class to Manage Windows updates and software from Microsoft knowledge base
#
# TODO: chocolatey packages, local packages from a known location
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
class windows_installmanager
(
  Boolean $install_all_updates,
  Boolean $install_all_security_updates,
  String $wsus_server_url,
  Hash $kbs_to_install,
  String $update_schedule_range          = '0-5',
  String $update_schedule_weekday        = 'Saturday',
  String $security_update_schedule_range = '0-5',
  String $ecurity_update_schedule_period = 'daily',
)
{
  validate_str($update_schedule_range)
  validate_str($update_schedule_weekday)
  validate_str($security_update_schedule_range)
  validate_str($security_update_schedule_range)
  validate_bool($install_all_updates)
  validate_bool($install_all_security_updates)
  validate_str($wsus_server_ur)
  validate_hash($kbs_to_install)

  class { '::windows_autoupdate':
    noAutoUpdate => '1'
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
    range   => $update_schedule_period,
  }

  schedule { 'Security updates schedule':
    period => $seccurity_update_schedule_period,
    range  => $security_update_schedule_range,
  }

  if $install_all_updates {

    ::windows_updates::list { 'Ensure presence of all available updates':
      ensure    => 'present',
      name_mask => '*',
      schedule  => 'Updates schedule',
      require   => Schedule[ 'Updates schedule' ],
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

  $kbs_to_install.each | String $description, String $kb | {

    notify { "Installing KB: ${desctiption}: kb ${kb}": }

    ::windows_updates::kb { $kb:
      ensure   => 'present',
      kb       => $kb,
      schedule => 'Updates Schedule',
      require  => Schedule[ 'Updates schedule' ],
    }
  }
}


