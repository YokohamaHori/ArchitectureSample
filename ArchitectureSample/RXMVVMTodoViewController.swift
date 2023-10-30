import UIKit
import RxSwift
import RxCocoa

// MARK: - Model
struct RXMVVMTodoItem: Identifiable {
    var id = UUID()
    var task: String
}

// MARK: - ViewModel
class RXMVVMTodoViewModel {
    // Outputs
    let tasks: Observable<[RXMVVMTodoItem]>
    
    // Inputs
    let addTaskSubject = PublishSubject<String>()
    let removeTaskAtIndexSubject = PublishSubject<Int>()
    
    private let tasksRelay = BehaviorRelay<[RXMVVMTodoItem]>(value: [])
    private let disposeBag = DisposeBag()
    
    init() {
        self.tasks = tasksRelay.asObservable()
        
        addTaskSubject
            .map { RXMVVMTodoItem(task: $0) }
            .withLatestFrom(tasksRelay.asObservable()) { (newTask: RXMVVMTodoItem, tasks: [RXMVVMTodoItem]) -> [RXMVVMTodoItem] in
                return tasks + [newTask]
            }
            .bind(to: tasksRelay)
            .disposed(by: disposeBag)
        
        removeTaskAtIndexSubject
            .withLatestFrom(tasksRelay.asObservable()) { (index: Int, tasks: [RXMVVMTodoItem]) -> [RXMVVMTodoItem] in
                var tasks = tasks
                tasks.remove(at: index)
                return tasks
            }
            .bind(to: tasksRelay)
            .disposed(by: disposeBag)
    }
}

// MARK: - View & Controller
class RXMVVMTodoViewController: UIViewController {
    private let titleText: String
    private var tableView: UITableView!
    private var taskTextField: UITextField!
    private var addButton: UIButton!
    
    private let disposeBag = DisposeBag()
    private let viewModel = RXMVVMTodoViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // bind
        viewModel.tasks
            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { row, task, cell in
                cell.textLabel?.text = task.task
            }
            .disposed(by: disposeBag)
        
        taskTextField.rx.controlEvent(.editingDidEndOnExit)
            .withLatestFrom(taskTextField.rx.text.orEmpty)
            .do(onNext: { [weak self] _ in
                self?.taskTextField.text = ""
            })
            .bind(to: viewModel.addTaskSubject)
            .disposed(by: disposeBag)
        
        tableView.rx.itemDeleted
            .map { $0.row }
            .bind(to: viewModel.removeTaskAtIndexSubject)
            .disposed(by: disposeBag)
        
        addButton.rx.tap
            .withLatestFrom(taskTextField.rx.text.orEmpty)
            .do(onNext: { [weak self] _ in
                self?.taskTextField.text = ""
            })
            .bind(to: viewModel.addTaskSubject)
            .disposed(by: disposeBag)
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
