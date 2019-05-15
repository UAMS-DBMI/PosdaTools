import { DicomPage } from './app.po';

describe('dicom App', () => {
  let page: DicomPage;

  beforeEach(() => {
    page = new DicomPage();
  });

  it('should display message saying app works', () => {
    page.navigateTo();
    expect(page.getParagraphText()).toEqual('app works!');
  });
});
