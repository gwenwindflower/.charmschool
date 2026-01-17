function logirl_tester -d "Diagnostic tool for checking all output styles from the logirl helper function"
    echo "================================"
    echo "Testing logirl --flag option"
    echo "================================"
    echo ""

    echo "TEST 1: Valid short flag formats"
    echo ---------------------------------
    logirl -f h/help help_cmd
    logirl -f v/version help_cmd
    logirl -f n/no-cache help_cmd
    logirl -f D/debug help_cmd
    echo ""

    echo "TEST 2: Valid with different message types"
    echo -------------------------------------------
    logirl -f s/save success_msg
    logirl -f l/load info_msg
    logirl -f d/delete error_msg
    logirl -f u/update special_msg
    echo ""

    echo "TEST 3: Combined with other options"
    echo ------------------------------------
    logirl -f h/help -i "?" help_cmd
    logirl -f v/version -t "[OPT]" help_cmd
    echo ""

    echo "TEST 4: Error cases (should show error messages)"
    echo -------------------------------------------------
    echo "Missing separator:"
    logirl -f help help_cmd
    echo ""

    echo "Empty short flag:"
    logirl -f /help help_cmd
    echo ""

    echo "Empty long flag:"
    logirl -f h/ help_cmd
    echo ""

    echo "Too many separators:"
    logirl -f h/help/extra help_cmd
    echo ""

    echo "================================"
    echo "All tests complete!"
    echo "================================"
end
