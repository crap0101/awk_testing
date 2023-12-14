# Copyright (C) 2023,  Marco Chieppa | crap0101
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3 of the License,
# or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, see <https://www.gnu.org/licenses>.

#
# Description: tests facilities for awk programs.
#

@namespace "testing"

BEGIN {
    outfile = "foo"
    OUTFILE = "/dev/stdout"
    GLOBAL_MUST_EXIT = 1
    MSG_TRUE = "OK"
    MSG_FALSE = "FAIL"
    PREFIX = ""
    SEPARATOR = " --> "
    REPORT["ok_tests_count"] = 0
    REPORT["fail_tests_count"] = 0
    REPORT["ignored_tests_count"] = 0
    REPORT["no_tests_count"] = 0
    REPORT["running"] = 0
    STDERR = "/dev/stderr"
}

###################
# TESTS FUNCTIONS #
###################

function assert_true(condition, must_exit, msg, ignore,    ret) {
    # Check if $condition is true, exits with $must_exit
    # if the test fails.
    # Prints the optional message $mgs in any case.
    # For convenience, to *globally* ignore the $must_exit value,
    # one can set the GLOBAL_MUST_EXIT variable to 0
    # avoiding immediate exit in case of test failure.
    # As in the other assert_* functions, if $ignore is true
    # the test's result is not included in the global tests report.
    if (! condition) {
	ret = 0
	if (REPORT["running"] && (! ignore))
	    REPORT["fail_tests_count"] += 1
	if (msg)
	    message(ret, msg)
	if (must_exit && GLOBAL_MUST_EXIT)
	    exit(must_exit && GLOBAL_MUST_EXIT)
    } else {
	ret = 1
	if (REPORT["running"] && (! ignore))
	    REPORT["ok_tests_count"] += 1
	if (msg)
	    message(ret, msg)
    }
    if (ignore)
	REPORT["ignored_tests_count"] += 1
    return ret
}

function assert_false(condition, must_exit, msg, ignore,    ret) {
    # Check if $condition is false, exits with $must_exit
    # if the test fails.
    # Prints the optional message $mgs in any case.
    return assert_true(! condition, must_exit, msg, ignore)
}

function assert_nothing(condition, must_exit, msg, ignore,    ret) {
    # Special assert function. Returns always true, used only to check $condition.
    # Appends a string after $msg to signaling the actual evaluation of $condition. 
    # $must_exit has no means here, still usable but ignored.
    ret = assert_true(condition, 0, msg " [ignored: assert_nothing]", ignore)
    if (! ignore) {
	if (ret)
	    REPORT["ok_tests_count"] -= 1
	else
	    REPORT["fail_tests_count"] -= 1
    }
    REPORT["no_tests_count"] += 1
    return 1
}

function assert_equal(value1, value2, must_exit, msg, ignore,    ret) {
    # Check if $value1 == $values, exits with $must_exit
    # if the test fails.
    # Prints the optional message $mgs in any case.
    return assert_true(value1 == value2, must_exit, msg, ignore)
}

function assert_not_equal(value1, value2, must_exit, msg, ignore,    ret) {
    # Check if $value1 == $values, exits with $must_exit
    # if the test fails.
    # Prints the optional message $mgs in any case.
    return assert_true(value1 != value2, must_exit, msg, ignore)
}

function assert_command(cmd, must_exit, msg, ignore) {
    # Executes shell command $cmd using the builtin system() function.
    # Return true on success, false otherwise.
    return assert_true(system(cmd) == 0, must_exit, msg, ignore)
}


#####################
# UTILITY FUNCTIONS #
#####################

function set_outfile(filename,    __prev) {
    # Prints messagges on $filename (default is to print on stdout).
    # Returns the previous set output file.
    __prev = OUTFILE
    OUTFILE = filename
    return __prev
}

function get_outfile() {
    # Returns the current output file.
    return OUTFILE
}

function set_messages(prefix, separator, iftrue, iffalse) {
    # Sets some formatting options for the messagges
    # printed by the testing functions.
    # The format string will be composed as
    # "$prefix$ MESSAGE $separator ($iftrue|$iffalse)\n"
    # (without spaces between them, showed now only for clarity).
    # For example, the call of  assert_true(1==1, must_exit, "1 equals 1?"
    # using the default $prefix, $sepatator and $iftrue strings, will print:
    # "1 equals 1? --> OK".
    PREFIX = prefix
    SEPARATOR = separator
    MSG_TRUE = iftrue
    MSG_FALSE = iffalse
}

function set_messages_array(arr) {
    # Like <set_messages>, but reading the values from the $arr array,
    # where the index must be (any of) "prefix", "separator", "iftrue",
    # "iffalse". The meaning is the same as the <set_message> function.
    # Returns false if any $arr index are not one of the above mentionedm
    # otherwise returns true.
    for (i in arr)
	switch (i) {
	    case "prefix":
		PREFIX = arr[i]
		break
	    case "separator":
		SEPARATOR = arr[i]
		break
	    case "iftrue":
		MSG_TRUE = arr[i]
		break
	    case "iffalse":
		MSG_FALSE = arr[i]
		break
	    default:
		printf("Unknown format string value <%s>\n", i) >> STDERR
		return 0
	}
    return 1
}

function get_messages_array(arr) {
    # Fills $arr with the previous set (with <set_messages>
    # or <set_messages_array> functions) messages formatting strigns,
    # or the default values.
    # The indexes are the same of the <set_messages_array> function.
    # NOTE: $arr is deleted at function call.
    delete arr
    arr["prefix"] = PREFIX
    arr["separator"] = SEPARATOR
    arr["iftrue"] = MSG_TRUE
    arr["iffalse"] = MSG_FALSE
}

function message(condition, msg) {
    # Formats and prints on the file choosed with <set_outfile>
    # the string $msg following the rules described
    # in the <set_messages> function,
    printf("%s%s %s %s\n",
	   PREFIX, msg, SEPARATOR, condition ? MSG_TRUE : MSG_FALSE) >> OUTFILE
}


#####################
# REPORTS FUNCTIONS #
#####################

function start_test_report() {
    # Set some variables for a new tests report.
    # Call it before the first test case.
    REPORT["ok_tests_count"] = 0
    REPORT["fail_tests_count"] = 0
    REPORT["ignored_tests_count"] = 0
    REPORT["no_tests_count"] = 0
    REPORT["running"] = 1
}

function end_test_report() {
    # Set some report's variables. when the tests report has done.
    # Call it after the last test case.
    REPORT["running"] = 0
}

function report() {
    # Prints the report results.
    if (REPORT["running"])
	print ("WARNING: tests seems to still be in progress...") >> OUTFILE
    printf ("===== TESTS REPORT =====\n" \
	    "total tests:      %3d\n" \
	    "successful tests: %3d\n" \
	    "failed tests:     %3d\n" \
	    "no_tests_count:   %3d\n" \
	    "ignored tests:    %3d\n",
	    REPORT["ok_tests_count"] + REPORT["fail_tests_count"] + REPORT["no_tests_count"],
	    REPORT["ok_tests_count"],
	    REPORT["fail_tests_count"],
	    REPORT["no_tests_count"],
	    REPORT["ignored_tests_count"]) >> OUTFILE
}
