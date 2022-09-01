*** Settings ***
Documentation       Order robots from soter \n
...                 Save the orders in Pdf with a screenshot \n
...                 Create Zip file \n
...                 Remove all recipts

Resource    ./Resources/settings.robot

Task Teardown    Close and Clean


*** Variables ***
${out_dir}           ${CURDIR}${/}output
${screensDirectory}    ${out_dir}${/}screenshots
${reciptsDirectory}       ${out_dir}${/}receipts  
${csvPath}    ${CURDIR}${/}orders.csv

*** Tasks ***
Order robots from the store
    Open the store page
    Click on the popUp window
    ${ordersURL}    Get the URL of the orders from user
    ${csvFile}    Retrive data from the orders url    ${ordersURL} 
    FOR    ${row}    IN    @{csvFile}
        Fill the form for each row of data    ${row}
        Preview the robot and wait to have the photo
        ${screenshotPath}    Take screenshot of the robot image    ${row}[Order number]
        Wait Until Keyword Succeeds    5x    0.5 sec    Submit order
        Create a PDF file for each order with robot image    ${row}[Order number]    ${screenshotPath}
        Order New robot
    END 
    Create a zip file from receipts


*** Keywords ***
Open the store page
    ${secret}    Get Secret    urls
    Open Available Browser    ${secret}[Base_URL]    maximized=True
    

Click on the popUp window
    Wait Until Page Contains Element    xpath://p[contains(text(),'By using this order form, I give up all my constit')]
    Click Button    xpath://button[normalize-space()='OK']

Get the URL of the orders from user
    Add heading        CSV file address
    Add text           Provide the link to the CSV file
    Add text input     url
    ${input} =         Run dialog
    [Return]           ${input}[url]    


Retrive data from the orders url
    [Arguments]    ${ordersURL}
    Download    ${ordersURL}    overwrite=True
    ${csvFile}    Read table from CSV    ${csvPath}
    [Return]    ${csvFile}

Fill the form for each row of data
    [Arguments]    ${row}
    Select From List By Value    id:head    ${row}[Head]
    Click Element    xpath://input[@id='id-body-${row}[Body]']
    Input Text    
    ...    xpath://input[@placeholder='Enter the part number for the legs']    ${row}[Legs]
    Input Text    xpath://input[@id='address']    ${row}[Address]

Preview the robot and wait to have the photo
    Click Button    xpath://button[@id='preview']
    Wait Until Page Contains Element    xpath://div[@id='robot-preview-image']

Take screenshot of the robot image
    [Arguments]    ${orderNumber}
    ${screenshotPath}    Set Variable    ${screensDirectory}${/}robot${orderNumber}.png
    RPA.Browser.Selenium.Screenshot    id:robot-preview-image    ${screenshotPath}
    #RPA.Wind.Take Screenshot    ${screenshotPath}    id:robot-preview-image
    #Take Screenshot    ${screenshotPath}    id:robot-preview-image    fullpage=False
    #Capture Element Screenshot    xpath://div[@id='robot-preview-image']    ${screenshotPath}
    [Return]    ${screenshotPath}


Submit order
    Click Button    xpath://button[@id='order']
    Wait Until Element Is Visible    xpath://div[@id="receipt"]
    Wait Until Element Is Visible    xpath://button[@id='order-another']


Create a PDF file for each order with robot image
    [Arguments]    ${orderNumber}    ${screenshots}
    ${reciept}    Get Element Attribute    xpath://div[@id="receipt"]    outerHTML
    ${pdfPath}    Set Variable    ${reciptsDirectory}${/}file${orderNumber}.pdf
    Html To Pdf    ${reciept}    ${pdfPath}
    ${images}    Create List    ${screenshots}:align=center
    RPA.PDF.Add Files To Pdf    ${images}    ${pdfPath}    append=True

Order New robot
    Wait Until Element Is Visible    xpath://button[@id='order-another']
    Click Button    xpath://button[@id='order-another']
    Click on the popUp window


Create a zip file from receipts
    ${zip_file_name} =    Set Variable    ${out_dir}${/}allReceipts.zip
    Archive Folder With Zip    ${reciptsDirectory}    ${zip_file_name}

Close and Clean
    Sleep    1s
    Close Window
    Remove Directory    ${screensDirectory}    recursive=True
    Remove Directory    ${reciptsDirectory}    recursive=True