import UIKit

// MARK: - Model
struct MVVMTodoItem: Identifiable {
    var id = UUID()
    var task: String
}

// MARK: - ViewModel
class MVVMTodoViewModel {
    var tasks: [MVVMTodoItem] = []
    
    func add(task: String) {
        let newTodo = MVVMTodoItem(task: task)
        tasks.append(newTodo)
    }
    
    func remove(at index: Int) {
        tasks.remove(at: index)
    }
}

// MARK: - View & Controller
class MVVMTodoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    private let titleText: String
    private var tableView: UITableView!
    private var taskTextField: UITextField!
    private var addButton: UIButton!
    
    private let viewModel = MVVMTodoViewModel()
    
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
        viewModel.add(task: task)
        tableView.reloadData()
        taskTextField.text = ""
    }
    
    // TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.tasks[indexPath.row].task
        return cell
    }
    
    // TableView Delegate Methods
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
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
    
    init(title: String) {
        self.titleText = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
