*** Settings ***
Resource        ${RENODEKEYWORDS}
Suite Setup     Setup
Suite Teardown  Teardown
Test Teardown   Test Teardown

*** Test Cases ***
Firmware Boots On STM32F4 Discovery
    Execute Command    mach create
    Execute Command    machine LoadPlatformDescription @platforms/boards/stm32f4_discovery-kit.repl
    Execute Command    sysbus LoadELF ${ELF}

    Execute Command    emulation RunFor "0.01"

    ${pc}=    Execute Command    cpu PC
    Should Contain    ${pc}    0x800
