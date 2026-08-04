//
//  Theme.swift
//  Medora
//
//  Drop this into your project (e.g. a new "Theme" group). It's the
//  single source of truth for the white + Barbie-pink look, so
//  DashboardView, PrescriptionsListView, NewPrescriptionView, and
//  VerificationDetailView can all share it.
//

import SwiftUI

extension Color {
    static let medoraPink       = Color(red: 1.00, green: 0.41, blue: 0.63)  // Barbie pink #FF6AA0
    static let medoraPinkDeep   = Color(red: 0.93, green: 0.24, blue: 0.51)  // Deeper accent #EE3D82
    static let medoraPinkSoft   = Color(red: 1.00, green: 0.86, blue: 0.92)  // Light pink surface #FFDBEB
    static let medoraBlush      = Color(red: 1.00, green: 0.96, blue: 0.98)  // Near-white bg #FFF5FA

    static let medoraInk        = Color(red: 0.16, green: 0.14, blue: 0.18)
    static let medoraGraySubtle = Color(red: 0.55, green: 0.53, blue: 0.57)

    // Status colors — reused by StatusBadge / StatCard everywhere
    static let medoraVerified   = Color(red: 0.20, green: 0.72, blue: 0.47) // green
    static let medoraFlagged    = Color(red: 0.92, green: 0.26, blue: 0.29) // red
    static let medoraPending    = Color(red: 0.98, green: 0.62, blue: 0.20) // orange
    static let medoraResolved   = Color(red: 0.35, green: 0.55, blue: 0.95) // blue
    static let medoraTotal      = Color(red: 0.93, green: 0.24, blue: 0.51) // pink, for "Total"
}

extension LinearGradient {
    static let medoraBackground = LinearGradient(
        colors: [Color.medoraBlush, Color.medoraPinkSoft.opacity(0.5)],
        startPoint: .top, endPoint: .bottom
    )
    static let medoraPinkButton = LinearGradient(
        colors: [Color.medoraPink, Color.medoraPinkDeep],
        startPoint: .leading, endPoint: .trailing
    )
}

/// Replaces `.regularMaterial` cards with soft white cards + pink glow,
/// which reads much more "Medora" than the default translucent material.
struct MedoraCard: ViewModifier {
    var padding: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.medoraPink.opacity(0.15), radius: 12, x: 0, y: 6)
            )
    }
}

extension View {
    func medoraCard(padding: CGFloat = 16) -> some View {
        modifier(MedoraCard(padding: padding))
    }

    func medoraPrimaryButton() -> some View {
        self
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(LinearGradient.medoraPinkButton)
                    .shadow(color: Color.medoraPinkDeep.opacity(0.3), radius: 10, x: 0, y: 5)
            )
    }
}

/// Central place to map a status to a color, used by StatusBadge and
/// anywhere else that needs to color-code a PrescriptionStatus.
extension PrescriptionStatus {
    var medoraColor: Color {
        switch self {
        case .pending:  return .medoraPending
        case .verified: return .medoraVerified
        case .flagged:  return .medoraFlagged
        case .resolved: return .medoraResolved
        }
    }
}
