#!/usr/bin/expect

source env.tcl

# TODO: The e-mail validation in the tool should be improved

scenario "No change is performed if --dry_run option is enabled" {
    create_valid_installdir $autodetected_installdir
    # Create a git repository in the installation directory, used to check if any changes were performed
    cd $autodetected_installdir
    catch {exec crontab -u bitnami -l | sudo tee crontab.txt}
    exec sudo git init
    exec sudo git add -A
    # Run the tool
    spawn sudo $tool --dry_run 1 --domains $sample_certificate_domains --email $valid_email
    expect_test "Tool started" "*Welcome*"
    send "\r"
    expect_test "Asked to agree to the changes" "*Do you agree to these changes? \\\[Y/n\\\]: "
    send "\r"
    expect_test "Changes to proceed validated" "*Please provide a valid e-mail address*"
    send "\r"
    expect_test "Asked to agree to the Let's Encrypt SA" "*can be found at*https://*Do you agree to*? \\\[Y/n\\\]: "
    send "\r"
    expect_test "The parameters were validated" "*Success*"
    # Check for changes
    catch {exec crontab -u bitnami -l | sudo tee crontab.txt}
    set diff [exec git diff]
    string_test "The diff should be empty" equal $diff ""
}
