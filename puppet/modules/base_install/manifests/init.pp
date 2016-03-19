# Base installation/configuration class for Ubuntu
# Author: Gleidson Nascimento
class base_install {

    if versioncmp($::puppetversion,'3.6.1') >= 0 {
        $allow_virtual_packages = hiera('allow_virtual_packages',false)
        Package {
            allow_virtual => $allow_virtual_packages,
        }
    }

    exec { "apt-update":
        command => "/usr/bin/apt-get update",
    }

# Present packages
    package { "dnsutils": ensure => "installed" }
    package { "cryptsetup-luks": ensure => "installed" }
    package { "dstat": ensure => "installed" }
    package { "ed": ensure => "installed" }
    package { "lsof": ensure => "installed" }
    package { "mlocate": ensure => "installed" }
    package { "mtr": ensure => "installed" }
    package { "net-tools": ensure => "installed" }
    package { "rsync": ensure => "installed" }
    package { "screen": ensure => "installed" }
    package { "strace": ensure => "installed" }
    package { "sysstat": ensure => "installed" }
    package { "tcpdump": ensure => "installed" }
    package { "tcsh": ensure => "installed" }
    package { "telnet": ensure => "installed" }
    package { "traceroute": ensure => "installed" }
    package { "unzip": ensure => "installed" }
    package { "wget": ensure => "installed" }
    package { "yum": ensure => "installed" }
    package { "zip": ensure => "installed" }

# Removed packages
    package { "alsa-firmware": ensure => "absent" }
    package { "alsa-lib": ensure => "absent" }
    package { "alsa-utils": ensure => "absent" }
    package { "alsa-tools-firmware": ensure => "absent" }
    package { "libsndfile": ensure => "absent" }
    package { "iprutils": ensure => "absent" }
    package { "ivtv-firmware": ensure => "absent" }
    package { "iwl100-firmware": ensure => "absent" }
    package { "iwl1000-firmware": ensure => "absent" }
    package { "iwl105-firmware": ensure => "absent" }
    package { "iwl135-firmware": ensure => "absent" }
    package { "iwl2000-firmware": ensure => "absent" }
    package { "iwl2030-firmware": ensure => "absent" }
    package { "iwl3160-firmware": ensure => "absent" }
    package { "iwl3945-firmware": ensure => "absent" }
    package { "iwl4965-firmware": ensure => "absent" }
    package { "iwl5000-firmware": ensure => "absent" }
    package { "iwl5150-firmware": ensure => "absent" }
    package { "iwl6000-firmware": ensure => "absent" }
    package { "iwl6000g2a-firmware": ensure => "absent" }
    package { "iwl6000g2b-firmware": ensure => "absent" }
    package { "iwl6050-firmware": ensure => "absent" }
    package { "iwl7260-firmware": ensure => "absent" }
    package { "java-1.8.0-openjdk-headless": ensure => "absent" }
    package { "java-1.8.0-openjdk": ensure => "absent" }
    package { "java-1.7.0-openjdk": ensure => "absent" }
    package { "java-1.7.0-openjdk-devel": ensure => "absent" }
    package { "bind": ensure => "absent" }
    package { "dhcp": ensure => "absent" }
    package { "dovecot": ensure => "absent" }
    package { "httpd": ensure => "absent" }
    package { "mcstrans": ensure => "absent" }
    package { "openldap-clients": ensure => "absent" }
    package { "openldap-servers": ensure => "absent" }
    package { "pulseaudio-libs": ensure => "absent" }
    package { "rsh": ensure => "absent" }
    package { "rsh-server": ensure => "absent" }
    package { "samba": ensure => "absent" }
    package { "setroubleshoot": ensure => "absent" }
    package { "squid": ensure => "absent" }
    package { "talk": ensure => "absent" }
    package { "talk-server": ensure => "absent" }
    package { "telnet-server": ensure => "absent" }
    package { "tftp": ensure => "absent" }
    package { "tftp-server": ensure => "absent" }
    package { "vsftpd": ensure => "absent" }
    package { "xorg-x11-server-common": ensure => "absent" }
    package { "ypbind": ensure => "absent" }
    package { "ypserv": ensure => "absent" }

# Disabled services
    service { 'rpcbind'        : ensure => stopped, enable => false, }

