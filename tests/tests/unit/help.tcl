#!/usr/bin/expect

source env.tcl

set allowed_options {
	help
	version
	unattendedmodeui
	optionfile
	debuglevel
	mode
	debugtrace
	installer-language
	installdir
	domains
	server_name
	configure_server_name
	enable_https_redirection
	enable_nonwww_to_www_redirection
	enable_www_to_nonwww_redirection
	add_missing_domains
	dry_run
	use_staging
	email
	accept_tos
}

proc convert_to_cli_opts {opts} {
    set result ""
	foreach opt $opts {
        append result "--$opt\n"
	}
    return $result
}

scenario "All options in the help menu are acknowledged for" {
    set options [exec $tool --help 2>/dev/null | grep -- -- | awk {{ print $1 }}]
    # The last newline is not in the --help menu, which is why we use the '?' modifier
    regexp_test "There is an exact match for the help options" matches "^[convert_to_cli_opts $allowed_options]?$" $options
}
