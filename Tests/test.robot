*** Settings ***
Resource    ../Resources/App.resource
Resource    ../Resources/Customer.resource
Library    ../Libraries/CommonLibrary.py

Suite Setup    Suite Init
Suite Teardown    Capture Page Screenshot


*** Test Cases ***

TEST-1
    [Documentation]    ADD FIRST 5 USERS
    Add First 5 Users

TEST-2
    [Documentation]    UPDATE EXISTING CUSTOMER
    Update Customers 6 Through 10

TEST-3
    [Documentation]    LOG TABLE DATA
    Log Customer Table Data

TEST-4
    [Documentation]    ANALYZE USER SPENDING
    Validate Total Customer Spending


*** Keywords ***
Suite Init
    Launch Browser
    Login User
    ${users}    Get Users
    Set Suite Variable    ${USERS}    ${users}
