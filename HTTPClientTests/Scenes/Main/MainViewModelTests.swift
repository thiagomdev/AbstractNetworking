import XCTest
@testable import HTTPClient

final class MainViewModelTests: XCTestCase {
    func test_display_data_when_retuned_success() {
        let (sut, spy) = makeSut()
        var expectedDataModel: DataModel?
        let exp = expectation(description: "Wait for a completion block")
        
        spy.expectedResult = .success(.fixture())
        
        sut.displayData { result in
            if case let .success(dataModel) = result {
                expectedDataModel = dataModel
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertTrue(spy.fetchDataCalled)
        XCTAssertEqual(spy.fetchDataCount, 1)
        XCTAssertNotNil(expectedDataModel)
    }
    
    func test_() {
        let (sut, spy) = makeSut()
        var expectedError: NSError = .init(domain: "Test", code: -999)
        let exp = expectation(description: "Wait for a completion block")
        
        spy.expectedResult = .failure(expectedError)
        
        sut.displayData { result in
            if case let .failure(receivedError as NSError) = result {
                expectedError = receivedError
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertTrue(spy.fetchDataCalled)
        XCTAssertEqual(spy.fetchDataCount, 1)
        XCTAssertNotNil(expectedError)
    }
}

final class MainServiceSpy: MainServicing {
    private(set) var fetchDataCalled: Bool = false
    private(set) var fetchDataCount: Int = 0
    
    var expectedResult: ((MainServiceResult))?
    
    func fetchData(onComplete: @escaping (MainServiceResult) -> Void) {
        fetchDataCalled = true
        fetchDataCount += 1
        if let expectedResult {
            onComplete(expectedResult)
        }
    }
}

extension MainViewModelTests {
    private func makeSut() -> (sut:  MainViewModel, spy: MainServiceSpy) {
        let spy = MainServiceSpy()
        let sut = MainViewModel(service: spy)
        return (sut, spy)
    }
}
