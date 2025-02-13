import UIKit

final class MainViewController: UIViewController {

    private let viewModel: MainViewModeling
    
    init(viewModel: MainViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        didLoadData()
        view.backgroundColor = .lightGray
    }
    
    required init?(coder: NSCoder) { nil }
    
    func didLoadData() {
        viewModel.displayData { result in
            switch result {
            case let .success(dataModel):
                dump(dataModel)
            case let .failure(error):
                dump(error)
            }
        }
    }
}

