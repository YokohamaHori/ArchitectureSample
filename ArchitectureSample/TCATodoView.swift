import SwiftUI
import ComposableArchitecture

// MARK: - Model
struct TCATodoItem: Identifiable, Equatable {
    var id: UUID
    var task: String
}

struct TCATodoState: Equatable {
    var todos: [TCATodoItem] = []
    var newTask: String = ""
}

enum TCATodoAction: Equatable {
    case addTask
    case updateNewTask(String)
    case removeTask(IndexSet)
}

// MARK: - Reducer
let todoReducer = Reducer<TCATodoState, TCATodoAction, Void> { state, action, _ in
    switch action {
    case .addTask:
        state.todos.append(TCATodoItem(id: UUID(), task: state.newTask))
        state.newTask = ""
        return .none
    case .updateNewTask(let text):
        state.newTask = text
        return .none
    case .removeTask(let indexSet):
        state.todos.remove(atOffsets: indexSet)
        return .none
    }
}

// MARK: - View
struct TCATodoView: View {
    let titleText: String
    let store: Store<TCATodoState, TCATodoAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                HStack {
                    TextField("New task " + titleText, text: viewStore.binding(
                        get: \.newTask,
                        send: TCATodoAction.updateNewTask
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        viewStore.send(.addTask)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                    }
                }
                .padding()
                
                List {
                    ForEach(viewStore.todos) { todo in
                        Text(todo.task)
                    }
                    .onDelete { indexSet in
                        viewStore.send(.removeTask(indexSet))
                    }
                }
            }
            .navigationTitle(titleText)
        }
    }
}
