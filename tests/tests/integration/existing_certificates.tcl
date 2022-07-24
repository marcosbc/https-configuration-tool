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

# TODO: Implement test for checking that missing domains are properly detected for the certificate

scenario "Should ask to use an existing Let's Encrypt certificate if domains match" {
    set domains $sample_certificate_domains
    open_bncert_domains_page $domains
    copy_sample_certificates
    send "\r"
    expect_test "The certificate was detected" "*Warning: A certificate*already exists"
    expect_test "Domains match" "*will be used*Press \\\[Enter\\\] to continue:"
    send "\r"
    expect_bncert_domain_validated
    expect_test "Explicit mention that the existing certificate will be used/renewed" "*use an existing*certificate and renew*"
    close_bncert_and_revert_changes
}

scenario "Should ask to replace an existing Let's Encrypt certificate if domains do not match" {
    set domains $valid_domains
    open_bncert_domains_page $domains
    copy_sample_certificates
    foreach answer {n y} {
        send "\r"
        expect_test "The certificate was detected" "*A certificate was found"
        expect_test "Domains mismatch" "*It is registered for a different set of domains"
        expect_test "Asked to create a new certificate" "*create a new one? \\\[y/N\\\]: "
        send "$answer\r"
        if {$answer == "n"} {
            expect_test "A warning is shown" "Press \\\[Enter\\\] to continue:"
            send "\r"
            expect_test "Back to domains page" "*Domain list \\\[$domains\\\]: "
        }
    }
    expect_bncert_domain_validated
    expect_test "Explicit mention that the existing certificate will be revoked" "*Revoke existing Let's Encrypt certificate"
    expect_test "Explicit mention that a new certificate will be created" "*certificate for the domains*"
    close_bncert_and_revert_changes
}
