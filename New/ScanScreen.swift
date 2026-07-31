import SwiftUI

// MARK: - Models

struct ExtractedMed: Identifiable {
    let id = UUID()
    let name: String
    let dose: String
    let freq: String
    let raw: String
}

struct VerificationResult: Identifiable {
    let id = UUID()
    let type: String
    let severity: Severity
    let title: String
    let detail: String
    let drugs: [String]
    let alternatives: [String]

    enum Severity: String {
        case high
        case medium
        case low
    }
}

let EXTRACTED_MEDS: [ExtractedMed] = [
    ExtractedMed(name: "Warfarin", dose: "5mg", freq: "Once daily", raw: "Warfarin 5mg OD"),
    ExtractedMed(name: "Ibuprofen", dose: "400mg", freq: "Three times daily", raw: "Ibuprofen 400mg TDS"),
    ExtractedMed(name: "Omeprazole", dose: "20mg", freq: "Before meals", raw: "Omeprazole 20mg AC"),
]

let VERIFICATION_RESULTS: [VerificationResult] = [
    VerificationResult(
        type: "interaction",
        severity: .high,
        title: "Critical Drug Interaction",
        detail: "Warfarin + Ibuprofen: NSAIDs inhibit platelet function and displace warfarin from protein binding, significantly increasing bleeding risk.",
        drugs: ["Warfarin 5mg", "Ibuprofen 400mg"],
        alternatives: ["Paracetamol 500mg", "Acetaminophen 500mg"]
    ),
    VerificationResult(
        type: "duplicate",
        severity: .medium,
        title: "Possible Duplicate",
        detail: "Omeprazole 20mg is already present in your active prescription list from Dr. Chen dated 15 Jul 2026.",
        drugs: ["Omeprazole 20mg"],
        alternatives: []
    ),
    VerificationResult(
        type: "dosage",
        severity: .low,
        title: "Dosage Within Range",
        detail: "Warfarin 5mg is within the standard therapeutic range for your age group. Continue INR monitoring.",
        drugs: ["Warfarin 5mg"],
        alternatives: []
    ),
]

// MARK: - ScanScreen

struct ScanScreen: View {
    let scanResult: ScanResultState
    let onScanComplete: () -> Void
    let onNewScan: () -> Void

    enum Step {
        case input
        case scanning
        case extracted
        case results
    }

    enum InputMode {
        case scan
        case manual
    }

    @State private var step: Step
    @State private var inputMode: InputMode = .scan
    @State private var scanProgress: Double = 0
    @State private var manualInput = ""
    @State private var activeResult: Int? = nil

