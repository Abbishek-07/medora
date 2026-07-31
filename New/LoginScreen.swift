import SwiftUI

struct LoginScreen: View {
    let onLogin: () -> Void

    enum Mode {
        case login
        case register
    }

    @State private var mode: Mode = .login
    @State private var email = ""
    @State private var password = ""
    @State private var showPass = false
    @State private var loading = false
    @State private var biometricPulse = false

    var body: some View {
        VStack(spacing: 0) {
            // Top teal header
            ZStack {
                LinearGradient(
                    colors: [AppTheme.teal950, AppTheme.teal700, AppTheme.teal500],
                    startPoint: UnitPoint(x: 0, y: 0),
                    endPoint: UnitPoint(x: 1, y: 1)
                )
                .frame(height: 260)
                .clipShape(
                    UnevenRoundedRectangle(
                        bottomLeadingRadius: 36,
                        bottomTrailingRadius: 36
                    )
                )

                // Decorative circles
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 2)
                    .frame(width: 112, height: 112)
                    .offset(x: 100, y: -60)
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    .frame(width: 56, height: 56)
                    .offset(x: 60, y: -20)
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .offset(x: -110, y: -50)

                // Logo
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 48, height: 48)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                            Text("💊")
                                .font(.system(size: 24))
                        }
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Medora")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                                .tracking(-0.5)
                            Text("Smart Rx Verification")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(AppTheme.teal200)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity)

            // Mode toggle
            VStack {
                HStack(spacing: 4) {
                    ForEach([Mode.login, .register], id: \.self) { m in
                        Button {
                            mode = m
                        } label: {
                            Text(m == .login ? "Sign In" : "Create Account")
                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                .foregroundColor(mode == m ? AppTheme.teal700 : AppTheme.slate400)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(mode == m ? Color.white : Color.clear)
                                        .shadow(color: mode == m ? Color.black.opacity(0.08) : .clear, radius: 4, x: 0, y: 1)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(4)
                .background(AppTheme.slate100)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

            // Form
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    if mode == .register {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("FULL NAME")
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundColor(AppTheme.slate500)
                            TextField("Sarah Mitchell", text: .constant(""))
                                .font(.system(size: 14))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(AppTheme.slate50)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppTheme.slate200, lineWidth: 1)
                                )
                        }
                        .padding(.bottom, 16)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("EMAIL ADDRESS")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundColor(AppTheme.slate500)
                        HStack(spacing: 12) {
                            Image(systemName: "envelope")
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.slate400)
                            TextField("sarah@example.com", text: $email)
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.slate700)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(AppTheme.slate50)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppTheme.slate200, lineWidth: 1)
                        )
                    }
                    .padding(.bottom, 16)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("PASSWORD")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundColor(AppTheme.slate500)
                        HStack(spacing: 12) {
                            Image(systemName: "lock")
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.slate400)
                            if showPass {
                                TextField("", text: $password)
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.slate700)
                            } else {
                                SecureField("", text: $password)
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.slate700)
                            }
                            Button {
                                showPass.toggle()
                            } label: {
                                Image(systemName: showPass ? "eye" : "eye.slash")
                                    .font(.system(size: 13))
                                    .foregroundColor(AppTheme.slate400)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(AppTheme.slate50)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppTheme.slate200, lineWidth: 1)
                        )
                    }
                    .padding(.bottom, 8)

                    if mode == .login {
                        HStack {
                            Spacer()
                            Button {
                                // forgot password
                            } label: {
                                Text("Forgot password?")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(AppTheme.teal600)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.bottom, 20)
                    }

                    if mode == .register {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("DATE OF BIRTH")
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundColor(AppTheme.slate500)
                            TextField("March 14, 1990", text: .constant(""))
                                .font(.system(size: 14))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(AppTheme.slate50)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppTheme.slate200, lineWidth: 1)
                                )
                        }
                        .padding(.bottom, 16)
                    }

                    // Submit button
                    Button {
                        handleSubmit()
                    } label: {
                        HStack(spacing: 8) {
                            if loading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                            Text(loading ? "Verifying..." : (mode == .login ? "Sign In" : "Create Account"))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: loading ? [AppTheme.teal800] : [AppTheme.teal900, AppTheme.teal700],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .opacity((!email.isEmpty && !password.isEmpty) ? 1 : 0.6)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(loading || email.isEmpty || password.isEmpty)

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
                    .padding(.vertical, 20)

                    // Biometric button
                    Button {
                        handleBiometric()
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(biometricPulse ? AppTheme.teal700 : AppTheme.slate100)
                                    .frame(width: 32, height: 32)
                                Image(systemName: "faceid")
                                    .font(.system(size: 18))
                                    .foregroundColor(biometricPulse ? .white : AppTheme.slate500)
                            }
                            Text(biometricPulse ? "Authenticating…" : "Sign in with Face ID")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.slate600)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(biometricPulse ? AppTheme.teal50 : Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(biometricPulse ? AppTheme.teal700 : AppTheme.slate200, lineWidth: 2)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Privacy note
                    Text("All prescription data is processed on-device. Medora never shares your medical information with third parties.")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.slate400)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 24)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
        }
        .background(Color.white)
    }

    private func handleSubmit() {
        guard !email.isEmpty, !password.isEmpty else { return }
        loading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            loading = false
            onLogin()
        }
    }

    private func handleBiometric() {
        biometricPulse = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            biometricPulse = false
            onLogin()
        }
    }
}

#Preview {
    LoginScreen(onLogin: {})
}
