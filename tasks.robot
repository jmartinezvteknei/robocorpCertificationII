*** Settings ***
Documentation       Robot created for get RPA certification of 
...                 Robocorp level II.
Library    RPA.Browser.Selenium
Library    OperatingSystem
Library    RPA.Tables
Library    RPA.PDF
Library    RPA.Archive

*** Variables ***
${DOWNLOAD_DIRECTORY}=  ${OUTPUT_DIR}/Orders
${ORDERS_FILENAME}=     orders.csv
${URL_DOWNLOAD_CSV}=    https://robotsparebinindustries.com/orders.csv

*** Keywords ***
Get orders 
    # Create directory if not exists
    Create Directory  ${DOWNLOAD_DIRECTORY}

    # Remove previous files.
    Empty Directory  ${DOWNLOAD_DIRECTORY}

    # Download orders.csv
    Set Download Directory  ${DOWNLOAD_DIRECTORY}
    Open Chrome Browser     ${URL_DOWNLOAD_CSV}
    Wait Until Created      ${DOWNLOAD_DIRECTORY}/${ORDERS_FILENAME}

    # Read CSV
    ${ordersTable}  Read table from CSV  ${DOWNLOAD_DIRECTORY}/${ORDERS_FILENAME}

    [Return]  ${ordersTable}

Open Sparebin web
    Go To    https://robotsparebinindustries.com/#/robot-order
    Click Element When Visible    //button[.="I guess so..."]

Save order
    [Arguments]  ${orderNumber}

    Click Button    id:order
    # Register order in PDF document.
    Register order in PDF file  ${orderNumber}

    # Close modal window.
    Click Element When Visible    id:order-another
    Click Element When Visible    //button[.="I guess so..."]

Register order in PDF file
    [Arguments]  ${orderNumber}    

    Wait Until Element Is Visible    id:order-completion
    Screenshot  id:order-completion  ${DOWNLOAD_DIRECTORY}/order_${orderNumber}.png
    Html To Pdf    Order Number: ${orderNumber}\n\n    ${DOWNLOAD_DIRECTORY}/order_${orderNumber}.pdf
    @{fileInAList}=  Create List  ${DOWNLOAD_DIRECTORY}/order_${orderNumber}.png
    Add Files To Pdf  ${fileInAList}  ${DOWNLOAD_DIRECTORY}/order_${orderNumber}.pdf  True
    Remove File    ${DOWNLOAD_DIRECTORY}/order_${orderNumber}.png

Set orders
    [Arguments]  ${orders}

    FOR  ${order}  IN  @{orders}
        Select From List By Value  id:head  ${order}[Head]
        Click Element    id:id-body-${order}[Body]
        Input Text    //input[@class="form-control" and @type="number"]    ${order}[Legs]
        Input Text    id:address    ${order}[Address]

        Wait Until Keyword Succeeds    5x    1    Save order  ${order}[Order number]

    END

    # Creating zip file with all pdf documents.
    Archive Folder With Zip    ${DOWNLOAD_DIRECTORY}    ${OUTPUT_DIR}/orders.zip   include=*.pdf  

*** Tasks ***
Vamos pallá 
    ${orders}  Get orders
    Open Sparebin web
    Set orders  ${orders}
    
