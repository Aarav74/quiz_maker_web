const { PDFDocument } = require('pdf-lib');
const fs = require('fs').promises;

exports.extractText = async (filePath) => {
  try {
    // For PDF files
    if (filePath.endsWith('.pdf')) {
      const pdfBytes = await fs.readFile(filePath);
      const pdfDoc = await PDFDocument.load(pdfBytes);
      let text = '';
      
      for (let i = 0; i < pdfDoc.getPageCount(); i++) {
        const page = pdfDoc.getPage(i);
        text += await page.getText();
      }
      return text;
    }
    // For text files
    else if (filePath.endsWith('.txt')) {
      return await fs.readFile(filePath, 'utf-8');
    }
    // Add DOCX support here if needed
    else {
      throw new Error('Unsupported file format');
    }
  } catch (error) {
    console.error('Text extraction error:', error);
    throw error;
  }
};