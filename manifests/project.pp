# This resource is designed to manage Bugzilla projects.
#
# == Parameters
#
# [*create_htaccess*]
#		create necessary .htaccess files to lock down bugzilla
# [*webservergroup*]
#		group that apache runs as
#	[*db_driver*]
#		driver to use for db access. Mysql is the default.
# [*db_host*]
#		host for db
# [*db_name*]
#		db name
# [*db_user*]
#		who we connect to the database as
# [*db_pass*]
#		DB user password.
#	[*db_port*]
#		Port to connect to database. 0 is default. 
# [*db_sock*]
#		Socket to connect to database. Will default to the drivers default.
#	[*db_check*]
#		Should checksetup.pl try to verify that your database setup is correct?
#	[*index_html*]
#		Create an index.html file.
#	[*cvsbin*]
#		Locion of cvs binary
#	[*interdiffbin*]
#		Location of interdiff binary
# [*diffpath*]
#		Location of diff home (/usr/bin/)
#	[*site_wide_secret*]
#		Set the site wide secret
define bugzilla::project (
	$admin_email,
	$admin_password,
	$admin_realname,
	$create_htaccess = false,
	$webservergroup = 'apache',
  $db_driver = 'mysql',
  $db_host = 'localhost',
  $db_name = 'bugzilla',
  $db_user = 'bugzilla',
  $db_pass = '',
  $db_port = 0,
  $db_sock = '',
  $db_check = true,
  $index_html = false,
  $cvsbin = '/usr/bin/cvs',
  $interdiffbin = '/usr/bin/interdiff',
  $diffpath = '/usr/bin',
  $site_wide_secret = '',
	$smtp_server = 'localhost'
) {

	require("bugzilla")

	$bz_confdir = "/etc/bugzilla/"
	case $name {
		"main": {
			$localconfigfile = "${bz_confdir}localconfig"
			$backupconfigfile = "${bz_confdir}.puppet/localconfig"
			$answerconfigfile = "${bz_confdir}.puppet/answer"
			$envexport = "DUMMY=foo"
		}
		/(.*)/: {
			$localconfigfile = "${bz_confdir}localconfig.${name}"
			$backupconfigfile = "${bz_confdir}.puppet/localconfig.${name}"
			$answerconfigfile = "${bz_confdir}.puppet/answer.${name}"
			$envexport = "PROJECT=${name}"
		}
	}

	# Perform configuration and run checksetup.pl which will build the db
	# if required.
	file {$answerconfigfile:
		owner => 'root',
		group => 'root',
		mode => '0644',
		content => template('bugzilla/answer.erb'),
		notify => Exec["bugzilla_checksetup_${name}"]
	}
	exec{"bugzilla_checksetup_${name}":
		command => "/usr/share/bugzilla/checksetup.pl ${answerconfigfile}",
		logoutput => true,
		refreshonly => true,
		notify => Exec["backup_localconfigfile_${name}"],
	}
	exec{"backup_localconfigfile_${name}":
		command => "/bin/cp ${localconfigfile} ${backupconfigfile}",
		logoutput => true,
		refreshonly => true,
	}
	file {$backupconfigfile:
		ensure => present
	}
	file {$localconfigfile:
		owner => 'root',
		group => 'root',
		mode => '0644',
		ensure => present,
		source => $backupconfigfile,
		require => Exec["backup_localconfigfile_${name}"]
	}

	# Cron jobs for notifications and statistics
	cron {"bugzilla-collectstats-${name}":
		command => "cd /usr/share/bugzilla; ./collectstats.pl",
		user => "root",
		hour => 0,
		minute => 5,
		environment => $envexport,
		require => File[$localconfigfile]
	}
	cron {"bugzilla-whineatnews-${name}":
		command => "cd /usr/share/bugzilla; ./whineatnews.pl > /dev/null",
		user => "apache",
		hour => 0,
		minute => 55,
		environment => $envexport,
		require => File[$localconfigfile]
	}
	cron {"bugzilla-whine-${name}":
		command => "cd /usr/share/bugzilla; ./whine.pl",
		user => "apache",
		minute => "*/15",
		environment => $envexport,
		require => File[$localconfigfile]
	}
}
