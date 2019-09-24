import time
from selenium.webdriver.support.ui import Select

@given(u'Test data was imported')
def step_impl(context):
    #do later
    pass

@given(u'an activity exists')
def step_impl(context):
    #do later
    pass

@given(u'Your browser is allowing popups')
def step_impl(context):
    #do later
    pass

@when(u'we open dbif')
def step_impl(context):

    #Open browser and get past landing page 1
    context.browser.get("http://localhost")
    context.browser.find_element_by_link_text("Posda Login").click()

    #login to real posda landing page
    username = context.browser.find_element_by_id("UserName")
    password = context.browser.find_element_by_id("UserEnteredPassword")
    username.send_keys("admin")
    password.send_keys("admin")
    submit = context.browser.find_element_by_id("LoginSubmit")
    submit.click()

    #Open DBIF
    show_apps = context.browser.find_element_by_link_text("Show Apps")
    dbif_row = context.browser.find_element_by_xpath("//tr/td[text()='DbIf']/..")
    launcher = dbif_row.find_element_by_xpath(".//td/input")
    launcher.click()

    #switch to popup
    time.sleep(3)
    context.browser.switch_to.window(context.browser.window_handles[1])
    assert "Loading" in context.browser.find_element_by_xpath("//h1").text
    time.sleep(10)
    assert "Database" in context.browser.title

@when(u'we click activity')
def step_impl(context):
    activity = context.browser.find_element_by_link_text("Activity")
    activity.click()
    time.sleep(2)


@when(u'we count the existing activities')
def step_impl(context):
    #currently returns 2 extra
    context.activity_count = len(context.browser.find_elements_by_xpath("//h2[text()='Activities']/../div/select/option"))-2

@when(u'we create an activity')
def step_impl(context):
    desc_entry = context.browser.find_element_by_id("newActivity")
    desc_entry.send_keys("Test Curation")
    savebutton = context.browser.find_element_by_xpath("//input[@value='Save']")
    savebutton.click()

@then(u'one new activity should exist in dropdown')
def step_impl(context):
    new_activity_count = len(context.browser.find_elements_by_xpath("//h2[text()='Activities']/../div/select/option"))
    assert new_activity_count == (context.activity_count + 1)

@when(u'we select an activity')
def step_impl(context):
    #activity = context.browser.find_elements_by_xpath("//h2[text()='Activities']/../div/select/option")[1]
    selector = Select(context.browser.find_element_by_id("ActivityDropDown"))
    selector.select_by_value("" + str(context.activity_count) + "")
    time.sleep(2)



@when(u'we select ActivityOperations')
def step_impl(context):
    selector = Select(context.browser.find_element_by_id("SetActivityMode"))
    selector.select_by_value("2")
    time.sleep(2)

@when(u'we click Create Activity Timepoint from Import Name')
def step_impl(context):
    timepointbutton = context.browser.find_element_by_xpath("//input[@value='Create Activity Timepoint from Import Name']")
    timepointbutton.click()
    time.sleep(3)
    context.browser.switch_to.window(context.browser.window_handles[2])


@when(u'we input the required parameters, Expand, and Start Subprocess')
def step_impl(context):
    import_name_input = context.browser.find_element_by_id("import_nameEntryBox")
    import_name_input.send_keys("Test Curation Import")
    comment_input = context.browser.find_element_by_id("commentEntryBox")
    comment_input.send_keys("Functional Testing")
    expandbutton = context.browser.find_element_by_xpath("//input[@value='Expand']")
    expandbutton.click()
    time.sleep(1)
    startbutton = context.browser.find_element_by_xpath("//input[@value='Start Subprocess']")
    startbutton.click()
    time.sleep(5)
    #close_button_row = context.browser.find_element_by_xpath("//tr/td[text()='Signed in as']/..")
    #closebutton = close_button_row.find_element_by_xpath(".//div/button")
    #closebutton.click()

