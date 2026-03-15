*** Settings ***
Library    SeleniumLibrary
Variables    ../Variables/customers.py
Resource    App.resource

*** Keywords ***

#===============================================================================

Get Table Cell Text
    [Arguments]    ${row}    ${column}
    ${text}    Get Text    ((//tbody//tr)[${row}]//td)[${column}]
    RETURN    ${text}

Get Clean Customer Name
    [Arguments]    ${row}
    ${name}    Get Table Cell Text    ${row}    2
    ${name}    Clean Text    ${name}
    RETURN    ${name}

Parse Currency To Float
    [Arguments]    ${value}
    ${value}    Evaluate    float("""${value}""".replace("$","").replace(",",""))
    RETURN    ${value}

Get Customer News
    [Arguments]    ${row}
    ${news}    Get Element Attribute    ((//tbody//tr)[${row}]//td)[7]//*[name()="svg"]    aria-label
    RETURN    ${news}

Get Customer Segments
    [Arguments]    ${row}
    ${segments}    Set Variable    ${EMPTY}
    ${spans}    Get WebElements    xpath=((//tbody//tr)[${row}]//td)[8]//div//div//span
    ${flag}    Set Variable    0

    FOR    ${span}    IN    @{spans}
        ${text}    Get Text    ${span}
        IF    ${flag}==0
            ${segments}    Set Variable    ${text}
            ${flag}    Set Variable    1
        ELSE
            ${segments}    Set Variable    ${segments}, ${text}
        END
    END

    RETURN    ${segments}

Validate Customer Form Values
    [Arguments]    ${user}

    ${locators}    Create List
    ...    ${customers_txt_first_name}
    ...    ${customers_txt_last_name}
    ...    ${customers_txt_email}
    ...    ${customers_txt_birthday}
    ...    ${customers_txt_address}
    ...    ${customers_txt_city}
    ...    ${customers_txt_stateAbbr}
    ...    ${customers_txt_zipcode}
    ...    ${customers_txt_password}
    ...    ${customers_txt_confirm_password}

    ${expected_values}    Create List
    ...    ${user['first_name']}
    ...    ${user['last_name']}
    ...    ${user['email']}
    ...    ${user['birthday']}
    ...    ${user["address"]["street"]} ${user["address"]["suite"]}
    ...    ${user["address"]["city"]}
    ...    ${user["address"]['stateAbbr']}
    ...    ${user["address"]['zipcode']}
    ...    ${user['password']}
    ...    ${user['password']}

    FOR    ${i}    ${locator}    IN ENUMERATE    @{locators}
        Mouse Over    ${locator}
        ${value_text}    Get Value    ${locator}

        IF    '${locator}'=='${customers_txt_birthday}'
            ${value_text}    Format Birthday    ${value_text}
        END

        Should Be Equal As Strings    ${expected_values[${i}]}    ${value_text}
    END

#===============================================================================

Open Create Modal
    Click Element    //a[text()="Create"]
    Wait Until Element Is Visible    //h6[descendant::span[text()="Create Customer"]]

Add A Customer
    [Arguments]    ${user}
    Navigate    Customers
    Open Create Modal
        
    Input Text    ${customers_txt_first_name}    ${user['first_name']}
    Input Text    ${customers_txt_last_name}    ${user['last_name']}
    Input Text    ${customers_txt_email}    ${user['email']}
    Input Text    ${customers_txt_birthday}    ${user['birthday']}
    Input Text    ${customers_txt_address}    ${user["address"]["street"]} ${user["address"]["suite"]}
    Input Text    ${customers_txt_city}    ${user["address"]["city"]}
    Input Text    ${customers_txt_stateAbbr}    ${user["address"]['stateAbbr']}
    Input Text    ${customers_txt_zipcode}    ${user["address"]['zipcode']}
    Input Text    ${customers_txt_password}    ${user['password']}
    Input Text    ${customers_txt_confirm_password}    ${user['password']}
    Click Button    ${customers_btn_save}
    Wait Until Element Is Visible    //div[text()="Customer created"]

Add First 5 Users
    FOR    ${user}    IN    @{USERS}[0:5]
        Add A Customer    ${user}
        Verify If Customer Exist In The Table    ${user}
        Verify Customer Identity Details    ${user}
    END


#===============================================================================

Update A Customer
    [Arguments]    ${user}    ${i}
    Navigate    Customers

    ${user_row}    Get Customer Rows    ${user}
    Wait Until Element Is Visible    (//tbody//tr)[${i}]//td[2]
    Click Element    (//tbody//tr)[${i}]//td[2]
    Wait Until Element Is Visible    ${customers_txt_first_name}
        
    Clear Then Input Text    ${customers_txt_first_name}    ${user['first_name']}
    Clear Then Input Text    ${customers_txt_last_name}    ${user['last_name']}
    Clear Then Input Text    ${customers_txt_email}    ${user['email']}
    Input Text    ${customers_txt_birthday}    ${user['birthday']}
    Clear Then Input Text    ${customers_txt_address}    ${user["address"]["street"]} ${user["address"]["suite"]}
    Clear Then Input Text    ${customers_txt_city}    ${user["address"]["city"]}
    Clear Then Input Text    ${customers_txt_stateAbbr}    ${user["address"]['stateAbbr']}
    Clear Then Input Text    ${customers_txt_zipcode}    ${user["address"]['zipcode']}
    Clear Then Input Text    ${customers_txt_password}    ${user['password']}
    Clear Then Input Text    ${customers_txt_confirm_password}    ${user['password']}
    Click Button    ${customers_btn_save}

Update Customers 6 Through 10
    ${start}    Set Variable    5
    ${end}    Set Variable    10
    FOR    ${i}    ${user}    IN ENUMERATE    @{USERS}[${start}:${end}]    start=${start}
        Update A Customer    ${user}    ${i+1}
        Verify If Customer Exist In The Table    ${user}
        Verify Customer Updated Details    ${user}    ${i+1}
    END

#===============================================================================

Get Customer Rows
    [Arguments]    ${user}
    Navigate    Customers
    ${web_elems}    Get WebElements    //tbody//tr

    FOR    ${i}    ${elem}    IN ENUMERATE    @{web_elems}
        ${row_index}    Set Variable    ${i+1}
        ${name}    Get Clean Customer Name    ${row_index}
        Return From Keyword If    "${user['first_name']} ${user['last_name']}"    ${i+1}
    END

Verify If Customer Exist In The Table
    [Arguments]    ${user}
    ${user_row}    Get Customer Rows    ${user}
    Should Not Be Equal As Strings    None    ${user_row}

Verify Customer Identity Details
    [Arguments]    ${user}
    ${user_row}    Get Customer Rows    ${user}

    Wait Until Element Is Visible    ((//tbody//tr)[${user_row}]//td)[2]
    Click Element    ((//tbody//tr)[${user_row}]//td)[2]

    Wait Until Element Is Visible    ${customers_txt_first_name}

    Validate Customer Form Values    ${user}

Verify Customer Updated Details
    [Arguments]    ${user}    ${i}

    Wait Until Element Is Visible    ((//tbody//tr)[${i}]//td)[2]
    Click Element    ((//tbody//tr)[${i}]//td)[2]

    Wait Until Element Is Visible    ${customers_txt_first_name}

    Validate Customer Form Values    ${user}

#===============================================================================

Log Customer Table Data
    Navigate    Customers
    ${web_elems}    Get WebElements    //tbody//tr

    FOR    ${i}    ${elem}    IN ENUMERATE    @{web_elems}
        ${row_index}    Set Variable    ${i+1}

        ${name}    Get Clean Customer Name    ${row_index}
        ${order}    Get Table Cell Text    ${row_index}    4
        ${total_spent}    Get Table Cell Text    ${row_index}    5
        ${latest_purchase}    Get Table Cell Text    ${row_index}    6

        ${news}    Get Customer News    ${row_index}
        ${segments}    Get Customer Segments    ${row_index}

        Log To Console    \n====== User ${row_index} =====\nName: ${name}\nOrders: ${order}\nTotal Spent: ${total_spent}\nLatest Purchase: ${latest_purchase}\nNews: ${news}\nSegments: ${segments}

    END

Validate Total Customer Spending
    Navigate    Customers
    ${web_elems}    Get WebElements    //tbody//tr

    ${count}    Set Variable    ${0}
    ${total}    Set Variable    ${0}

    Log To Console    \n

    FOR    ${i}    ${elem}    IN ENUMERATE    @{web_elems}
        ${row_index}    Set Variable    ${i+1}

        ${name}    Get Clean Customer Name    ${row_index}

        ${total_spent}    Get Table Cell Text    ${row_index}    5
        ${total_spent}    Parse Currency To Float    ${total_spent}

        IF    ${total_spent} > 0
            ${count}    Set Variable    ${count+1}

            Log To Console    ${count}. ${name}: ${total_spent}

            ${total}    Evaluate    ${total} + ${total_spent}
        END
    END

    ${formatted_total}    Format Figure    ${total}

    Log To Console    =========================\nTotal Customer Spending: $${formatted_total}\n=========================

    IF    ${total} < 3500
        Fail    FAIL: Total spending ($${formatted_total}) is below minimum threshold ($3,500)
    ELSE
        Pass Execution    PASS: Total spending ($${formatted_total}) meets minimum threshold ($3,500)
    END

#===============================================================================

Format Birthday
    [Arguments]    ${date}
    ${formatted}    Evaluate    "/".join("${date}".split("-")[::-1])
    RETURN    ${formatted}

Format Figure
    [Arguments]    ${total}
    ${formatted_total}    Evaluate    "{:,.2f}".format(${total})
    RETURN    ${formatted_total}