    init(scanResult: ScanResultState, onScanComplete: @escaping () -> Void, onNewScan: @escaping () -> Void) {
        self.scanResult = scanResult
        self.onScanComplete = onScanComplete
        self.onNewScan = onNewScan
        _step = State(initialValue: scanResult == .results ? .results : .input)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 2) {
                    Text("PRESCRIPTION")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(AppTheme.slate400)
                        .tracking(1)
                    Text("Verify Rx")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.slate900)
                }
                .padding(.horizontal, 24)
                .padding(.top, 56)
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)

                switch step {
                case .input:
                    inputView
                case .scanning:
                    scanningView
                case .extracted:
                    extractedView
                case .results:
                    resultsView
                }
            }
        }
        .background(AppTheme.slate50)
    }

    // MARK: - Input View

    private var inputView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Mode toggle
            HStack(spacing: 4) {
                ForEach([InputMode.scan, .manual], id: \.self) { mode in
                    Button {
                        inputMode = mode
                    } label: {
                        Text(mode == .scan ? "📷 Scan Rx" : "✏️ Manual Entry")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundColor(inputMode == mode ? AppTheme.teal700 : AppTheme.slate400)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(inputMode == mode ? Color.white : Color.clear)
                                    .shadow(color: inputMode == mode ? Color.black.opacity(0.08) : .clear, radius: 4, x: 0, y: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(4)
            .background(AppTheme.slate100)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.bottom, 20)

            if inputMode == .scan {
                scanView
            } else {
                manualView
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    private var scanView: some View {
        VStack(spacing: 0) {
            // Camera frame
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(AppTheme.slate900)
                    .frame(height: 260)

                // Grid overlay
                GridPattern()
                    .opacity(0.2)
                    .frame(height: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 24))

                // Corner brackets
                HStack {
                    VStack {
                        HStack {
                            CornerBracket(position: .topLeft)
                            Spacer()
                            CornerBracket(position: .topRight)
                        }
                        Spacer()
                        HStack {
                            CornerBracket(position: .bottomLeft)
                            Spacer()
                            CornerBracket(position: .bottomRight)
                        }
                    }
                    .padding(16)
                }
                .frame(height: 260)

                // Scan line
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, AppTheme.teal500, .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 2)
                    .shadow(color: AppTheme.teal500, radius: 6)
                    .padding(.horizontal, 24)

                // Center label
                VStack(spacing: 8) {
                    Text("📄")
                        .font(.system(size: 36))
                    Text("POINT CAMERA AT PRESCRIPTION")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(AppTheme.teal300)
                }
            }
            .frame(height: 260)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(.bottom, 16)

            // Scan button
            Button {
                startScan()
            } label: {
                Text("Scan Prescription")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.teal900, AppTheme.teal700],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(PlainButtonStyle())

            // Divider
            HStack {
                Rectangle()
                    .fill(AppTheme.slate200)
                    .frame(height: 1)
                Text("or")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(AppTheme.slate400)
                Rectangle()
                    .fill(AppTheme.slate200)
                    .frame(height: 1)
            }
            .padding(.vertical, 16)

            // Import buttons
            HStack(spacing: 12) {
                Button {
                    startScan()
                } label: {
                    Text("📁 Import PDF")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.teal700)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.teal50)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppTheme.teal100, lineWidth: 2)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                Button {
                    startScan()
                } label: {
                    Text("🖼️ Import Image")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.teal700)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.teal50)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppTheme.teal100, lineWidth: 2)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private var manualView: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("PRESCRIPTION DETAILS")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundColor(AppTheme.slate500)
                    .tracking(1)
                TextEditor(text: $manualInput)
                    .font(.system(size: 12, design: .monospaced))
                    .frame(height: 140)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppTheme.slate200, lineWidth: 1)
                    )
            }
            .padding(.bottom, 12)

            ManualField(label: "Patient Age", placeholder: "68 years")
            ManualField(label: "Prescribing Doctor", placeholder: "Dr. James Porter")
            ManualField(label: "Date Prescribed", placeholder: "28 Jul 2026")

            Button {
                startScan()
            } label: {
                Text("Verify Prescription")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.teal900, AppTheme.teal700],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 8)
        }
    }

    // MARK: - Scanning View

    private var scanningView: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(AppTheme.slate200, lineWidth: 6)
                Circle()
                    .trim(from: 0, to: CGFloat(scanProgress / 100))
                    .stroke(AppTheme.teal700, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int(scanProgress.rounded()))%")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(AppTheme.teal700)
            }
            .frame(width: 96, height: 96)
            .padding(.bottom, 32)

            Text("Analyzing Prescription")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.slate800)
                .padding(.bottom, 16)

            VStack(alignment: .leading, spacing: 8) {
                ScanStep(label: "OCR extraction", done: scanProgress > 25)
                ScanStep(label: "Medicine identification", done: scanProgress > 55)
                ScanStep(label: "Database lookup", done: scanProgress > 75)
                ScanStep(label: "Interaction check", done: scanProgress > 95)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 32)
        .frame(height: 500)
    }

    // MARK: - Extracted View

    private var extractedView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppTheme.emerald600)
                Text("3 medications extracted from prescription")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.emerald700)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.emerald50)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppTheme.emerald100, lineWidth: 1)
            )
            .padding(.bottom, 16)

            Text("EXTRACTED MEDICATIONS")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundColor(AppTheme.slate500)
                .tracking(1)
                .padding(.bottom, 12)

            VStack(spacing: 8) {
                ForEach(EXTRACTED_MEDS) { med in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 4) {
                                Text(med.name)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppTheme.slate800)
                                Text(med.dose)
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.teal600)
                            }
                            Text(med.freq)
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.slate400)
                        }
                        Spacer()
                        Text("RAW: \(med.raw)")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(AppTheme.slate400)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppTheme.slate50)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppTheme.slate100, lineWidth: 1)
                            )
                    }
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppTheme.slate100, lineWidth: 1)
                    )
                }
            }
            .padding(.bottom, 20)

            Button {
                verify()
            } label: {
                Text("Run Safety Verification")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.teal900, AppTheme.teal700],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }

    // MARK: - Results View

    private var resultsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Overall result banner
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Text("⚠️")
                        .font(.system(size: 30))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Issues Detected")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Text("1 critical · 1 moderate · 1 informational")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.rose100)
                    }
                    Spacer()
                }

                HStack(spacing: 8) {
                    ResultCountCard(count: "1", label: "Interaction")
                    ResultCountCard(count: "1", label: "Duplicate")
                    ResultCountCard(count: "1", label: "Advisory")
                }
                .padding(.top, 16)
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.745, green: 0.071, blue: 0.235), AppTheme.rose600],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(.bottom, 20)

            Text("VERIFICATION DETAILS")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundColor(AppTheme.slate500)
                .tracking(1)
                .padding(.bottom, 12)

            VStack(spacing: 12) {
                ForEach(Array(VERIFICATION_RESULTS.enumerated()), id: \.element.id) { index, res in
                    ResultCard(
                        result: res,
                        expanded: activeResult == index,
                        onToggle: {
                            activeResult = activeResult == index ? nil : index
                        }
                    )
                }
            }
            .padding(.bottom, 20)

            HStack(spacing: 12) {
                Button {
                    reset()
                } label: {
                    Text("New Scan")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.teal700)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.teal50)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppTheme.teal100, lineWidth: 2)
                        )
                }
                .buttonStyle(PlainButtonStyle())

                Button {
                    // save report
                } label: {
                    Text("Save Report")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [AppTheme.teal900, AppTheme.teal700],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }

    // MARK: - Actions

    private func startScan() {
        step = .scanning
        scanProgress = 0
        Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { timer in
            scanProgress += Double.random(in: 5...23)
            if scanProgress >= 100 {
                scanProgress = 100
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    step = .extracted
                }
            }
        }
    }

    private func verify() {
        step = .results
        onScanComplete()
    }

    private func reset() {
        step = .input
        scanProgress = 0
        manualInput = ""
        activeResult = nil
        onNewScan()
    }
}

