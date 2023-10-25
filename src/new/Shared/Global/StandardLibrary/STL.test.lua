mtsl_module_test_start("STL")

do
    local case = "mtsl_std_is_empty"
    mtsl_test(case, "empty table", function() assert(mtsl_is_empty({})) end)
    mtsl_test(case, "k-table", function() assert(not mtsl_is_empty({ ["k"] = 1})) end)
    mtsl_test(case, "v-table", function() assert(not mtsl_is_empty({ "a"})) end)
    mtsl_test(case, "kv-table-1", function() assert(not mtsl_is_empty({ ["k"] = 1, "a"})) end)
    mtsl_test(case, "kv-table-2", function() assert(not mtsl_is_empty({ "a", ["k"] = 1})) end)
    mtsl_test(case, "nil-v-table", function() assert(not mtsl_is_empty({ nil, "a"})) end)
end

mtsl_module_test_end("STL")
