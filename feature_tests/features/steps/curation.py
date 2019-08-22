import time

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
    #currently returns extra, but is still useable as a measure of if the number has increased
    context.activity_count = len(context.browser.find_elements_by_xpath("//h2[text()='Activities']/../div/select/option"))

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
