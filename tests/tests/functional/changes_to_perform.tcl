#!/usr/bin/expect

source env.tcl

# TODO: Improve redirection detection tests (e.g. expect not to contain words)

proc expect_installdir_validated {} {
    expect_test "Tool started" "*Welcome*"
}

proc expect_agree_to_changes {} {
    uplevel {
        expect_test "Asked to agree to the changes" "*Do you agree to these changes? \\\[Y/n\\\]: "
    }
}

proc expect_changes_to_proceed_validated {} {
    uplevel {
        expect_test "Changes to proceed validated" "*Please provide a valid e-mail address*"
    }
}

scenario "Default options validate correctly" {
    create_functional_installdir
    eval spawn sudo $tool --use_staging 1 --domains $sample_certificate_domains
    expect_installdir_validated
    send "\r"
    expect_agree_to_changes
    send "\r"
    expect_changes_to_proceed_validated
    close_bncert_and_revert_changes
}

scenario "Redirections won't be configured if configuration contains one not created by the tool" {
    create_functional_installdir
    add_bncert_www_to_nonwww_redirection 0
    expect_test "Warning: Custom redirections were detected*Press \\\[Enter\\\] to continue:"
    close_bncert_and_revert_changes
}

# TODO
exit

scenario "Services are not stopped if --manage_services option is enabled" {}
