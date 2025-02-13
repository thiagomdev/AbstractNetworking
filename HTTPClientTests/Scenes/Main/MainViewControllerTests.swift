import XCTest
@testable import HTTPClient

final class MainViewControllerTests: XCTestCase {
    func test_display_data_when_retuned_success() {
        let (sut, spy) = makeSut()
        let dataModel: DataModel = .fixture()
        spy.shouldBeExpected = .success(dataModel)
        
        sut.didLoadData()
        
        XCTAssertTrue(spy.fetchDataCalled)
        XCTAssertEqual(spy.fetchDataCount, 1)
        XCTAssertNotNil(dataModel)
    }
    
    func test_display_data_when_retuned_failure() {
        let (sut, spy) = makeSut()
        let expectedError: NSError = .init(domain: "Test", code: -999)
        spy.shouldBeExpected = .failure(expectedError)
        
        sut.didLoadData()
        
        XCTAssertTrue(spy.fetchDataCalled)
        XCTAssertEqual(spy.fetchDataCount, 1)
        XCTAssertNotNil(expectedError)
    }
    
    func test_init_with_coder_should_return_nil() {
        let coder = NSCoder()
        let viewController = MainViewController(coder: coder)
        
        XCTAssertNil(viewController)
    }
}

final class MainViewModelSpy: MainViewModeling {
    private(set) var fetchDataCalled: Bool = false
    private(set) var fetchDataCount: Int = 0
    
    var shouldBeExpected: ((MainServiceResult))?
                           
    func displayData(onComplete: @escaping (MainServiceResult) -> Void) {
        fetchDataCalled = true
        fetchDataCount += 1
        if let shouldBeExpected {
            onComplete(shouldBeExpected)
        }
    }
}

extension MainViewControllerTests {
    private func makeSut() -> (sut: MainViewController, spy: MainViewModelSpy) {
        let spy = MainViewModelSpy()
        let sut = MainViewController(viewModel: spy)
        return (sut, spy)
    }
}
