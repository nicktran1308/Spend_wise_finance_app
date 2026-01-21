//
//  ExportDataSheet.swift
//  spendwise_nick
//
//  Created by Nick on 1/13/26.
//
import SwiftUI

/// Sheet for exporting transaction data
struct ExportDataSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let transactions: [Transaction]
    
    @State private var isExporting = false
    @State private var exportURL: URL?
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Icon
                Image(systemName: "square.and.arrow.up.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.accentBlue)
                
                // Info
                VStack(spacing: 8) {
                    Text("Export Transactions")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("\(transactions.count) transactions will be exported as CSV")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Export Button
                Button {
                    exportToCSV()
                } label: {
                    HStack {
                        if isExporting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "doc.text")
                        }
                        Text("Export CSV")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentBlue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isExporting || transactions.isEmpty)
                
                Spacer()
            }
            .padding()
            .background(Color.appBackground)
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }
    
    private func exportToCSV() {
        isExporting = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Create CSV content
            var csv = "Date,Title,Amount,Type,Category,Note\n"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            
            for tx in transactions.sorted(by: { $0.date > $1.date }) {
                let date = dateFormatter.string(from: tx.date)
                let title = tx.title.replacingOccurrences(of: ",", with: ";")
                let amount = String(format: "%.2f", tx.amount)
                let type = tx.isIncome ? "Income" : "Expense"
                let category = tx.category?.name ?? "None"
                let note = tx.note.replacingOccurrences(of: ",", with: ";")
                
                csv += "\(date),\(title),\(amount),\(type),\(category),\(note)\n"
            }
            
            // Save to temp file
            let fileName = "SpendWise_Export_\(Date().formatted(date: .numeric, time: .omitted)).csv"
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            do {
                try csv.write(to: tempURL, atomically: true, encoding: .utf8)
                
                DispatchQueue.main.async {
                    exportURL = tempURL
                    isExporting = false
                    showingShareSheet = true
                }
            } catch {
                DispatchQueue.main.async {
                    isExporting = false
                }
            }
        }
    }
}

/// UIKit share sheet wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ExportDataSheet(transactions: [])
        .preferredColorScheme(.dark)
}
