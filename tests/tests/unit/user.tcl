#!/usr/bin/expect

source env.tcl

scenario "Cannot be launched as a normal user" {
    spawn $tool --dry_run 1
    expect_test "Can not be launched by normal users" "*This installer requires root privileges*Press \\\[Enter\\\] to continue:"
    send "\r"
    expect_test "Process exited" eof
}

scenario "Can be launched as a superuser" {
    spawn sudo $tool --dry_run 1
    expect_test "Can be launched by superusers" "*Welcome*"
}
