#!/usr/bin/expect

source env.tcl

proc open_bncert_changes_to_perform_page {domains {args {}}} {
    uplevel {
        create_valid_installdir $autodetected_installdir
        eval spawn sudo $tool --dry_run 1 --domains $sample_certificate_domains
        expect_test "Tool started" "*Welcome*"
        send "\r"
        expect_test "Domain validated" "*Changes to perform*"
    }
}

proc expect_changes_to_proceed_validated {} {
    uplevel {
        expect_test "Changes to proceed validated" "*Please provide a valid e-mail address*"
    }
}

proc expect_agree_to_changes {} {
    uplevel {
        expect_test "Asked to agree to the changes" "*Do you agree to these changes? \\\[Y/n\\\]: "
    }
}

proc expect_additional_configuration {} {
    uplevel {
        expect_test "Additional configuration page is shown" "*Additional configuration"
    }
}

# NOTE: We will be using sample_certificate_domains instead of valid_domains
# as the latter includes a domain that does not have a www subdomain, which
# changes the output of the "Additional configuration" page

scenario "Default options" {
    open_bncert_changes_to_perform_page
    expect_test "Web server will be stopped" "*Stop web server"
    expect_test "A certificate will be created" "*certificate for the domains*$sample_certificate_domains"
    expect_test "A cron job for renewing certificates will be added" "*Configure a cron job"
    expect_test "Server name will be configured" "*Configure web server name"
    expect_test "HTTP to HTTPS redirection will be enabled" "*Enable HTTP to HTTPS"
    expect_test "non-www to www redirection will be enabled" "*Enable non-www to www"
    expect_test "Web server will be started again" "*Start web server"
    expect_agree_to_changes
    send "\r"
    expect_changes_to_proceed_validated
    close_bncert_and_revert_changes
}

scenario "Allow disabling HTTP to HTTPS redirection" {
    open_bncert_changes_to_perform_page
    expect_test "HTTP to HTTPS redirection will be enabled" "*Enable HTTP to HTTPS"
    expect_agree_to_changes
    send "n\r"
    expect_additional_configuration
    expect_test "Disable HTTP to HTTPS redirection" "Enable HTTP to HTTPS redirection \\\[Y/n\\\]: "
    send "n\r"
    expect_test "Keep default for non-www to www redirection" "Enable non-www to www redirection \\\[Y/n\\\]: "
    send "\r"
    expect_test "Keep default for www to non-www redirection" "Enable www to non-www redirection \\\[y/N\\\]: "
    send "\r"
    expect_test "Back in changes to perform page" "*Changes to perform"
    # HTTP to HTTPS redirection should not be mentioned
    close_bncert_and_revert_changes
}

scenario "Allow disabling non-www to www redirection" {
    open_bncert_changes_to_perform_page
    expect_test "non-www to www redirection will be enabled" "*Enable non-www to www"
    expect_agree_to_changes
    send "n\r"
    expect_additional_configuration
    expect_test "Keep default for HTTP to HTTPS redirection" "Enable HTTP to HTTPS redirection \\\[Y/n\\\]: "
    send "\r"
    expect_test "Disable non-www to www redirection" "Enable non-www to www redirection \\\[Y/n\\\]: "
    send "n\r"
    expect_test "Keep default for www to non-www redirection" "Enable www to non-www redirection \\\[y/N\\\]: "
    send "\r"
    expect_test "Back in changes to perform page" "*Changes to perform"
    # non-www to www redirection should not be mentioned
    close_bncert_and_revert_changes
}

scenario "Allow enabling www to non-www redirection" {
    open_bncert_changes_to_perform_page
    expect_test "non-www to www redirection will be enabled (instead of www to non-www)" "*Enable non-www to www"
    expect_agree_to_changes
    send "n\r"
    expect_additional_configuration
    expect_test "Keep default for HTTP to HTTPS redirection" "Enable HTTP to HTTPS redirection \\\[Y/n\\\]: "
    send "\r"
    expect_test "Disable non-www to www redirection" "Enable non-www to www redirection \\\[Y/n\\\]: "
    send "n\r"
    expect_test "Enable www to non-www redirection" "Enable www to non-www redirection \\\[y/N\\\]: "
    send "y\r"
    expect_test "Back in changes to perform page" "*Changes to perform"
    expect_test "www to non-www redirection will be enabled" "*Enable www to non-www"
    # non-www to www redirection should not be mentioned
    close_bncert_and_revert_changes
}

scenario "Can not enable both non-www to www and www to non-www redirections at once" {
    open_bncert_changes_to_perform_page
    expect_test "non-www to www redirection will be enabled (instead of www to non-www)" "*Enable non-www to www"
    expect_agree_to_changes
    send "n\r"
    expect_additional_configuration
    expect_test "Keep default for HTTP to HTTPS redirection" "Enable HTTP to HTTPS redirection \\\[Y/n\\\]: "
    send "\r"
    expect_test "Disable non-www to www redirection" "Enable non-www to www redirection \\\[Y/n\\\]: "
    send "y\r"
    expect_test "Enable www to non-www redirection" "Enable www to non-www redirection \\\[y/N\\\]: "
    send "y\r"
    expect_test "Cannot enable both non-www to www and www to non-www redirections at once" "*cannot enable both non-www to www and www to non-www*Press \\\[Enter\\\] to continue:"
    send "\r"
    expect_additional_configuration
    close_bncert_and_revert_changes
}

# TODO
exit

#scenario "Missing domains are verified" {}

#scenario "Cannot add missing domains if all www and non-www combinations are specified"

scenario "Cron jobs won't be added/removed if --configure_cron option is disabled" {}

scenario "Allow disabling non-www and/or www domains that were not specified" {}

scenario "Show error if another ports 80 or 443 are busy" {}

scenario "HTTP to HTTPS redirection can be disabled if already applied" {}

scenario "Redirections can't be configured if custom configuration was added" {}

# If all domains specified include all non-www and www combination, and custom
# redirections are detected, the additional configuration page will be empty
scenario "Changes to perform page does not ask to agree if additional configuration page is empty" {}
