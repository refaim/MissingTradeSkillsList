mtsl_module_test_start("OOP")

do
    ---@class TestClass
    ---@field a number
    local TestClass = mtsl_declare_class({})
    TestClass.a = 1

    function TestClass:GetProperty() return self.a end
    function TestClass:SetProperty(v) self.a = v end
    function TestClass:Foo() return "foo" end
    function TestClass:Bar() return "bar" end

    local case = "mtsl_new"
    mtsl_test(case, "class property: a", function() assert(TestClass:GetProperty() == 1) end)
    TestClass:SetProperty(2)
    mtsl_test(case, "class property: a", function() assert(TestClass:GetProperty() == 2) end)
    mtsl_test(case, "class methods: foo", function() assert(TestClass:Foo() == "foo") end)
    mtsl_test(case, "class methods: bar", function() assert(TestClass:Bar() == "bar") end)

    mtsl_test(case, "create instance of a class", function()
        local object = mtsl_new(TestClass)
        assert(object ~= TestClass)
        assert(object:Foo() == "foo")
        assert(object:Bar() == "bar")
        assert(object:GetProperty() == 2)
        object:SetProperty(3)
        assert(object:GetProperty() == 3)
        assert(TestClass:GetProperty() == 2)
    end)
end

do
    local TestClass = mtsl_declare_class({})
    function TestClass:A() return 0 end
    function TestClass:B() return 1 end

    local TestInterface = mtsl_declare_interface()
    local TestImpl = mtsl_declare_class({ implements = TestInterface })

    local case = "mtsl_instance_of"
    mtsl_test(case, "that class", function() assert(mtsl_instance_of(mtsl_new(TestClass), TestClass)) end)
    mtsl_test(case, "other class", function() assert(not mtsl_instance_of(mtsl_new(TestImpl), TestClass)) end)
    mtsl_test(case, "is interface", function() assert(mtsl_instance_of(mtsl_new(TestImpl), TestInterface)) end)
    mtsl_test(case, "is not interface", function() assert(not mtsl_instance_of(mtsl_new(TestClass), TestInterface)) end)
    mtsl_test(case, "empty table and class", function() assert(not mtsl_instance_of({}, TestClass)) end)
    mtsl_test(case, "empty table and interface", function() assert(not mtsl_instance_of({}, TestInterface)) end)
end

do
    local TestClass = mtsl_declare_class({})
    local TestInterface = mtsl_declare_interface()
    
    local case = "mtsl_is_class"
    mtsl_test(case, "empty table", function () assert(not mtsl_is_class({})) end)
    mtsl_test(case, "class", function () assert(mtsl_is_class(TestClass)) end)
    mtsl_test(case, "interface", function () assert(not mtsl_is_class(TestInterface)) end)
end

do
    local TestClass = mtsl_declare_class({})
    local TestInterface = mtsl_declare_interface()

    local case = "mtsl_is_interface"
    mtsl_test(case, "empty table", function () assert(not mtsl_is_interface({})) end)
    mtsl_test(case, "class", function () assert(not mtsl_is_interface(TestClass)) end)
    mtsl_test(case, "interface", function () assert(mtsl_is_interface(TestInterface)) end)
end

do
    local TestClass = mtsl_declare_class({})
    local TestInterface = mtsl_declare_interface()
    local TestImpl = mtsl_declare_class({ implements = TestInterface })

    local case = "mtsl_list_of"
    mtsl_test(case, "empty table and class", function () assert(mtsl_list_of({}, TestClass)) end)
    mtsl_test(case, "empty table and interface", function () assert(mtsl_list_of({}, TestInterface)) end)
    mtsl_test(case, "list of class instances (class)", function () assert(mtsl_list_of({mtsl_new(TestClass), mtsl_new(TestClass)}, TestClass)) end)
    mtsl_test(case, "list of class instances (interface)", function () assert(not mtsl_list_of({mtsl_new(TestClass), mtsl_new(TestClass)}, TestInterface)) end)
    mtsl_test(case, "list of interface instances (class)", function () assert(not mtsl_list_of({mtsl_new(TestImpl), mtsl_new(TestImpl)}, TestClass)) end)
    mtsl_test(case, "list of interface instances (interface)", function () assert(mtsl_list_of({mtsl_new(TestImpl), mtsl_new(TestImpl)}, TestInterface)) end)
    mtsl_test(case, "list of mixed instances", function () assert(not mtsl_list_of({mtsl_new(TestClass), mtsl_new(TestImpl)}, TestClass)) end)
    mtsl_test(case, "list of stuff", function () assert(not mtsl_list_of({TestClass, true, "a"}, TestClass)) end)
end

mtsl_module_test_end("OOP")
