import time
from selenium.webdriver.support.ui import Select

@given(u'RSNA data was imported under the name "RSNA"')
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
    assert "Activities" in context.browser.find_element_by_xpath("//h2").text

@when(u'we count the existing activities')
def step_impl(context):
    #currently returns 2 extra
    context.activity_count = len(context.browser.find_elements_by_xpath("//h2[text()='Activities']/../div/select/option"))-2

@when(u'we create an activity')
def step_impl(context):
    desc_entry = context.browser.find_element_by_id("newActivity")
    desc_entry.send_keys("RSNA Activity")
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
    import_name_input.send_keys("RSNA")
    comment_input = context.browser.find_element_by_id("commentEntryBox")
    comment_input.send_keys("Functional Testing")
    expandbutton = context.browser.find_element_by_xpath("//input[@value='Expand']")
    expandbutton.click()
    time.sleep(1)
    startbutton = context.browser.find_element_by_xpath("//input[@value='Start Subprocess']")
    startbutton.click()
    time.sleep(5)
    close_button_row = context.browser.find_element_by_xpath("//tr/td[text()='Signed in as']/..")
    closebutton = close_button_row.find_element_by_xpath(".//div/button")
    closebutton.click()

@then(u'we recieve an inbox notice of success')
def step_impl(context):
    context.browser.switch_to.window(context.browser.window_handles[1])
    time.sleep(10)
    inbox = context.browser.find_element_by_link_text("Inbox")
    inbox.click()
    time.sleep(2)
