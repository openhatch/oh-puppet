class openhatch_code {
  user { 'deploy':
    comment => "Mister Deploy",
    home => "/home/deploy",
    shell => "/bin/bash",
    uid => '50000', # Let's give it a constant UID
  }

  file { '/home/deploy':
    require => [User['deploy'], Group['deploy']],
    ensure => directory,
    group  => 'deploy',
    owner  => 'deploy',
    mode   => '0750',
  }

  group { 'deploy':
    gid => '50000',
    require => User['deploy'],
  }

  package { 'git':
    ensure => 'installed',
  }

  # We do not use the vcsrepo type because
  # it does not support setting the user
  # who will own the resulting git clone.
  exec { "/usr/bin/git clone git://gitorious.org/openhatch/oh-mainline.git":
    user => 'deploy',
    group => 'deploy',
    cwd => '/home/deploy/',
    logoutput => "on_failure",
    unless => '/usr/bin/test -d /home/deploy/oh-mainline',
    subscribe => [File['/home/deploy']],
  }

}

node default {
  include openhatch_code
}