// MARK: - Helper Views

struct CornerBracket: View {
    enum Position {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }

    let position: Position

    var body: some View {
        ZStack {
            switch position {
            case .topLeft:
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 32))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 32, y: 0))
                }
                .stroke(AppTheme.teal400, lineWidth: 2)
            case .topRight:
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 32, y: 0))
                    path.addLine(to: CGPoint(x: 32, y: 32))
                }
                .stroke(AppTheme.teal400, lineWidth: 2)
            case .bottomLeft:
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: 32))
                    path.addLine(to: CGPoint(x: 32, y: 32))
                }
                .stroke(AppTheme.teal400, lineWidth: 2)
            case .bottomRight:
                Path { path in
                    path.move(to: CGPoint(x: 32, y: 0))
                    path.addLine(to: CGPoint(x: 32, y: 32))
                    path.addLine(to: CGPoint(x: 0, y: 32))
                }
                .stroke(AppTheme.teal400, lineWidth: 2)
            }
        }
        .frame(width: 32, height: 32)
        .opacity(0.8)
    }
}

struct GridPattern: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 40
            var x: CGFloat = 0
            while x < size.width {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(AppTheme.teal700.opacity(0.5)), lineWidth: 1)
                x += spacing
            }
            var y: CGFloat = 0
            while y < size.height {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(AppTheme.teal700.opacity(0.5)), lineWidth: 1)
                y += spacing
            }
        }
    }
}

struct ScanStep: View {
    let label: String
    let done: Bool

    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(done ? AppTheme.teal700 : AppTheme.slate200)
                    .frame(width: 16, height: 16)
                if done {
                    Image(systemName: "checkmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            Text(label)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(done ? AppTheme.teal700 : AppTheme.slate400)
        }
    }
}

struct ManualField: View {
    let label: String
    let placeholder: String
    @State private var text = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundColor(AppTheme.slate500)
                .tracking(1)
            TextField(placeholder, text: $text)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.slate700)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.slate200, lineWidth: 1)
                )
        }
        .padding(.bottom, 12)
    }
}

struct ResultCountCard: View {
    let count: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(count)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(AppTheme.rose100)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ResultCard: View {
    let result: VerificationResult
    let expanded: Bool
    let onToggle: () -> Void

    private var config: (bg: Color, border: Color, badge: Color, badgeBg: Color, label: String) {
        switch result.severity {
        case .high:
            return (AppTheme.rose50, Color(red: 0.996, green: 0.804, blue: 0.824), AppTheme.rose600, AppTheme.rose100, "CRITICAL")
        case .medium:
            return (AppTheme.amber50, Color(red: 0.992, green: 0.906, blue: 0.541), AppTheme.amber600, AppTheme.amber100, "MODERATE")
        case .low:
            return (AppTheme.emerald50, Color(red: 0.655, green: 0.953, blue: 0.816), AppTheme.emerald600, AppTheme.emerald100, "INFO")
        }
    }

    var body: some View {
        Button(action: onToggle) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(config.label)
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(config.badge)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(config.badgeBg)
                                .clipShape(Capsule())
                            Text(result.type)
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(AppTheme.slate400)
                        }
                        Text(result.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.slate800)

                        if expanded {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(result.detail)
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.slate500)
                                    .multilineTextAlignment(.leading)

                                if !result.drugs.isEmpty {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("INVOLVED")
                                            .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                            .foregroundColor(AppTheme.slate400)
                                            .tracking(1)
                                        HStack(spacing: 4) {
                                            ForEach(result.drugs, id: \.self) { d in
                                                Text(d)
                                                    .font(.system(size: 12))
                                                    .foregroundColor(AppTheme.slate600)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 2)
                                                    .background(Color.white)
                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .stroke(AppTheme.slate200, lineWidth: 1)
                                                    )
                                            }
                                        }
                                    }
                                }

                                if !result.alternatives.isEmpty {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("SAFER ALTERNATIVES")
                                            .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                            .foregroundColor(AppTheme.emerald600)
                                            .tracking(1)
                                        HStack(spacing: 4) {
                                            ForEach(result.alternatives, id: \.self) { a in
                                                Text(a)
                                                    .font(.system(size: 12))
                                                    .foregroundColor(AppTheme.emerald700)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 2)
                                                    .background(AppTheme.emerald50)
                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .stroke(AppTheme.emerald200, lineWidth: 1)
                                                    )
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppTheme.slate400)
                        .rotationEffect(.degrees(expanded ? 180 : 0))
                        .padding(.top, 2)
                }
            }
            .padding(16)
            .background(config.bg)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(config.border, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ScanScreen(scanResult: .none, onScanComplete: {}, onNewScan: {})
}
