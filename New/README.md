# Medora — Swift iOS App

This is a complete SwiftUI conversion of the **Medora** prescription safety verification app, originally built as a React + Vite + Tailwind CSS web application.

## Overview

Medora is a smart prescription verification mobile app that helps patients:
- **Verify prescriptions** by scanning or manually entering medications
- **Detect drug interactions**, duplicate medications, and dosage advisories
- **Chat with an AI assistant** (Medora AI) about medications
- **Track prescription history** with safety scores
- **Manage a medical profile** with conditions, allergies, and settings

## Project Structure

```
Medora/
├── MedoraApp.swift                  # App entry point (@main)
├── ContentView.swift                # Root view: iPhone shell, status bar, tab bar, theme
└── Views/
    └── Screens/
        ├── LoginScreen.swift        # Sign in / Create account with biometric auth
        ├── HomeScreen.swift         # Dashboard: safety score, alerts, active meds
        ├── ScanScreen.swift         # Verify Rx: scan/manual input, progress, results
        ├── HistoryScreen.swift      # Prescription history with filters
        ├── ChatScreen.swift         # Medora AI chat assistant
        └── ProfileScreen.swift      # Medical profile, settings, sign out
```

## Requirements

- iOS 17.0+
- Xcode 15+
- Swift 5.9+

## Building

Open the project in Xcode and run, or build from command line:

```bash
swift build
```

## Features Implemented

### Authentication (LoginScreen)
- Sign In / Create Account mode toggle
- Email + password fields with show/hide password
- Loading state with spinner
- Biometric (Face ID) authentication simulation
- Registration fields (Full Name, Date of Birth)

### Home Dashboard (HomeScreen)
- Greeting header with avatar and notification badge
- Quick stats (Active Meds, Alerts, Verified)
- Prescription Safety Score card with animated ring and progress bar
- Expandable alert cards (interaction, duplicate, dosage) with severity colors
- Active medications list with safety indicators

### Prescription Verification (ScanScreen)
- Scan Rx / Manual Entry mode toggle
- Camera frame UI with grid overlay and corner brackets
- Scanning progress with step-by-step status
- Extracted medications list
- Verification results with severity badges (CRITICAL/MODERATE/INFO)
- Expandable result details with involved drugs and safer alternatives

### History (HistoryScreen)
- Summary stats (Total, Flagged, Clear)
- Filter tabs (All / Flagged / Clear)
- Timeline cards with score bars and status badges
- Expandable details with metrics grid and action buttons

### AI Chat (ChatScreen)
- Quick prompt suggestions
- Message bubbles (user vs assistant)
- Typing indicator animation
- Bold markdown (**text**) parsing
- Predefined responses for common questions
- Reset chat functionality

### Profile (ProfileScreen)
- Avatar card with verified patient status
- Medical profile info rows
- Conditions and allergies tags
- Settings toggles (alerts, biometric, auto-save)
- Privacy & data section
- Export records / Sign out actions

## Design System

The design closely follows the original Tailwind CSS theme:

| Color | Hex | Usage |
|-------|-----|-------|
| Teal-700 | #0e7377 | Primary accent |
| Teal-900 | #073b3e | Gradient dark |
| Rose-600 | #e11d48 | High risk / alerts |
| Amber-600 | #d97706 | Moderate risk |
| Emerald-600 | #059669 | Safe / verified |
| Slate palette | — | Neutrals |

Fonts use the system monospaced design (`DM Mono` equivalent) for labels and data, and standard system font for body text.