    # Enable puppet in the target host
    file { 'puppet_agent_config':
        name => '/etc/puppetlabs/puppet/puppet.conf',
        owner => root,
        group => root,
        mode => 640,
        source => "puppet:///modules/base_install/puppet.conf",
    }
    service { "pe-puppet":
        ensure  => "running",
        enable  => "true",
        subscribe => File[puppet_agent_config],
    }

    # Enable auditd Service
    package { 'auditd': ensure => present, }
    service { 'auditd':
        subscribe => File[audit_rules],
        require => Package['auditd'],
        ensure => "running",
        enable => "true",
    }

    file { 'audit_rules':
        name => '/etc/audit/rules.d/audit.rules',
        owner => root,
        group => root,
        mode => 640,
        source => "puppet:///modules/base_install/audit.rules",
        require => Package['auditd'],
    }

    file { '/etc/audit/auditd.conf':
        mode => '0640',
        require => Package["auditd"],
        notify => Service["auditd"],
    }

    augeas{'Audit-max_log_file':
        context => "/files/etc/audit/auditd.conf",
        changes => "set max_log_file 100",
    }

    # Enable cron Daemon
    package { "anacron": ensure => "installed", }
    service { 'cron':
        ensure => running,
        enable => true,
    }

    # Restrict at/cron to Authorized Users
    file { '/etc/cron.allow':
        mode => 600,
        content => "root\n",
    }
    file { '/etc/cron.deny':
        ensure => absent,
    }
    file { '/etc/anacrontab' : mode => 600, require => Package['anacron'], }

    file { '/etc/cron.d'       : ensure => directory, mode => 700, }
    file { '/etc/cron.daily'   : ensure => directory, mode => 700, }
    file { '/etc/cron.hourly'  : ensure => directory, mode => 700, }
    file { '/etc/cron.monthly' : ensure => directory, mode => 700, }
    file { '/etc/cron.weekly'  : ensure => directory, mode => 700, }
    file { '/etc/crontab'      :                      mode => 600, }

    file { '/etc/at.allow': mode => 600, content => "root\n", }
    file { '/etc/at.deny': ensure => absent, }

    # Activate the rsyslog Service
    package { "rsyslog": ensure => "installed" }
    package { "rsyslog-gnutls": ensure => "installed" }
    service { 'rsyslog':
        ensure => running,
        enable => true,
        require => Package["rsyslog"],
    }

    # Configure logrotate
        package { 'logrotate':
        ensure => installed,
    }
    file { '/etc/logrotate.d/syslog':
        owner => "root",
        group => "root",
        mode => 644,
        source => "puppet:///modules/base_install/syslog.logrotate",
    }
    file { '/var/log/boot.log':
        mode => 644,
        owner => "root",
        group => "root",
    }
    file { '/var/log/cron':
        owner => "root",
        group => "root",
        mode => 600,
    }

    file { '/etc/group'   : mode => 644, }
    file { '/etc/gshadow' : mode => 000, }

    file { '/etc/passwd':
        owner => "root",
        group => "root",
        mode => 644,
    }
    user { 'root' : gid => 0, }

    file { '/etc/shadow':
        owner => "root",
        group => "root",
        mode => 000,
    }

    # Lock Inactive User Accounts
    augeas{ 'Lock-Inactive-Accounts':
        context => "/files/etc/default/useradd",
        changes => "set INACTIVE 35",
    }

    # Set Password Rules
    augeas{ 'Set-Password-Change-Minimum':
        context => "/files/etc/login.defs",
        changes => "set PASS_MIN_DAYS 7",
    }
    augeas{ 'Set-Password-Expiring-Warning':
        context => "/files/etc/login.defs",
        changes => "set PASS_WARN_AGE 7",
    }
    augeas{ 'Set-Password-Expiration':
        context => "/files/etc/login.defs",
        changes => "set PASS_MAX_DAYS 90",
    }

