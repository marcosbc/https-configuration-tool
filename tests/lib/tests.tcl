proc scenario {description code} {
    message info2 $description
    uplevel $code
}

proc expect_test {test pattern} {
    puts [expect {
        $pattern {
            success "\n\[OK\] $test"
        }
        default {
            failed "\n\[FAILED\] $test: Did not find pattern: $pattern"
        }
    }]
}

proc file_test {test type path} {
    set file_exists 0
    if {[glob -nocomplain $path] != ""} {
        set file_exists 1
    }
    if {($file_exists && $type == "exists")
        || (!$file_exists && $type == "not_exists")} {
        success "\n\[OK\] $test"
    } else {
        failed "\n\[FAILED\] $test"
    }
}

proc string_test {test type string1 string2} {
    if {($string1 == $string2 && $type == "equal")
        || ($string1 != $string2 && $type == "not_equal")} {
        success "\n\[OK\] $test"
    } else {
        failed "\n\[FAILED\] $test: \"$string1\" $type \"$string2\""
    }
}

proc regexp_test {test type re str} {
    if {([regexp $re $str] && $type == "matches")
        || (![regexp $re $str] && $type == "does_not_match")} {
        success "\n\[OK\] $test"
    } else {
        failed "\n\[FAILED\] $test: \"$re\" $type \"$str\"" 
    }
}
