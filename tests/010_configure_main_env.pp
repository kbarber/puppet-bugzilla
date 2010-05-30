include bob_bugzilla

# This is how you create a single main environment using the defaults.
bob_bugzilla::project{"main": 
	admin_email => "foo@bob.sh",
	admin_realname => "Foo Bar",
	admin_password => "foobar"
}

# This is a more complex one
bob_bugzilla::project{"complex":
	admin_email => "foo@bob.sh",
	admin_realname => "Foo Bar",
	admin_password => "foobar",
	create_htaccess => true,
	webservergroup => 'apache',
	db_driver => 'mysql',
	db_host => 'localhost',
	db_name => 'bugzilla',
	db_user => 'bugzilla',
	db_pass => '',
	db_port => false,
	db_sock => '',
	db_check => true,
	index_html => false,
	cvsbin => '/usr/bin/cvs',
	interdiffbin => '/usr/bin/interdiff',
	diffpath => '/usr/bin',
	site_wide_secret => 'krif9f9rkr9f9fker9e44i',
}
