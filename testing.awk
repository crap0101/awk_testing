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
    GLOBAL_MUST_EXIT = 1
    MSG_TRUE = "OK"
    MSG_FALSE = "FAIL"
    REPORT["ok_tests_count"] = 0
    REPORT["fail_tests_count"] = 0
    REPORT["ignored_tests_count"] = 0
    REPORT["no_tests_count"] = 0
    REPORT["running"] = 0
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

function message(condition, msg) {
    # Print $msg and, either, MSG_TRUE or MSG_FALSE depending on $condition.
    printf("%s --> %s\n", msg, condition ? MSG_TRUE : MSG_FALSE) > "/dev/stderr"
}


#####################
# REPORTS FUNCTIONS #
#####################

function start_test_report() {
    REPORT["ok_tests_count"] = 0
    REPORT["fail_tests_count"] = 0
    REPORT["ignored_tests_count"] = 0
    REPORT["no_tests_count"] = 0
    REPORT["running"] = 1
}

function end_test_report() {
    REPORT["running"] = 0
}

function report() {
    if (REPORT["running"])
	print ("WARNING: tests seems to still be in progress...") > "/dev/stderr"
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
	    REPORT["ignored_tests_count"]) > "/dev/stderr"
}
