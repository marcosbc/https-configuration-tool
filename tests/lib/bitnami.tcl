proc delete_installdir {installdir} {
    if {[file exists $installdir]} {
        catch {exec sudo $installdir/ctlscript.sh stop}
        exec sudo rm -rf $installdir
    }
}

proc create_empty_installdir {installdir} {
    delete_installdir $installdir
    exec sudo mkdir -p $installdir
}

proc create_valid_installdir {installdir {working_scripts 1}} {
    create_empty_installdir $installdir
    cd $installdir
    exec sudo touch properties.ini ctlscript.sh changelog.txt README.txt
    if {!$working_scripts} {
        exec echo "exit 1" | sudo tee ctlscript.sh
    }
    exec sudo chmod a+x ctlscript.sh
    exec echo "\[General\]\ninstalldir=$installdir" | sudo tee properties.ini
    # Create Apache folder structure
    exec sudo mkdir -p apache2/conf/bitnami apache2/bin
    exec sudo touch apache2/conf/httpd.conf apache2/conf/bitnami/bitnami.conf apache2/bin/apachectl
    exec sudo chmod a+x apache2/bin/apachectl
}

proc add_tool_to_installdir {tool installdir} {
    cd $installdir
    exec sudo mkdir toolname
    exec sudo ln -s $installdir/toolname/[file tail $tool] toolname-tool
    exec sudo cp $tool toolname
}

# This will be used for integration tests, but installdir is forced to /opt/bitnami
proc create_functional_installdir {} {
    upvar input_dir archive_dir
    create_empty_installdir /opt/bitnami
    exec sudo tar xzf $archive_dir/bitnami.tar.gz -C /opt
    catch {exec sudo /opt/bitnami/ctlscript.sh start}
}

proc copy_sample_certificates {{installdir {}}} {
    upvar input_dir local_input_dir
    upvar autodetected_installdir default_installdir
    if {$installdir == ""} {
        set installdir $default_installdir
    }
    set certs_dir $installdir/letsencrypt/certificates
    exec sudo mkdir -p $certs_dir
    foreach cert_file [glob $local_input_dir/sample_certificates/*] {
        exec sudo cp $cert_file $certs_dir
    }
}