    # Disable ipv6
    file { '/etc/modprobe.d/ipv6-disable.conf':
        owner => "root",
        group => "root",
        mode => 644,
        source => "puppet:///modules/base_install/ipv6-disable.conf",
    }

    augeas{ 'FILE-etc-sysctl-conf':
        incl => "/etc/sysctl.conf",
        lens => "Sysctl.lns",
        changes => [
            "set fs.suid_dumpable                           0",
            "set kernel.randomize_va_space                  2",
            "set net.ipv4.ip_forward                        0",
            "set net.ipv4.conf.all.send_redirects           0",
            "set net.ipv4.conf.default.send_redirects       0",
            "set net.ipv4.conf.all.accept_source_route      0",
            "set net.ipv4.conf.default.accept_source_route  0",
            "set net.ipv4.conf.all.accept_redirects         0",
            "set net.ipv4.conf.default.accept_redirects     0",
            "set net.ipv4.conf.all.secure_redirects         0",
            "set net.ipv4.conf.default.secure_redirects     0",
            "set net.ipv4.conf.all.log_martians             1",
            "set net.ipv4.conf.default.log_martians         1",
            "set net.ipv4.icmp_echo_ignore_broadcasts       1",
            "set net.ipv4.icmp_ignore_bogus_error_responses 1",
            "set net.ipv4.conf.all.rp_filter                1",
            "set net.ipv4.conf.default.rp_filter            1",
            "set net.ipv4.tcp_syncookies                    1",
            "set net.ipv6.conf.all.accept_ra                0",
            "set net.ipv6.conf.default.accept_ra            0",
            "set net.ipv6.conf.all.accept_redirects         0",
            "set net.ipv6.conf.default.accept_redirects     0",
            "set net.ipv6.conf.all.disable_ipv6             1",
            "set net.ipv4.tcp_keepalive_time              600",
            "set net.ipv4.tcp_keepalive_intvl              60",
            "set net.ipv4.tcp_keepalive_probes              3",
            "set net.ipv4.tcp_sack                          0",
        ],
    }

    # Restrict Core Dumps
    augeas{ "/etc/security/limits.conf":
        incl   => "/etc/security/limits.conf",
        lens   => "limits.lns",
        changes=> [ "set domain       '*'",
                    "set domain/type  hard",
                    "set domain/item  core",
                    "set domain/value 0",
        ]
    }

    # Set SELinux
    augeas{ 'Set-the-SELinux-State':
        context => "/files/etc/selinux/config",
        changes => "set SELINUX enforcing",
    }
    augeas{ 'Set-SELinux-Policy':
        context => "/files/etc/selinux/config",
        changes => "set SELINUXTYPE targeted",
    }

    # Add login timeout settings.
    file { "timeout-settings.sh":
        name   => '/etc/profile.d/timeout-settings.sh',
        mode   => 644,
        owner  => "root",
        group  => "root",
        source => 'puppet:///modules/base_install/timeout-settings.sh',
    }

    # Add bash history timestamps.
    file { "history-timestamp.sh":
        name   => '/etc/profile.d/history-timestamp.sh',
        mode   => 644,
        owner  => "root",
        group  => "root",
        source => 'puppet:///modules/base_install/history-timestamp.sh',
    }

    # Configure PAM
    file { "system-auth-ac":
        name    => '/etc/pam.d/system-auth-ac',
        mode    => 644,
        owner   => "root",
        group   => "root",
        source => 'puppet:///modules/base_install/system-auth-ac',
    }
    file { "password-auth-ac":
        name    => '/etc/pam.d/password-auth-ac',
        mode    => 644,
        owner   => "root",
        group   => "root",
        source => 'puppet:///modules/base_install/system-auth-ac',
    }

    # NON-CIS Add Host Details
    host { 'localhost.localdomain':
        ensure => 'present',
        target => '/etc/hosts',
        ip => '127.0.0.1',
        host_aliases => ['localhost'],
    }
    host { "$fqdn":
        ensure => 'present',
        target => '/etc/hosts',
        ip => "$ipaddress",
        host_aliases => "$hostname",
    }

# END
}