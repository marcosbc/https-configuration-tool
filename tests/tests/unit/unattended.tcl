#!/usr/bin/expect

source env.tcl

scenario "Launching unattended mode requires --installdir" {
    spawn sudo $tool --dry_run 1 --mode unattended
    expect_test "Unattended mode requires --installdir" "*The following options were not specified and are required: \r\r\n--installdir"
    expect_test "Process exited" eof
}

scenario "Launching as unattended mode is not allowed"
    spawn sudo $tool --dry_run 1 --installdir /path/to/something --mode unattended
    expect_test "Unattended mode is not supported" "Unattended mode is not supported yet. Please use --mode text or --mode gui instead."
    expect_test "Process exited" eof
}
