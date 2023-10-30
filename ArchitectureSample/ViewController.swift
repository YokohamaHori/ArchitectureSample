import UIKit
import ComposableArchitecture
import SwiftUI

enum Architecture: String, CaseIterable {
    case MVC = "MVC"
    case MVVM = "MVVM"
    case Rx = "RxSwift"
    case RxMVVM = "RxSwift+MVVM"
    case Clean = "Clean Architecture"
    case VIPER = "VIPER"
    case SwiftUI = "SwiftUI"
    case SwiftUIMVVM = "SwiftUI+MVVM"
    case TCA = "TCA"
    
    var viewController: UIViewController {
        switch self {
        case .MVC:
            return MVCTodoViewController(title: self.rawValue)
        case .MVVM:
            return MVVMTodoViewController(title: self.rawValue)
        case .Rx:
            return RXTodoViewController(title: self.rawValue)
        case .RxMVVM:
            return RXMVVMTodoViewController(title: self.rawValue)
        case .Clean:
            let presenter = CleanTodoPresenter(useCase: CleanTodoInteractor())
            return CleanTodoViewController(title: self.rawValue, presenter: presenter)
        case .VIPER:
            let router = VIPERTodoRouter()
            return router.createTodoViewController(title: self.rawValue)
        case .SwiftUI:
            return UIHostingController(rootView: SwiftUITodoView(titleText: self.rawValue))
        case .SwiftUIMVVM:
            return UIHostingController(rootView: SwiftUIMVVMTodoView(titleText: self.rawValue))
        case .TCA:
            let detailView = TCATodoView(titleText: self.rawValue, store: Store(
                initialState: TCATodoState(),
                reducer: todoReducer,
                environment: ()
            ))
            return UIHostingController(rootView: detailView)
        }
    }
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var tableView: UITableView!
    private let architectures = Architecture.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return architectures.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = architectures[indexPath.row].rawValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = architectures[indexPath.row].viewController
        navigationController?.pushViewController(viewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
