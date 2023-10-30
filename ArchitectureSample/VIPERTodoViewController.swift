import UIKit

// MARK: - Entity
struct VIPERTodoItem: Identifiable {
    var id = UUID()
    var task: String
}

// MARK: - Interactor
protocol VIPERTodoInteractorInput {
    func addTask(task: String)
    func removeTask(at index: Int)
    func getTasks() -> [VIPERTodoItem]
}

class VIPERTodoInteractor: VIPERTodoInteractorInput {
    private var tasks: [VIPERTodoItem] = []
    
    func addTask(task: String) {
        let newTodo = VIPERTodoItem(task: task)
        tasks.append(newTodo)
    }
    
    func removeTask(at index: Int) {
        tasks.remove(at: index)
    }
    
    func getTasks() -> [VIPERTodoItem] {
        return tasks
    }
}

// MARK: - Presenter
protocol VIPERTodoPresenterInput {
    func addTask(task: String)
    func removeTask(at index: Int)
    func getTasks() -> [VIPERTodoItem]
}

class VIPERTodoPresenter: VIPERTodoPresenterInput {
    private weak var view: VIPERTodoViewProtocol?
    private var interactor: VIPERTodoInteractorInput
    
    init(view: VIPERTodoViewProtocol, interactor: VIPERTodoInteractorInput) {
        self.view = view
        self.interactor = interactor
    }
    
    func addTask(task: String) {
        interactor.addTask(task: task)
        view?.refreshUI()
    }
    
    func removeTask(at index: Int) {
        interactor.removeTask(at: index)
        view?.deleteRow(at: index)
    }
    
    func getTasks() -> [VIPERTodoItem] {
        interactor.getTasks()
    }
}

// MARK: - View
protocol VIPERTodoViewProtocol: AnyObject {
    func refreshUI()
    func deleteRow(at index: Int)
}

class VIPERTodoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, VIPERTodoViewProtocol {
    private let titleText: String
    private var tableView: UITableView!
    private var taskTextField: UITextField!
    private var addButton: UIButton!
    
    var presenter: VIPERTodoPresenterInput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        taskTextField.delegate = self
        
        addButton.addTarget(self, action: #selector(addTask), for: .touchUpInside)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc func addTask() {
        guard let task = taskTextField.text else { return }
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
    
    init(title: String) {
        self.titleText = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Router
protocol VIPERTodoRouterProtocol {
    func createTodoViewController(title: String) -> UIViewController
}

class VIPERTodoRouter: VIPERTodoRouterProtocol {
    func createTodoViewController(title: String) -> UIViewController {
        let interactor = VIPERTodoInteractor()
        let todoViewController = VIPERTodoViewController(title: title)
        let presenter = VIPERTodoPresenter(view: todoViewController, interactor: interactor)
        todoViewController.presenter = presenter
        return todoViewController
    }
}
