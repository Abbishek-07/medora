//
//  NewPrescriptionView.swift
//  Medora
//
//  Same NewPrescriptionViewModel, camera/photo/PDF import, OCR flow and
//  save logic as before — only the visual layer changed to match the
//  white + pink theme, with the scan/upload section pinned to the top.
//

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
                scanSection

                if vm.isProcessing {
                    HStack(spacing: 8) {
                        ProgressView().tint(.medoraPinkDeep)
                        Text("Reading prescription...")
                            .font(.caption)
                            .foregroundStyle(Color.medoraGraySubtle)
                    }
                }

                if let e = vm.ocrError {
                    Label(e, systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.medoraFlagged)
                }

                if !vm.scannedText.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Extracted Text")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.medoraGraySubtle)
                        Text(vm.scannedText)
                            .font(.caption)
                            .italic()
                            .foregroundStyle(Color.medoraInk)
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12).fill(Color.medoraPinkSoft.opacity(0.5))
                            )
                    }
                }

                HStack {
                    Rectangle().fill(Color.medoraPinkSoft).frame(height: 1)
                    Text("or enter manually")
                        .font(.caption)
                        .foregroundStyle(Color.medoraGraySubtle)
                        .fixedSize()
                    Rectangle().fill(Color.medoraPinkSoft).frame(height: 1)
                }

                manualEntrySection

                if let e = vm.saveError {
                    Label(e, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(Color.medoraFlagged)
                        .font(.caption)
                }

                Button {
                    vm.save(context: context)
                } label: {
                    if vm.isSaving {
                        HStack(spacing: 8) {
                            ProgressView().tint(.white)
                            Text("Saving...")
                        }
                        .medoraPrimaryButton()
                    } else {
                        Label("Save Prescription", systemImage: "checkmark.shield.fill")
                            .medoraPrimaryButton()
                    }
                }
                .disabled(!vm.isValid || vm.isSaving)
                .opacity((vm.isValid && !vm.isSaving) ? 1 : 0.5)
            }
            .padding()
        }
        .background(LinearGradient.medoraBackground.ignoresSafeArea())
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

    // MARK: - Scan / upload section (kept at the top, as requested)

    private var scanSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.medoraPinkSoft)
                    .frame(width: 64, height: 64)
                Image(systemName: "doc.viewfinder")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color.medoraPinkDeep)
            }

            VStack(spacing: 4) {
                Text("Scan Prescription")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.medoraInk)
                Text("Use camera or upload a PDF/image")
                    .font(.caption)
                    .foregroundStyle(Color.medoraGraySubtle)
            }

            HStack(spacing: 12) {
                Button { showCamera = true } label: {
                    Label("Camera", systemImage: "camera.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.medoraPinkDeep)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.medoraPink, lineWidth: 1.5)
                        )
                }

                Menu {
                    Button { showPicker = true } label: { Label("Photo Library", systemImage: "photo.on.rectangle") }
                    Button { showFile = true } label: { Label("PDF File", systemImage: "doc.badge.plus") }
                } label: {
                    Label("Upload", systemImage: "square.and.arrow.up")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14).fill(LinearGradient.medoraPinkButton)
                        )
                }
            }
        }
        .medoraCard()
    }

    // MARK: - Manual entry fields

    private var manualEntrySection: some View {
        VStack(spacing: 14) {
            MedoraTextField(placeholder: "Patient Name *", text: $vm.patientName, icon: "person.fill")
                .textContentType(.name)
            MedoraTextField(placeholder: "Medicine Name *", text: $vm.medicineName, icon: "pills.fill")
            MedoraTextField(placeholder: "Diagnosis / Condition", text: $vm.diagnosis, icon: "stethoscope")

            HStack(spacing: 12) {
                MedoraTextField(placeholder: "Dosage", text: $vm.dosage, icon: "cross.vial.fill")
                MedoraTextField(placeholder: "Frequency", text: $vm.frequency, icon: "clock.fill")
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Age Group")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.medoraGraySubtle)
                Picker("Age Group", selection: $vm.ageGroup) {
                    ForEach(AgeGroup.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .tint(.medoraPinkDeep)
            }

            VStack(alignment: .leading, spacing: 8) {
                DatePicker("Prescription Date", selection: $vm.date, displayedComponents: .date)
                    .tint(.medoraPinkDeep)
                    .font(.subheadline)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))

            VStack(alignment: .leading, spacing: 8) {
                Text("Notes")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.medoraGraySubtle)
                TextField("Add any additional notes", text: $vm.notes, axis: .vertical)
                    .lineLimit(3...6)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
            }
        }
    }
}

// MARK: - Reusable pink-themed text field

private struct MedoraTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(Color.medoraPinkDeep)
                .frame(width: 18)
            TextField(placeholder, text: $text)
                .font(.subheadline)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
    }
}
