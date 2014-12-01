
scope macro puts(string) {
    phk
    jsr _write_string_stack_relative
    db {string}, 0
}

// vim:ft=bass
