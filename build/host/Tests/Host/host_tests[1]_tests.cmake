add_test( TemplateTest.BasicTest /home/koenigr/git/stm32f407_project_template/build/host/Tests/Host/host_tests [==[--gtest_filter=TemplateTest.BasicTest]==] --gtest_also_run_disabled_tests)
set_tests_properties( TemplateTest.BasicTest PROPERTIES WORKING_DIRECTORY /home/koenigr/git/stm32f407_project_template/build/host/Tests/Host SKIP_REGULAR_EXPRESSION [==[\[  SKIPPED \]]==])
set( host_tests_TESTS TemplateTest.BasicTest)
