# tugas_dari_ppt

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Reporting (PDF export) 🔧

This project now includes a simple reporting feature that can export screening results and history as a formal PDF document. It is intended for documentation, progress recap, and sharing with professionals.

- From the Result screen: tap **"Ekspor Laporan (PDF)"** to generate a PDF for the current screening.
- From the History screen: tap **"Ekspor Rekap (PDF)"** in the statistics card to generate a history/rekap PDF.

Dependencies added:
- `pdf: ^3.10.8`
- `printing: ^5.12.0`

Run `flutter pub get` after pulling changes to install the new packages.
