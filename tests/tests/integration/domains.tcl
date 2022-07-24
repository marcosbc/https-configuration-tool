#!/usr/bin/expect

source env.tcl

proc open_bncert_domains_page {{domains {}} {args {}}} {
    eval [subst {uplevel {
        create_valid_installdir \$autodetected_installdir
        if {"$domains" == ""} {
            eval spawn sudo \$tool --dry_run 1 $args
        } else {
            eval spawn sudo \$tool --dry_run 1 --domains {"$domains"} $args
        }
        expect_test "Tool started" "*Welcome*"
        expect_test "Installdir was detected" {*Domain list \\\[$domains\\\]: }
    }}]
}

proc expect_bncert_domain_validated {} {
    uplevel {
        expect_test "Domain validated" "*Changes to perform*"
    }
}

restore_hosts
set public_ip_address [get_public_ip]
add_valid_domains_to_hosts

# NOTES: For the verifications, we take advantage of the facts that the tool
# relies on 'getent' for getting hosts (which can manipulated by modifying
# the '/etc/hosts' file), and that it relies in 'myip.bitnami.com' for getting
# the machine's public IP address

# TODO: Do not quit if public IP validation failed
# TODO: Implement test for public IP validation error in case the user rejects

scenario "One valid domain can be specified" {
    open_bncert_domains_page
    send "[lindex $valid_domains 0]\r"
    expect_bncert_domain_validated
    close_bncert_and_revert_changes
}

scenario "Multiple valid domains can be specified" {
    open_bncert_domains_page
    send "$valid_domains\r"
    expect_bncert_domain_validated
    close_bncert_and_revert_changes
}

scenario "One domain can be passed via the --domains option" {
    open_bncert_domains_page [lindex $valid_domains 0]
    send "\r"
    expect_bncert_domain_validated
    close_bncert_and_revert_changes
}

scenario "Multiple domains can be passed via the --domains option" {
    open_bncert_domains_page $valid_domains
    send "\r"
    expect_bncert_domain_validated
    close_bncert_and_revert_changes
}

scenario "An invalid domain is not accepted" {
    set domains "dom@!n.com"
    open_bncert_domains_page $domains
    send "\r"
    expect_test "Domain not validated" "*Warning: Please enter valid domains\r\r\nPress \\\[Enter\\\] to continue:"
    send "\r"
    expect_test "Back to domain page" "*Domain list \\\[$domains\\\]: "
    close_bncert_and_revert_changes
}

scenario "Domains with more than 64 characters are not allowed" {
    set domains "aaabbbcccdddeeefffggghhhiiijjjkkklllmmmnnnooopppqqqrrrssstttuuuvvvwwwxxxyyyzzz.com"
    open_bncert_domains_page $domains
    send "\r"
    expect_test "Domain not validated" "*Warning: Domains must have less than 64 characters\r\r\nPress \\\[Enter\\\] to continue:"
    send "\r"
    expect_test "Back to domain page" "*Domain list \\\[$domains\\\]: "
    close_bncert_and_revert_changes
}

foreach domain {xip.io nip.io} {
    scenario "$domain subdomains are not allowed" {
        set domains "11.22.33.44.$domain"
        open_bncert_domains_page $domains
        send "\r"
        expect_test "Domain not validated" "*Warning: * Please enter valid domains.\r\r\nPress \\\[Enter\\\] to continue:"
        send "\r"
        expect_test "Back to domain page" "*Domain list \\\[$domains\\\]: "
        close_bncert_and_revert_changes
    }
}

scenario "Domains that do not resolve to any IP address are not allowed" {
    set domains "thisdomaindoesnotresolve.com"
    open_bncert_domains_page $domains
    send "\r"
    expect_test "The domain validation failed" "*Warning: * does not resolve*Press \\\[Enter\\\] to continue:"
    send "\r"
    expect_test "Back to domain page" "*Domain list \\\[$domains\\\]: "
    close_bncert_and_revert_changes
}

scenario "Domains that do not resolve to the current public IP address are not allowed" {
    set domains "bitnami.com"
    open_bncert_domains_page $domains
    send "\r"
    expect_test "The domain validation failed" "*Warning: *resolves to a different IP address*Press \\\[Enter\\\] to continue:"
    send "\r"
    expect_test "Back to domain page" "*Domain list \\\[$domains\\\]: "
    close_bncert_and_revert_changes
}

scenario "Domains that do not resolve properly are allowed if --perform_dns_validation option is disabled" {
    open_bncert_domains_page "bitnami.com" "--perform_dns_validation 0"
    send "\r"
    expect_bncert_domain_validated
    close_bncert_and_revert_changes
}

scenario "Public IP address validation not performed if --perform_public_ip_validation option is disabled" {
    open_bncert_domains_page $valid_domains "--perform_public_ip_validation 0"
    # Force public IP address validation to fail by making myip.bitnami.com unresolvable
    # Note that we rely directly on this site for gathering public IP addresses
    add_to_hosts "127.0.0.1 myip.bitnami.com"
    send "\r"
    expect_bncert_domain_validated
    close_bncert_and_revert_changes
}

scenario "Server name is the first domain" {
    open_bncert_domains_page $valid_domains
    send "\r"
    expect_bncert_domain_validated
    expect_test "Server name matches" "Configure web server name to: [lindex $valid_domains 0]"
    close_bncert_and_revert_changes
}

scenario "Server name can be overridden by specifying the --server_name option" {
    open_bncert_domains_page $valid_domains "--server_name customservername"
    send "\r"
    expect_bncert_domain_validated
    expect_test "Server name matches" "Configure web server name to: customservername"
    close_bncert_and_revert_changes
}

restore_hosts
exit

scenario "Can continue if public IP address validation fails" {
    open_bncert_domains_page $valid_domains
    # Force public IP address validation to fail by making myip.bitnami.com unresolvable
    # Note that we rely directly on this site for gathering public IP addresses
    add_to_hosts "127.0.0.1 myip.bitnami.com"
    send "\r"
    expect_test "Question is shown" "*The public IP address for this machine could not be detected.*Do you want to proceed anyways? \\\[y/N\\\]: "
    send "\r"

    #expect_test "description" "pattern"
    close_bncert_and_revert_changes
}
