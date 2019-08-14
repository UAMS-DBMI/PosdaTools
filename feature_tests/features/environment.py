from behave import fixture, use_fixture
from selenium import webdriver

@fixture
def selenium_browser_firefox(context):
    context.browser = webdriver.Firefox()
    context.browser.implicitly_wait(5) # seconds
    yield context.browser
    context.browser.quit()

def before_all(context):
    use_fixture(selenium_browser_firefox, context)
