import SwiftUI
import SwiftData
import PhotosUI
import UniformTypeIdentifiers

struct NewPrescriptionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var vm = NewPrescriptionViewModel()
    @State private var showCamera = false
    @State private var showPicker = false
    @State private var showFile = false
    @State private var photoItem: PhotosPickerItem?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Image(systemName: "doc.viewfinder").font(.system(size: 40)).foregroundStyle(.teal)
                    Text("Scan Prescription").font(.headline)
                    Text("Use camera or upload a PDF/image").font(.caption).foregroundStyle(.secondary)
                    HStack(spacing: 12) {
                        Button { showCamera = true } label: {
                            Label("Camera", systemImage: "camera").frame(maxWidth: .infinity)
                        }.buttonStyle(.bordered)
                        Menu {
                            Button { showPicker = true } label: { Label("Photo Library", systemImage: "photo.on.rectangle") }
                            Button { showFile = true } label: { Label("PDF File", systemImage: "doc.badge.plus") }
                        } label: { Label("Upload", systemImage: "square.and.arrow.up") }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding().background(.regularMaterial).clipShape(.rect(cornerRadius: 16))

                if vm.isProcessing { HStack { ProgressView(); Text("Reading prescription...").font(.caption) } }
                if let e = vm.ocrError { Label(e, systemImage: "exclamationmark.triangle").font(.caption).foregroundStyle(.red) }
                if !vm.scannedText.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Extracted Text").font(.caption).foregroundStyle(.secondary)
                        Text(vm.scannedText).font(.caption).italic().padding(8).background(.quaternary).clipShape(.rect(cornerRadius: 8))
                    }
                }

                Divider(); Text("or enter manually").font(.caption).foregroundStyle(.secondary)

                Group {
                    TextField("Patient Name *", text: $vm.patientName).textContentType(.name).textFieldStyle(.roundedBorder)
                    TextField("Medicine Name *", text: $vm.medicineName).textFieldStyle(.roundedBorder)
                    HStack {
                        TextField("Dosage", text: $vm.dosage); TextField("Frequency", text: $vm.frequency)
                    }.textFieldStyle(.roundedBorder)
                    Picker("Age Group", selection: $vm.ageGroup) {
                        ForEach(AgeGroup.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }.pickerStyle(.segmented)
                    DatePicker("Prescription Date", selection: $vm.date, displayedComponents: .date)
                    TextField("Notes", text: $vm.notes, axis: .vertical).textFieldStyle(.roundedBorder).lineLimit(3...6)
                }

                if let e = vm.saveError { Label(e, systemImage: "exclamationmark.triangle").foregroundStyle(.red).font(.caption) }

                Button {
                    vm.save(context: context)
                } label: {
                    if vm.isSaving { HStack { ProgressView(); Text("Saving...") } }
                    else { Label("Save Prescription", systemImage: "checkmark.shield") }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!vm.isValid || vm.isSaving)
                .frame(maxWidth: .infinity)
            }.padding()
        }
        .navigationTitle("New Prescription")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showCamera) { CameraView(image: $vm.scannedImage) }
        .photosPicker(isPresented: $showPicker, selection: $photoItem, matching: .images)
        .fileImporter(isPresented: $showFile, allowedContentTypes: [.pdf]) {
            if case .success(let url) = $0 { Task { await vm.processPDF(url: url) } }
        }
        .onChange(of: vm.scannedImage) { _, img in if img != nil { Task { await vm.processImage() } } }
        .onChange(of: photoItem) { _, item in
            guard let item else { return }
            item.loadTransferable(type: Data.self) {
                if case .success(let data) = $0, let data, let img = UIImage(data: data) {
                    vm.scannedImage = img
                }
            }
        }
        .onChange(of: vm.didSave) { _, s in if s { dismiss() } }
    }
}
