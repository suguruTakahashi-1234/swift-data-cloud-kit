import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [
        SortDescriptor(\Item.order, order: .forward),
        SortDescriptor(\Item.timestamp, order: .reverse)
    ])
    private var items: [Item]
    @State private var newItemText = ""
    @State private var showingAddSheet = false
    @State private var selectedItem: Item?
    // https://capibara1969.com/3478/
    @State var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    Button {
                        editMode = .inactive
                        selectedItem = item
                    } label: {
                        VStack(alignment: .leading) {
                            Text(item.text)
                                .lineLimit(1)
                            Text(item.timestamp, format: .dateTime.day().month().hour().minute())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .foregroundStyle(.primary)
                    }
                }
                .onMove { indices, newOffset in
                    withAnimation {
                        try? modelContext.transaction {
                            // 移動するアイテムのインデックスと移動先
                            guard let sourceIndex = indices.first else { return }
                            
                            // 移動するアイテム
                            let movingItem = items[sourceIndex]
                            
                            // 移動先インデックスの調整（重要）
                            // sourceIndexより後ろに移動する場合は、自分自身が抜けることを考慮して-1する
                            let targetIndex = sourceIndex < newOffset ? newOffset - 1 : newOffset
                            
                            // 移動方向に応じて処理（こうしないと挙動がおかしくなる）
                            if sourceIndex < targetIndex {
                                // 上から下への移動
                                // sourceIndexとtargetIndexの間のアイテムを1つ上に移動
                                for i in (sourceIndex + 1)...targetIndex {
                                    items[i].order -= 1
                                }
                            } else if sourceIndex > targetIndex {
                                // 下から上への移動
                                // targetIndexとsourceIndexの間のアイテムを1つ下に移動
                                for i in targetIndex..<sourceIndex {
                                    items[i].order += 1
                                }
                            } else {
                                // 同じ位置への移動（何もしない）
                                return
                            }
                            
                            // 移動アイテムを目的の位置に設定
                            movingItem.order = targetIndex
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
                    Button {
                        editMode = .inactive
                        showingAddSheet = true
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                addItemView
            }
            .navigationDestination(item: $selectedItem) { item in
                ItemDetailView(item: item)
            }
            .navigationTitle("Items")
            // https://capibara1969.com/3478/
            .environment(\.editMode, $editMode)
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
        List {
            Section(header: Text("Item Details")) {
                NavigationLink {
                    VStack {
                        TextField("Item Text", text: $item.text)
                            .textFieldStyle(.roundedBorder)
                            .padding()
                    }
                    .navigationTitle("Edit Item")
                } label: {
                    Text(item.text)
                        .lineLimit(1)
                }
                
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
