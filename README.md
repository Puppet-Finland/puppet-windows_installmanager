# windows_installmanager

A Puppet module for managing Windows updates and software installations.

# Usage

In your hiera:

    install_all_updates: false
    install_all_security_updates: true
    update_schedule_range: '0-23'
    update_schedule_weekday: Saturday
    security_update_schedule_range: '0-5'
    security_update_schedule_period: daily
    list_available_updates, Boolean: true
    wsus_server_url: 'http://updates.example.com:8530'
    kbs_to_install:
      'Security Update for Windows Server 2012 R2 (KB3175024)': KB3175024

