import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showAddSheet = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingEntry: Entry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    ForEach(store.entries) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.origin).font(Theme.headlineFont)
                            Text(entry.destination).font(Theme.bodyFont).foregroundColor(.secondary)
                            HStack {
                                Text("\(entry.miles, specifier: \"%.1f\") mi")
                                Spacer()
                                Text("\(entry.fuelCost, specifier: \"%.1f\")")
                            }
                            .font(.caption)
                            .foregroundColor(Theme.accent)
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Theme.card)
                        .contentShape(Rectangle())
                        .onTapGesture { editingEntry = entry }
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Roadtoll")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if store.canAddMore || purchases.isPro {
                            showAddSheet = true
                        } else {
                            showPaywall = true
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addEntryButton")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                EntryFormView(entry: nil) { newEntry in
                    store.add(newEntry)
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryFormView(entry: entry) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}

struct EntryFormView: View {
    @Environment(\.dismiss) var dismiss
    @State private var origin: String
    @State private var destination: String
    @State private var milesText: String
    @State private var fuelCostText: String
    @State private var notes: String
    @FocusState private var focusedField: Field?
    private let originalID: UUID
    private let onSave: (Entry) -> Void

    enum Field { case f1, f2, n1, n2, notes }

    init(entry: Entry?, onSave: @escaping (Entry) -> Void) {
        _origin = State(initialValue: entry?.origin ?? "")
        _destination = State(initialValue: entry?.destination ?? "")
        _milesText = State(initialValue: entry != nil ? String(entry!.miles) : "")
        _fuelCostText = State(initialValue: entry != nil ? String(entry!.fuelCost) : "")
        _notes = State(initialValue: entry?.notes ?? "")
        originalID = entry?.id ?? UUID()
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("origin") {
                    TextField("origin", text: $origin)
                        .focused($focusedField, equals: .f1)
                        .accessibilityIdentifier("field_origin")
                }
                Section("destination") {
                    TextField("destination", text: $destination)
                        .focused($focusedField, equals: .f2)
                        .accessibilityIdentifier("field_destination")
                }
                Section("Details") {
                    TextField("miles", text: $milesText)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .n1)
                        .accessibilityIdentifier("field_miles")
                    TextField("fuelCost", text: $fuelCostText)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .n2)
                        .accessibilityIdentifier("field_fuelCost")
                    TextField("Notes", text: $notes)
                        .focused($focusedField, equals: .notes)
                        .accessibilityIdentifier("field_notes")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .navigationTitle(originalID == UUID() ? "New Entry" : "Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("formCancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let entry = Entry(
                            id: originalID,
                            origin: origin,
                            destination: destination,
                            miles: Double(milesText) ?? 0,
                            fuelCost: Double(fuelCostText) ?? 0,
                            notes: notes
                        )
                        onSave(entry)
                        dismiss()
                    }
                    .accessibilityIdentifier("formSaveButton")
                    .disabled(origin.isEmpty)
                }
            }
        }
    }
}
