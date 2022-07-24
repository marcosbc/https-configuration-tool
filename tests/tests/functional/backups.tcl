#!/usr/bin/expect

source env.tcl

# NOTE: We take into advantage the fact that we don't ask for installidr if
# it was properly detected

scenario "Backups are created after installdir is detected" {
    create_valid_installdir $autodetected_installdir
    spawn sudo $tool
    expect_test "Tool started" "*Welcome*"
    expect_test "Installdir was detected" "*Domain list \\\[\\\]: "
    close
    file_test "Backup files were detected" exists [file join $autodetected_installdir * conf *.back.*]
    delete_installdir $autodetected_installdir
}

scenario "Backups are not created if --dry_run option is enabled" {
    create_valid_installdir $autodetected_installdir
    spawn sudo $tool --dry_run 1
    expect_test "Tool started" "*Welcome*"
    expect_test "Installdir was detected" "*Domain list \\\[\\\]: "
    close
    file_test "Backup files were not detected" not_exists [file join $autodetected_installdir * conf *.back.*]
    delete_installdir $autodetected_installdir
}
