import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return run()
    }
}

extension AppDelegate {
    private func run() -> Bool {
        window = UIWindow(frame: UIScreen.main.coordinateSpace.bounds)
        window?.rootViewController = MainFactory.make()
        window?.makeKeyAndVisible()
        return true
    }
}
