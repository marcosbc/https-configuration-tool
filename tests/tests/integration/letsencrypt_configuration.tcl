#!/usr/bin/expect

source env.tcl

# TODO: The e-mail validation in the tool should be improved

proc open_bncert_letsencrypt_configuration_page {{args {}}} {
    eval [subst {uplevel {
        create_valid_installdir \$autodetected_installdir
        eval spawn sudo \$tool --dry_run 1 --domains \$sample_certificate_domains $args
        expect_test "Tool started" "*Welcome*"
        expect_test "Installdir was detected" "*Domain list*: "
        send "\r"
        expect_test "Asked to agree to the changes" "*Do you agree to these changes?*: "
        send "\r"
        expect_test "Changes to proceed validated" "*Please provide a valid e-mail address*"
    }}]
}

proc expect_email_address {} {
    uplevel {
        expect_test "E-mail address prompted" "*Email address \\\[*\\\]: "
    }
}

proc expect_letsencrypt_sa {} {
    uplevel {
        expect_test "Asked to agree to the Let's Encrypt SA" "*can be found at*https://*Do you agree to*? \\\[Y/n\\\]: "
    }
}

proc expect_finalpage {} {
    uplevel {
        expect_test "Changes to proceed validated" "*Please provide a valid e-mail address*"
    }
}

scenario "Invalid e-mail addresses are not allowed" {
    open_bncert_letsencrypt_configuration_page
    foreach mail {asdfg asdfg@ asdfg@doma!n} {
        expect_email_address
        send "$mail\r"
        expect_letsencrypt_sa
        send "\r"
        expect_test "A wrong e-mail was detected" "\r\r\nPress \\\[Enter\\\] to continue:"
        send "\r"
    }
    close_bncert_and_revert_changes
}

scenario "Must accept Let's Encrypt Subscriber Agreement" {
    open_bncert_letsencrypt_configuration_page
    expect_email_address
    send "\r"
    expect_letsencrypt_sa
    send "n\r"
    expect_email_address
    close_bncert_and_revert_changes
}

scenario "Can continue if e-mail address is validated and Let's Encrypt Subscriber Agreement is accepted" {
    open_bncert_letsencrypt_configuration_page
    expect_email_address
    send "$valid_email\r"
    expect_letsencrypt_sa
    send "\r"
    expect_test "The parameters were validated" "*Success*"
    close_bncert_and_revert_changes
}

scenario "E-mail address can be passed via --email parameter" {
    open_bncert_letsencrypt_configuration_page
    expect_email_address
    send "\r"
    expect_letsencrypt_sa
    send "\r"
    expect_test "The parameters were validated" "*Success*"
    close_bncert_and_revert_changes
}
