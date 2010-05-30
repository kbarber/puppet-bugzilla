# Bugzilla is a Web-based general-purpose bugtracker and testing tool 
# originally developed and used by the Mozilla project, and licensed under the 
# Mozilla Public License.
#
# This class is designed to install and setup Bugzilla.
class bugzilla {
	$res = "bugzilla"

	# These are the requirements for running a fully-functional bugzilla
	# The package should do this perhaps, but they are optional.
	package {
		[
		"bugzilla",

		# The following list was working out using checksetup.pl 
		"perl-GD",
		"perl-Chart",
		"perl-Template-GD",
		"perl-GDTextUtil",
		"perl-GDGraph",
		"perl-XML-Twig",
		"perl-MIME-tools",
		"perl-PatchReader",
		"ImageMagick-perl",
		"perl-Authen-SASL",
		"perl-Authen-Radius",
		"perl-HTML-Scrubber",
		"perl-TheSchwartz",
		"perl-Daemon-Generic",
		]:
			ensure => installed
	}

	# Create a dir for puppet to work with config
	file {"/etc/bugzilla/.puppet":
		ensure => directory,
		mode => 0755,
		owner => "root",
		group => "root"
	}
}
