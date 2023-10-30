import UIKit

// MARK: - Entity
struct CleanTodoItem {
    var id = UUID()
    var task: String
}

// MARK: - Use Cases
protocol CleanTodoUseCase {
    func addTask(task: String)
    func removeTask(at index: Int)
    func getTasks() -> [CleanTodoItem]
}

class CleanTodoInteractor: CleanTodoUseCase {
    private var tasks: [CleanTodoItem] = []
    
    func addTask(task: String) {
        let newTodo = CleanTodoItem(task: task)
        tasks.append(newTodo)
    }
    
    func removeTask(at index: Int) {
        tasks.remove(at: index)
    }
    
    func getTasks() -> [CleanTodoItem] {
        return tasks
    }
}

// MARK: - Presenter
class CleanTodoPresenter {
    weak var viewController: CleanTodoViewController?
    
    private let useCase: CleanTodoUseCase
    
    init(useCase: CleanTodoUseCase) {
        self.useCase = useCase
    }
    
    func addTask(task: String) {
        useCase.addTask(task: task)
        viewController?.refreshUI()
    }
    
    func removeTask(at index: Int) {
        useCase.removeTask(at: index)
        viewController?.deleteRow(at: index)
    }
    
    func getTasks() -> [CleanTodoItem] {
        return useCase.getTasks()
    }
}

// MARK: - View
class CleanTodoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    private let titleText: String
    private var tableView: UITableView!
    private var taskTextField: UITextField!
    private var addButton: UIButton!
    
    private var presenter: CleanTodoPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        taskTextField.delegate = self
        
        addButton.addTarget(self, action: #selector(addTask), for: .touchUpInside)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc func addTask() {
        guard let task = taskTextField.text, !task.isEmpty else { return }
        presenter.addTask(task: task)
    }
    
    func refreshUI() {
        tableView.reloadData()
        taskTextField.text = ""
    }
    
    func deleteRow(at index: Int) {
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    // TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getTasks().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = presenter.getTasks()[indexPath.row].task
        return cell
    }
    
    // TableView Delegate Methods
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presenter.removeTask(at: indexPath.row)
        }
    }
    
    // TextField Delegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        addTask()
        return true
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = titleText
        
        taskTextField = UITextField(frame: CGRect(x: 20, y: 100, width: view.bounds.width - 140, height: 40))
        taskTextField.placeholder = "New task " + titleText
        taskTextField.borderStyle = .roundedRect
        view.addSubview(taskTextField)
        
        addButton = UIButton(frame: CGRect(x: view.bounds.width - 110, y: 100, width: 100, height: 40))
        addButton.setTitle("Add", for: .normal)
        addButton.setTitleColor(.blue, for: .normal)
        view.addSubview(addButton)
        
        tableView = UITableView(frame: CGRect(x: 0, y: 150, width: view.bounds.width, height: view.bounds.height - 150))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
    }
    
    init(title: String, presenter: CleanTodoPresenter) {
        self.titleText = title
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        self.presenter.viewController = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
