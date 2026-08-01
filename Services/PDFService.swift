import PDFKit
import UIKit

final class PDFService {
    func extractText(from url: URL) -> String {
        guard let pdf = PDFDocument(url: url) else { return "" }
        var text = ""
        for i in 0..<pdf.pageCount {
            if let page = pdf.page(at: i), let pageText = page.string {
                text += pageText + "\n"
            }
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func extractImagesAndRecognize(from url: URL) async throws -> String {
        guard let pdf = PDFDocument(url: url) else { throw OCRError.invalidPDF }
        let ocr = OCRService()
        var allText = ""
        
        for i in 0..<pdf.pageCount {
            if let page = pdf.page(at: i) {
                let pageText = page.string ?? ""
                if !pageText.trimmingCharacters(in: .whitespaces).isEmpty {
                    allText += pageText + "\n"
                } else if let image = renderPage(page) {
                    if let ocrText = try? await ocr.recognizeText(from: image) {
                        allText += ocrText + "\n"
                    }
                }
            }
        }
        return allText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func renderPage(_ page: PDFPage) -> UIImage? {
        let bounds = page.bounds(for: .mediaBox)
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        return renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(bounds)
            ctx.cgContext.translateBy(x: 0, y: bounds.height)
            ctx.cgContext.scaleBy(x: 1, y: -1)
            page.draw(with: .mediaBox, to: ctx.cgContext)
        }
    }
    
    enum OCRError: LocalizedError {
        case invalidPDF
        var errorDescription: String? { "Could not read PDF file" }
    }
}
