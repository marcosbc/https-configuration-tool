#!/usr/bin/expect

source env.tcl

catch {exec sudo crontab -u bitnami -r}

# TODO: Find a way to disable bitnami user

proc run_bncert {} {
    uplevel {
        spawn sudo $tool --use_staging 1 --domains $sample_certificate_domains --email $valid_email
        expect_test "Tool started" "*Welcome*"
        expect_test "Installdir was detected" "*Domain list*: "
        send "\r"
        expect_test "Asked to agree to the changes" "*Do you agree to these changes? \\\[Y/n\\\]: "
        send "\r"
        expect_test "Changes to proceed validated" "*Please provide a valid e-mail address*"
        send "\r"
        expect_test "Asked to agree to the Let's Encrypt SA" "*can be found at*https://*Do you agree to*? \\\[Y/n\\\]: "
        send "\r"
        expect_test "Tool finished" "*Success*"
    }
}

scenario "Cron jobs are added to user bitnami" {
    create_functional_installdir
    run_bncert
    set crontab_num_lines [crontab -u bitnami -l | wc -l]
    string_test "Only one crontab entry should have been added" equal $crontab_num_lines 1
    close_bncert_and_revert_changes
}

scenario "Multiple runs don't generate multiple added cron jobs" {
    create_functional_installdir
    run_bncert
    run_bncert
    set crontab_num_lines [crontab -u bitnami -l | wc -l]
    string_test "Only one crontab entry should have been added" equal $crontab_num_lines 1
    close_bncert_and_revert_changes
}

exit
# TODO

scenario "Cron jobs are added to root if user bitnami does not exist" {
    #exec sudo passwd -l bitnami
    #exec sudo passwd -u bitnami
}
