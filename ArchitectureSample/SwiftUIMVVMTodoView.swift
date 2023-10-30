import SwiftUI

// MARK: - Model
struct SwiftUIMVVMTodoItem: Identifiable {
    var id = UUID()
    var task: String
}

// MARK: - ViewModel
class SwiftUIMVVMTodoViewModel: ObservableObject {
    @Published var tasks: [SwiftUIMVVMTodoItem] = []
    @Published var newTask: String = ""
    
    func addTask() {
        let newTodo = SwiftUIMVVMTodoItem(task: newTask)
        tasks.append(newTodo)
        newTask = ""
    }
    
    func removeTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
}

// MARK: - View
struct SwiftUIMVVMTodoView: View {
    let titleText: String
    
    @ObservedObject private var viewModel = SwiftUIMVVMTodoViewModel()
    
    var body: some View {
        VStack {
            HStack {
                TextField("New task " + titleText, text: $viewModel.newTask)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: viewModel.addTask) {
                    Image(systemName: "plus.circle.fill")
                        .font(.largeTitle)
                }
            }
            .padding()
            
            List {
                ForEach(viewModel.tasks) { task in
                    Text(task.task)
                }
                .onDelete(perform: viewModel.removeTask)
            }
        }
        .navigationTitle(titleText)
    }
}
