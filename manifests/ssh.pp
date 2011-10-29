# ssh.pp

class ssh {
	include ssh::client,
		ssh::hostkeys::publish,
		ssh::config,
		ssh::daemon

	class { "ssh::hostkeys::collect": }
}

class ssh::client {
	case $operatingsystem {
		Ubuntu,Debian: {
			package { "openssh-client":
				ensure => latest
			}
		}
	}
}

define sshhostkey($ip, $key) {
	$host = regsubst($title, '^([^\.]+)\..*$', '\1')

	sshkey {
		"$title":
			type => ssh-rsa,
			key => $key,
			ensure => present;
		"$host":
			type => ssh-rsa,
			key => $key,
			ensure => present;
		"$ip":
			type => ssh-rsa,
			key => $key,
			ensure => present;
	}
}


class ssh::hostkeys::publish {
	case $operatingsystem {
		Ubuntu,Debian: {
			include ssh::client
		}
	}

	# Store this hosts's host key
	case $sshrsakey {
		"": { 
			err("No sshrsakey on $fqdn")
		}
		default: {
			debug("Storing RSA ssh hostkey for $hostname.$domain")
			@@sshhostkey { $fqdn: ip => $ipaddress, key => $sshrsakey }
		}
	}
}

class ssh::hostkeys::collect {
	# Do this about twice a day
	# OH-TODO: Work out what this achieves and modify as needed.
	if $hostname == "fenari" or generate("/usr/local/bin/position-of-the-moon") == "True" {
		notice("Collecting SSH host keys on $hostname.")

		# Install all collected ssh host keys
		Sshhostkey <<| |>>
	}
}

class ssh::config {
        case $operatingsystem {
		Ubuntu,Debian: {
			file {
        	       	        "/etc/ssh/sshd_config":
                                        owner => root,
                                        group => root,
                                        mode  => 0644,
                                        content => template("ssh/sshd_config.erb");
			}
		}
	}
}

class ssh::daemon {
	case $operatingsystem {
		Ubuntu,Debian: {
			package { "openssh-server":
				ensure => latest;
			}

			service {
				ssh:
					ensure => running,
					subscribe => File["/etc/ssh/sshd_config"];
			}
		}
	}
}
