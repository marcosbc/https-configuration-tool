proc get_public_ip {} {
    set public_ip [exec curl -s http://myip.bitnami.com]
    if {![regexp {^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$} $public_ip]} {
        message fatalerror "Could not determine public IP address"
    }
    return $public_ip
}

proc backup_hosts {} {
    global output_dir
    if {![file exists [file join $output_dir hosts.back]]} {
        exec sudo cp /etc/hosts [file join $output_dir hosts.back]
    }
}

proc add_to_hosts {text} {
    global output_dir
    exec echo "$text #bncert-test" | sudo tee -a /etc/hosts
}

proc restore_hosts {} {
    global output_dir
    if {[file exists [file join $output_dir hosts.back]]} {
        exec cat [file join $output_dir hosts.back] | grep -v '#bncert-test' | sudo tee [file join $output_dir hosts.back]
        exec sudo cp [file join $output_dir hosts.back] /etc/hosts
    }
}
