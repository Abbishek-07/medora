
import Foundation
import SwiftData

@MainActor
@Observable
final class DashboardViewModel {
    var prescriptions: [Prescription] = []
    var results: [VerificationResult] = []
    var isLoading = false
    var errorMessage: String?

    var total: Int { prescriptions.count }
    var pending: Int { prescriptions.filter { $0.status == .pending }.count }
    var verified: Int { prescriptions.filter { $0.status == .verified }.count }
    var flagged: Int { prescriptions.filter { $0.status == .flagged }.count }

    var recent: [Prescription] {
        Array(prescriptions.sorted { $0.date > $1.date }.prefix(5))
    }

    func load(context: ModelContext) {
        isLoading = true; defer { isLoading = false }
        do {
            prescriptions = try context.fetch(FetchDescriptor<Prescription>(sortBy: [SortDescriptor(\.date, order: .reverse)]))
            results = try context.fetch(FetchDescriptor<VerificationResult>(sortBy: [SortDescriptor(\.verifiedAt, order: .reverse)]))
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
