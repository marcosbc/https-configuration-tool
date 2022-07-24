#!/usr/bin/expect

source env.tcl

# Avoid issues if the installdir exists before running tests
delete_installdir $autodetected_installdir

# NOTES:
# If the installdir page is not shown, and we're getting asked for an input,
# it means the installdir was automatically detected

scenario "Shows installdir parameter when an invalid value is detected" {
    create_empty_installdir $autodetected_installdir
    spawn sudo $tool --dry_run 1 --installdir $autodetected_installdir
    expect_test "Tool started" "*Welcome*"
    expect_test "Asked for installdir" "*installation directory \\\[$autodetected_installdir\\\]: "
    close
    delete_installdir $autodetected_installdir
}

scenario "Does not show installdir parameter when a valid value is detected" {
    create_valid_installdir $autodetected_installdir
    spawn sudo $tool --dry_run 1 --installdir $autodetected_installdir
    expect_test "Tool started" "*Welcome*"
    expect_test "Installdir was detected" "*Domain list \\\[\\\]: "
    close
    delete_installdir $autodetected_installdir
}

scenario "Installdir automatic detection for $autodetected_installdir" {
    create_valid_installdir $autodetected_installdir
    spawn sudo $tool --dry_run 1
    expect_test "Tool started" "*Welcome*"
    expect_test "Installdir was detected" "*Domain list \\\[\\\]: "
    close
    delete_installdir $autodetected_installdir
}

scenario "Installdir automatic detection for tool location" {
    create_valid_installdir $undetected_installdir
    add_tool_to_installdir $tool $undetected_installdir
    spawn sudo $undetected_installdir/toolname-tool --dry_run 1
    expect_test "Tool started" "*Welcome*"
    expect_test "Installdir was detected" "*Domain list \\\[\\\]: "
    close
}

scenario "Installdir automatic detection for --installdir" {
    create_valid_installdir $undetected_installdir
    spawn sudo $tool --dry_run 1 --installdir $undetected_installdir
    expect_test "Tool started" "*Welcome*"
    expect_test "Installdir was detected" "*Domain list \\\[\\\]: "
    close
}

scenario "Installdir could not be detected automatically, is manually specified" {
    create_valid_installdir $undetected_installdir
    spawn sudo $tool --dry_run 1
    expect_test "Tool started" "*Welcome"
    expect_test "Asked for installdir" "*installation directory \\\[\\\]: "
    send "$undetected_installdir\r"
    expect_test "Installdir was detected" "*Domain list \\\[\\\]: "
    close
}
