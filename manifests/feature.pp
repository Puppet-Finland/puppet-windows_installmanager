# A define to install a windowsfeature or windowsoptionalfeature
#
# == Parameters:
#
# feature:: The feature to install
define windows_installmanager::feature
(
  $feature,
)
{
  # TODO: Use module hiera
  if ($facts['os']['release']['full'] in [ '7', '8.1', '10' ]) {
    
    dsc_windowsoptionalfeature { $feature:
      dsc_ensure => 'Present',
      dsc_name   => $feature,
    }
  }
  elsif ($facts['os']['release']['full'] in [ '2003', '2008', '2008 R2', '2012', '2012 R2', '2016' ]) {
    dsc_windowsfeature  { $feature:
      dsc_ensure => 'Present',
      dsc_name   => $feature,
    }
  }
  else {
    fail("Unsupported relase ${facts}['os']['release']")
  }
}
