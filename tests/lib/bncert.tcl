proc add_valid_domains_to_hosts {} {
    uplevel {
        restore_hosts ;# avoid an aborted runs to mess up hosts files
        backup_hosts
        foreach domain $valid_domains {
            add_to_hosts "$public_ip_address $domain"
        }
    }
}

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

proc close_bncert_and_revert_changes {} {
    uplevel {
        catch {close}
        catch {exec sudo crontab -u bitnami -r}
        delete_installdir $autodetected_installdir
    }
}

proc add_apache_config {text} {
    set apacheDir /opt/bitnami/apache2
    if {[info exists ::env(INSTALLATION_TYPE)] && ::env(INSTALLATION_TYPE) == "multitier"} {
        set apacheDir /opt/bitnami/apache
    }
    exec sudo sed -i "s@<VirtualHost\\(.*\\)>@<VirtualHost>\\n[regsub -all {\n} $text {\n}]@" $apacheDir/conf/bitnami/bitnami.conf
}

proc add_apache_config_block {name text} {
    add_apache_config "  # BEGIN: $name
$text
  # END: $name"
}

proc add_bncert_www_to_nonwww_redirection {{with_block 1}} {
    set conf {  RewriteCond %{HTTP_HOST} ^www\.(.*)$ [NC]
  RewriteCond %{HTTP_HOST} !^(localhost|127.0.0.1)
  RewriteCond %{REQUEST_URI} !^/\.well-known
  RewriteRule ^(.*)$ http://%1$1 [R=permanent,L]}
    if {$with_block} {
        add_apache_config_block "Enable www to non-www redirection" $conf
    } else {
        add_apache_block $conf
    }
}