@then(u'we recieve an inbox notice of success')
def step_impl(context):
    context.browser.switch_to.window(context.browser.window_handles[1])
    time.sleep(10)
    inbox = context.browser.find_element_by_link_text("Inbox")
    inbox.click()
    time.sleep(2)

@when(u'we select Queries')
def step_impl(context):
    selector = Select(context.browser.find_element_by_id("SetActivityMode"))
    selector.select_by_value("3")
    time.sleep(2)

@when(u'we click Search radiobutton')
def step_impl(context):
    searchradio = context.browser.find_element_by_xpath("//input[@type='radio'][@value='search']")
    searchradio.click()

@when(u'We add parameter SeriesByMatchingImportEventsWithEventInfo')
def step_impl(context):
    nameparam = context.browser.find_element_by_xpath("//input[@name='NewNameMatchList']")
    nameparam.send_keys("SeriesByMatchingImportEventsWithEventInfo")

@when(u'we click Search button')
def step_impl(context):
    searchbutton = context.browser.find_element_by_xpath("//input[@type='button'][@value='search']")
    searchbutton.click()

@when(u'we click foreground')
def step_impl(context):
    button = context.browser.find_element_by_xpath("//input[@type='button'][@value='foreground']")
    button.click()

@when(u'we add SeriesByMatchingImportEventsWithEventInfo parameters')
def step_impl(context):
    param1 = context.browser.find_element_by_xpath("//th[text()='import_comment_like']/../td/input")
    if param1.get_attribute("value") != '%':
        param1.send_keys("%")
    param2 = context.browser.find_element_by_xpath("//th[text()='import_type_like']/../td/input")
    if param2.get_attribute("value") != '%':
        param2.send_keys("%")

@when(u'we click Query')
def step_impl(context):
    button = context.browser.find_element_by_xpath("//input[@type='button'][@value='query']")
    button.click()

@when(u'we Click CreateActivityTimepointFromSeriesList')
def step_impl(context):
    button = context.browser.find_element_by_xpath("//input[@type='button'][@value='CreateActivityTimepointFromSeriesList']")
    button.click()
    time.sleep(3)
    context.browser.switch_to.window(context.browser.window_handles[2])

@when(u'we input the parameters including the ID of your Activity')
def step_impl(context):
    param1 = context.browser.find_element_by_id("activity_idEntryBox")
    param1.send_keys(context.activity_count)
    param2 = context.browser.find_element_by_id("commentEntryBox")
    param2.send_keys("feature testing")


@when(u'we Click Expand')
def step_impl(context):
    button = context.browser.find_element_by_xpath("//input[@type='button'][@value='Expand']")
    button.click()
    time.sleep(2)

@when(u'we Click Start Subprocess')
def step_impl(context):
    button = context.browser.find_element_by_xpath("//input[@type='button'][@value='Start Subprocess']")
    button.click()
    time.sleep(2)

@when(u'we close popup and switch windows')
def step_impl(context):
    button = context.browser.find_element_by_xpath("//button[@type='button']")
    button.click()
    context.browser.switch_to.window(context.browser.window_handles[1])
    time.sleep(5)

@when(u'we file the inbox message')
def step_impl(context):
    inbox = context.browser.find_element_by_partial_link_text("Inbox")
    inbox.click()
    time.sleep(2)
    button = context.browser.find_element_by_xpath("//input[@type='button']") # top button
    button.click()
    fbutton = context.browser.find_element_by_xpath("//button[normalize-space(.)='File this message']")
    fbutton.click()
    ybutton =  context.browser.find_element_by_xpath("//button[normalize-space(.)='Yes']")
    ybutton.click()
    time.sleep(2)


@when(u'we select Timeline')
def step_impl(context):
    selector = Select(context.browser.find_element_by_id("SetActivityMode"))
    selector.select_by_value("0")
    time.sleep(2)


@then(u'we see a timeline message with correct file count')
def step_impl(context):
    time.sleep(5)
    assert context.browser.find_element_by_xpath('//tr/td[text()="CreateActivityTimepointFromSeriesList"]/../td[text()="628"]')
