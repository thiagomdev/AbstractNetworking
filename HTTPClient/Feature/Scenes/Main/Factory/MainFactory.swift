import UIKit

enum MainFactory {
    static func make() -> UIViewController {
        let service = MainService(client: NetwokingProvider())
        let viewModel = MainViewModel(service: service)
        let viewController = MainViewController(viewModel: viewModel)
        return viewController
    }
}
