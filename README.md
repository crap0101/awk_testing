
====================
=== DESCRIPTION  ===
====================
Test framework (a sort of) for awk programs.


===========
== USAGE ==
===========
# coarse usage:
@include "testing"
testing::start_test_report()
testing::assert_true(something, exit_if_fail, message)
testing::end_test_report()
testing::report()

========================
== module's functions ==
========================
assert_true(condition, must_exit, msg, ignore)
  Check if $condition is true, exits with $must_exit if the test fails.
  Prints the optional message $mgs in any case.
  For convenience, to *globally* ignore the $must_exit value, one can set the
  GLOBAL_MUST_EXIT variable to 0 avoiding immediate exit in case of test failure.
  As in the other assert_* functions, if $ignore is true
  the test's result is not included in the global tests report.

assert_false(condition, must_exit, msg, ignore)
  Check if $condition is false, exits with $must_exit if the test fails.
  Prints the optional message $mgs in any case.

assert_nothing(condition, must_exit, msg, ignore)
  Special assert function. Returns always true, used only to check $condition.
  Appends a string after $msg to signaling the actual evaluation of $condition. 
  $must_exit has no means here, still usable but ignored.

assert_equal(value1, value2, must_exit, msg, ignore)
  Check if $value1 == $values, exits with $must_exit if the test fails.
  Prints the optional message $mgs in any case.

assert_not_equal(value1, value2, must_exit, msg, ignore)
  Check if $value1 == $values, exits with $must_exit if the test fails.
  Prints the optional message $mgs in any case.

assert_command(cmd, must_exit, msg, ignore)
  Executes shell command $cmd using the builtin system() function.
  Return true on success, false otherwise.

set_outfile(filename)
  Prints messagges on $filename (default is to print on stdout).
  Returns the previous set output file.

get_outfile()
  Returns the current output file.

message(condition, msg)
  Prints $msg and, either, MSG_TRUE or MSG_FALSE depending on $condition.

start_test_report()
  Set some variables for a new tests report.
  Call it before the first test case.

end_test_report()
  Set some report's variables. when the tests report has done.
  Call it after the last test case.

report()
  Prints the report results.


=============================
== RUNNING TESTING'S TESTS ==
=============================
$ awk -f test/awk_testing_test.awk
# to redirect the tests output to another file:
awk -v OUTPUT=another_file -f test/awk_testing_test.awk