//
//  SplashView.swift
//  Medora
//
//  Stethoscope + "Medora App" wordmark, then scales/fades out to reveal
//  ContentView (already mounted underneath) — the "zoom out into the
//  dashboard" effect you asked for at the start.
//

import SwiftUI

struct SplashView: View {
    var onFinished: () -> Void

    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    @State private var pulse = false
    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 12

    @State private var splashScale: CGFloat = 1.0
    @State private var splashOpacity: Double = 1.0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.medoraPinkDeep, Color.medoraPink],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 22) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 168, height: 168)
                        .scaleEffect(pulse ? 1.12 : 0.9)
                        .opacity(pulse ? 0.0 : 0.7)
                        .animation(.easeOut(duration: 1.4).repeatForever(autoreverses: false), value: pulse)

                    Circle()
                        .fill(Color.white)
                        .frame(width: 128, height: 128)
                        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)

                    Image(systemName: "stethoscope")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 62, height: 62)
                        .foregroundStyle(Color.medoraPinkDeep)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                Text("Medora App")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .opacity(textOpacity)
                    .offset(y: textOffset)
            }
        }
        .scaleEffect(splashScale)
        .opacity(splashOpacity)
        .onAppear { runSequence() }
    }

    private func runSequence() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.65)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.25)) {
            textOpacity = 1.0
            textOffset = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { pulse = true }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.easeInOut(duration: 0.7)) {
                splashScale = 6.0
                splashOpacity = 0.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                onFinished()
            }
        }
    }
}//
//  SplashView.swift
//  New
//
//  Created by STUDENT_23 on 04/08/26.
//

