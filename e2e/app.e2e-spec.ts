import { KaleidoscopePage } from './app.po';

describe('kaleidoscope App', function() {
  let page: KaleidoscopePage;

  beforeEach(() => {
    page = new KaleidoscopePage();
  });

  it('should display message saying app works', () => {
    page.navigateTo();
    expect(page.getParagraphText()).toEqual('app works!');
  });
});
