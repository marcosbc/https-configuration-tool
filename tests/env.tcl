package require Expect

set root_dir [file dirname [file normalize [info script]]]
set lib_dir [file join $root_dir lib]
set tests_dir [file join $root_dir tests]
set tests_common_dir [file join $tests_dir common]
set input_dir [file join $root_dir inputs_for_tests]
set output_dir {/tmp/test_output}
set tool [glob -nocomplain [file join $input_dir *.run]]

# Test inputs variables
set autodetected_installdir /opt/bitnami
set undetected_installdir /opt/installdir
set resolvable_domain_with_www bncert.bntestdomain.cf
set resolvable_domain_without_www bncert-no-www.bntestdomain.cf
set sample_certificate_domains [list $resolvable_domain_with_www www.$resolvable_domain_with_www]
set valid_domains [concat $resolvable_domain_with_www www.$resolvable_domain_with_www $resolvable_domain_without_www]
set valid_email testbitnamismtp@gmail.com

# Environment checks
if {[llength $tool] != 1} {
    puts "You must place the binary .run file at $input_dir"
    exit 1
}

# Load procedures
foreach proc_file [glob [file join $lib_dir *]] {
    source $proc_file
}

file mkdir $output_dir
