import SwiftUI
import SwiftData

@main
struct MedoraApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: Prescription.self, Medicine.self, VerificationResult.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        MedicineSeeder.seedIfNeeded(context: container.mainContext)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}



