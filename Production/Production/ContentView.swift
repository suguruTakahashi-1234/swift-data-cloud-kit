import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var newItemText = ""
    @State private var showingAddSheet = false

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        ItemDetailView(item: item)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(item.text)
                                .lineLimit(1)
                            Text(item.timestamp, format: .dateTime.day().month().hour().minute())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete {
                    deleteItems(offsets: $0)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: { showingAddSheet = true }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                addItemView
            }
        } detail: {
            Text("Select an item")
        }
    }

    private var addItemView: some View {
        NavigationStack {
            Form {
                TextField("Enter text", text: $newItemText)
            }
            .navigationTitle("Add New Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        newItemText = ""
                        showingAddSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addItem(text: newItemText)
                        newItemText = ""
                        showingAddSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func addItem(text: String) {
        withAnimation {
            let newItem = Item(text: text, timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

struct ItemDetailView: View {
    @Bindable var item: Item
    
    var body: some View {
        Form {
            Section(header: Text("Item Details")) {
                TextField("Text", text: $item.text)
                
                Text("Created: \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Item Details")
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
