import { browser, logging, element, by } from 'protractor';

describe('Sakura App', () => {

  it('should display as posda', () => {
    browser.get(browser.baseUrl);
    expect(browser.getTitle()).toEqual('Posda');
  });

  it('should allow admin to login', () => {
    debugger;
    browser.get(browser.baseUrl);
    element(by.id('username')).sendKeys('admin');
    element(by.id('password')).sendKeys('admin');
    element(by.id('login')).click();

    expect(element(by.css('h2')).getText()).
      toEqual('admin');
  });

  afterEach(async () => {
    // Assert that there are no errors emitted from the browser
    const logs = await browser.manage().logs().get(logging.Type.BROWSER);
    expect(logs).not.toContain(jasmine.objectContaining({
      level: logging.Level.SEVERE,
    } as logging.Entry));
  });
});
