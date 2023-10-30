import UIKit
import RxSwift
import RxCocoa

// MARK: - Model
struct RXTodoItem: Identifiable {
    var id = UUID()
    var task: String
}

// MARK: - View & Controller
class RXTodoViewController: UIViewController {
    private let titleText: String
    private var tableView: UITableView!
    private var taskTextField: UITextField!
    private var addButton: UIButton!
    
    private var tasksRelay = BehaviorRelay<[MVCTodoItem]>(value: [])
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // Bindings
        addButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.addTask()
            })
            .disposed(by: disposeBag)
        
        taskTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                self?.addTask()
            })
            .disposed(by: disposeBag)
        
        tasksRelay.bind(to: tableView.rx.items(cellIdentifier: "cell")) { (row, element, cell) in
            cell.textLabel?.text = element.task
        }
        .disposed(by: disposeBag)
        
        tableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                var tasks = self?.tasksRelay.value ?? []
                tasks.remove(at: indexPath.row)
                self?.tasksRelay.accept(tasks)
            })
            .disposed(by: disposeBag)
    }
    
    func addTask() {
        guard let task = taskTextField.text, !task.isEmpty else { return }
        let newTodo = MVCTodoItem(task: task)
        var currentTasks = tasksRelay.value
        currentTasks.append(newTodo)
        tasksRelay.accept(currentTasks)
        taskTextField.text = ""
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
