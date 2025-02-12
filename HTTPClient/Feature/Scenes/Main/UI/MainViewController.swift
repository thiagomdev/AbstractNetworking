import UIKit

final class MainViewController: UIViewController {

    private let viewModel: MainViewModeling
    
    init(viewModel: MainViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        
        viewModel.displayData { result in
            switch result {
            case let .success(dataModel):
                dump(dataModel)
            case let .failure(error):
                dump(error)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

