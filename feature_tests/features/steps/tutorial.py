from behave import *

@given(u'posda is running')
def step_impl(context):
    pass

@when(u'we open posda')
def step_impl(context):
    context.browser.get("http://localhost")

@when(u'we click "Posda Login"')
def step_impl(context):
    context.browser.find_element_by_link_text("Posda Login").click()

@when(u'we log in')
def step_impl(context):
    username = context.browser.find_element_by_id("UserName")
    password = context.browser.find_element_by_id("UserEnteredPassword")
    username.send_keys("admin")
    password.send_keys("admin")
    submit = context.browser.find_element_by_id("LoginSubmit")
    submit.click()

@then(u'we should see POSDA')
def step_impl(context):
    assert "POSDA" in context.browser.title

@then(u'we should see DbIf')
def step_impl(context):
    show_apps = context.browser.find_element_by_link_text("Show Apps")
    dbif_row = context.browser.find_element_by_xpath("//tr/td[text()='DbIf']/..")
    assert dbif_row is not None
