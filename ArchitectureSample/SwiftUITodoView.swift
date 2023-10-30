import SwiftUI

// MARK: - Model
struct SwiftUITodoItem: Identifiable {
    var id = UUID()
    var task: String
}

// MARK: - View
struct SwiftUITodoView: View {
    let titleText: String
    
    @State private var newTask: String = ""
    @State private var tasks: [SwiftUITodoItem] = []
    
    var body: some View {
        VStack {
            HStack {
                TextField("New task " + titleText, text: $newTask)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: addTask) {
                    Image(systemName: "plus.circle.fill")
                        .font(.largeTitle)
                }
            }
            .padding()
            
            List {
                ForEach(tasks) { task in
                    Text(task.task)
                }
                .onDelete(perform: removeTask)
            }
        }
        .navigationTitle(titleText)
    }
    
    func addTask() {
        let newTodo = SwiftUITodoItem(task: newTask)
        tasks.append(newTodo)
        newTask = ""
    }
    
    func removeTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
}
