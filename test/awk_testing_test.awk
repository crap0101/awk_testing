
@include "testing"
# NOTE: use shell commands: true, false
BEGIN {
    # set an output file via the command line -v option
    # and save the default value for later use
    if (OUTPUT)
	_default_outfile = testing::set_outfile(OUTPUT)
    else
	_default_outfile = testing::get_outfile()
    # start with a fresh file:
    printf "" > testing::get_outfile()

    # report test later, meanwhile...
    testing::start_test_report()

    # TEST set_outfile
    _outfile = "fake_outfile"
    _prev = testing::set_outfile(_outfile)
    _rev = testing::set_outfile(_prev)
    # default output file is /dev/stdout if not changed from the command line
    testing::assert_equal("/dev/stdout", _default_outfile, 1, "set_outfile (default)")
    testing::assert_equal(_prev, OUTPUT ? OUTPUT : _default_outfile, 1, "set_outfile (prev)")
    testing::assert_equal(_rev, _outfile, 1, "set_outfile (revert)")
    
    ignore = 1
    # TEST assert_true
    if (! testing::assert_true(1, 1, "assert_true(1, 1)")) {
	print("ERROR: assert_true(1,1)") >> OUTFILE
	exit(1)
    }
    if (! testing::assert_true(1, 0, "assert_true(1, 0)")) {
	print("ERROR: assert_true(1,0)") >> OUTFILE
	exit(1)
    }
    if (testing::assert_true(0, 0, "! assert_true(0, 0) [MUST FAIL]", ignore)) {
	print("ERROR: assert_true(0,0)") >> OUTFILE
	exit(1)
    }

    # --- INTERLUDE --- #
    # TEST assert_command (which will be used later for other tests)
    if (testing::assert_command("false", 0, "assert_command(false) [MUST FAIL]", ignore)) {
	print("ERROR: assert_command(false)") >> OUTFILE
	exit(1)
    }
    if (! testing::assert_command("true", 0, "assert_command(true)")) {
	print("ERROR: assert_command(true)") >> OUTFILE
	exit(1)
    }
    cmd = "awk -i testing 'BEGIN { testing::assert_command(\"false\", 1)}'"
    if (testing::assert_command(cmd, 0, "! assert_command / assert_command [MUST FAIL]", ignore)) {
	print("ERROR: assert_command / assert_command") >> OUTFILE
	exit(1)
    }

    # --- REPRISE --- #
    # TEST assert_true
    cmd = "awk -i testing 'BEGIN { testing::assert_true(0, 1)}'"
    if (testing::assert_command(cmd, 0, "assert_command / assert_true [MUST FAIL]", ignore)) {
	print("ERROR: assert_command / assert_true") >> OUTFILE
	exit(1)
    }

    # now, assert_true is tested (we like to think so), we can define the other tests
    # upon it. Of course, also using assert_command as in the test above.

    # TEST assert_false
    testing::assert_true(testing::assert_false(0, 0, "", ignore), 1, "assert_false(0, 0)")
    testing::assert_true(testing::assert_false(0, 1, "", ignore), 1, "assert_false(0, 1)")
    testing::assert_true(! testing::assert_false(1, 0, "", ignore), 1, "assert_false(1, 0)")
    cmd = "awk -i testing 'BEGIN { testing::assert_false(1, 1)}'"
    testing::assert_true(! testing::assert_command(cmd, 0, "", ignore), 1, "assert_command / assert_false")

    # TEST assert_nothing
    testing::assert_true(testing::assert_nothing(0, 0, "", ignore), 1, "assert_nothing(0, 0)")
    testing::assert_true(testing::assert_nothing(0, 1, "", ignore), 1, "assert_nothing(0, 1)")
    testing::assert_true(testing::assert_nothing(1, 0, "", ignore), 1, "assert_nothing(1, 0)")
    testing::assert_true(testing::assert_nothing(1, 1, "", ignore), 1, "assert_nothing(1, 1)")

    # TEST assert_equal
    testing::assert_true(testing::assert_equal(1, 1, 0, "", ignore), 1, "assert_equal(1, 1, 0)")
    testing::assert_true(testing::assert_equal("1", "1", 1, "", ignore), 1, "assert_equal(\"1\", \"1\", 1)")
    testing::assert_false(testing::assert_equal(2, 1, 0, "", ignore), 1, "assert_equal(2, 1, 0)")
    cmd = "awk -i testing 'BEGIN { testing::assert_equal(2, 1, 1)}'"
    testing::assert_false(testing::assert_command(cmd, 0, "", ignore), 1, "assert_equal from system")

    # TEST assert_not_equal
    testing::assert_false(testing::assert_not_equal(1, 1, 0, "", ignore), 1, "assert_not_equal(1, 1, 0)")
    testing::assert_false(testing::assert_not_equal("1", "1", 0, "", ignore), 1, "assert_not_equal(\"1\", \"1\", 1)")
    testing::assert_false(testing::assert_not_equal("foo", "foo", 0, "", ignore), 1, "assert_not_equal(\"foo\", \"foo\", 1)")
    testing::assert_true(testing::assert_not_equal(2, 1, 0, "", ignore), 1, "assert_not_equal(2, 1, 0)")
    cmd = sprintf("awk -i testing 'BEGIN { testing::assert_not_equal(2, 1, 1, \"assert_not_equal from system()\")}' >> %s", testing::get_outfile())
    testing::assert_true(testing::assert_command(cmd, 0, "", ignore), 1, "assert_not_equal from system()")

    # TEST set_messages /set_messages_array / get_messages_array
    delete arr
    delete def_msg_arr
    # first, save the actual value, to be restored later
    testing::get_messages_array(def_msg_arr)
    
    testing::set_messages("prefix", "sep", "true", "FALSE")
    testing::get_messages_array(arr)
    testing::assert_equal(arr["prefix"], "prefix", 1, "PREFIX set to \"prefix\"")
    testing::assert_equal(arr["separator"], "sep", 1, "SEPARATOR set to \"sep\"")
    testing::assert_equal(arr["iftrue"], "true", 1, "MSG_TRUE set to \"true\"")
    testing::assert_equal(arr["iffalse"], "FALSE", 1, "MSG_FALSE set to \"FALSE\"")
    # now restore the original values
    testing::set_messages_array(def_msg_arr)
    testing::get_messages_array(arr)
    for (i in arr)
	testing::assert_equal(arr[i], def_msg_arr[i], 1, sprintf("<%s> restored to %s", i, def_msg_arr[i]))

    # test fail set
    delete arr
    arr["foobar"] = "err"
    testing::assert_false(testing::set_messages_array(arr), 1, "! set_messages_array with wrong indexes")

    
    testing::end_test_report()
    testing::report()

    printf("=================================\n" \
	   "---- REPORT'S FUNCTIONS TESTS ---\n") >> testing::get_outfile()
    # TEST report
    testing::assert_false(REPORT["running"], 1, "report running (no)")

    testing::start_test_report()

    testing::assert_true(REPORT["running"], 1, "report running (yes)")
    testing::assert_true(1, 0, "assert_true(1)")
    testing::assert_true(0, 0, "! assert_true(0)")
    testing::assert_nothing(1, 0, "assert_nothing(1)")
    testing::assert_nothing(0, 0, "assert_nothing(0)")

    testing::assert_true(0, 0, "! assert_true(0) [ignored]", ignore)
    testing::assert_true(1, 0, "! assert_true(0) [ignored]", ignore)
    testing::assert_true(ignore, 0, "! assert_true(ignore) [ignored]", ignore)

    testing::end_test_report()
    
    testing::assert_false(REPORT["running"], 1, "report running (no)")
    testing::assert_equal(REPORT["ok_tests_count"], 2, 1, "report ok count")
    testing::assert_equal(REPORT["fail_tests_count"], 1, 1, "report fail count")
    testing::assert_equal(REPORT["no_tests_count"], 2, 1, "report no count")
    testing::assert_equal(REPORT["ignored_tests_count"], 3, 1, "report ignore count")

    testing::report()
}
