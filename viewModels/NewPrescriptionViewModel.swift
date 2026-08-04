import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
final class NewPrescriptionViewModel {
    var patientName = ""
    var medicineName = ""
    var dosage = ""
    var frequency = ""
    var ageGroup: AgeGroup = .adult
    var notes = ""
    var diagnosis = ""
    var date = Date()

    var scannedImage: UIImage?
    var scannedText = ""
    var isProcessing = false
    var ocrError: String?
    var isSaving = false
    var saveError: String?
    var didSave = false

    var isValid: Bool {
        !patientName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !medicineName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func reset() {
        patientName = ""; medicineName = ""; dosage = ""; frequency = ""
        ageGroup = .adult; notes = ""; diagnosis = ""; date = .now
        scannedImage = nil; scannedText = ""; ocrError = nil
        isSaving = false; saveError = nil; didSave = false
    }

    func processImage() async {
        guard let img = scannedImage else { return }
        isProcessing = true; ocrError = nil
        do {
            scannedText = try await OCRService().recognizeText(from: img)
            parse(scannedText)
        } catch { ocrError = error.localizedDescription }
        isProcessing = false
    }

    func processPDF(url: URL) async {
        isProcessing = true; ocrError = nil
        do {
            scannedText = try await PDFService().extractImagesAndRecognize(from: url)
            parse(scannedText)
        } catch { ocrError = error.localizedDescription }
        isProcessing = false
    }

    private func parse(_ text: String) {
        for line in text.components(separatedBy: .newlines) {
            let lower = line.lowercased()
            if lower.contains("patient") || lower.contains("name"), patientName.isEmpty {
                patientName = line.components(separatedBy: ":").last?.trimmingCharacters(in: .whitespaces) ?? ""
            }
            if lower.contains("mg") || lower.contains("mcg") || lower.contains("tablet") || lower.contains("capsule"),
               medicineName.isEmpty {
                medicineName = line.trimmingCharacters(in: .whitespaces)
            }
            if (lower.contains("take") || lower.contains("daily") || lower.contains("times")), dosage.isEmpty {
                dosage = line.trimmingCharacters(in: .whitespaces)
            }
            if lower.contains("every"), frequency.isEmpty {
                frequency = line.trimmingCharacters(in: .whitespaces)
            }
        }
    }

    func save(context: ModelContext) {
        guard isValid else { saveError = "Patient name and medicine name are required."; return }
        isSaving = true; saveError = nil
        let rx = Prescription(
            patientName: patientName.trimmingCharacters(in: .whitespaces),
            medicineName: medicineName.trimmingCharacters(in: .whitespaces),
            dosage: dosage.trimmingCharacters(in: .whitespaces),
            frequency: frequency.trimmingCharacters(in: .whitespaces),
            ageGroup: ageGroup, date: date,
            notes: notes.trimmingCharacters(in: .whitespaces),
            diagnosis: diagnosis.trimmingCharacters(in: .whitespaces)
        )
        context.insert(rx)
        do {
            try context.save()
            didSave = true
            let ai = AIVerificationService(context: context)
            Task { await ai.analyzePrescription(rx) }
        } catch { saveError = error.localizedDescription }
        isSaving = false
    }
}
