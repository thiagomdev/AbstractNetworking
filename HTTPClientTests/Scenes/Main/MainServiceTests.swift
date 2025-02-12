import XCTest
@testable import HTTPClient

final class MainServiceTests: XCTestCase {
    func test_init_does_not_request_data_from_URL() {
        let  (_, client) = makeSut()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_fetch_data_requests_from_URL() {
        let expectedURL = URLRequest(url: URL(string: "https://api.themoviedb.org/3/discover/movie")!)
        let  (sut, client) = makeSut(expectedURL)
        
        sut.fetchData { _ in }
        
        XCTAssertEqual(client.requestedURLs.first?.url, expectedURL.url ?? .applicationDirectory)
    }
    
    func test_fetch_data_error_on_client_error() {
        let  (sut, client) = makeSut()
        let expectedError: NSError = .init(domain: "some_error", code: -999)
        
        expect(sut, toCompleteWith: failure(expectedError), when: {
            client.complete(with: expectedError)
        })
    }
    
    func test_load_delivers_error_on_Non_200_HTTPResponse() {
        let  (sut, client) = makeSut()
        let samples = [199, 201, 300, 400, 500].enumerated()
        
        samples.forEach { index, code in
            expect(sut, toCompleteWith: failure(unnexpectedError), when: {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }
    
    func test_load_delivers_error_on_200HTTPResponse_with_invalidJSON() {
        let  (sut, client) = makeSut()
        
        expect(sut, toCompleteWith: failure(unnexpectedError), when: {
            let invalidJSON: Data = .init(_: "invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_delivers_no_items_on_200HTTPResponse_with_empty_json_list() {
        let  (sut, client) = makeSut()
        
        expect(sut, toCompleteWith: failure(unnexpectedError), when: {
            client.complete(withStatusCode: 200)
        })
    }
    
    func test_load_does_not_deliver_result_after_SUT_instance_has_been_deallocated() {
        let client = HTTPClientSpy()
        var sut: MainService? = MainService(client: client)
        
        var capturedResults = [MainServiceResult]()
        sut?.fetchData { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        
        XCTAssertFalse(capturedResults.isEmpty)
    }
}
// MARK: - SUT
extension MainServiceTests {
    private func makeSut(
        _ request: URLRequest = .init(url: URL(string: "https://a-url.com")!)
    ) -> (sut: MainService, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = MainService(client: client)
        return (sut, client)
    }
}
// MARK: - HELPERS
extension MainServiceTests {
    private func expect(_ sut: MainService, toCompleteWith expectedResult: MainServiceResult,
        when execute: () -> Void,
        file: StaticString = #file,
        line: UInt = #line) {
        
        let exp = expectation(description: "Wai for load completion")
        
        sut.fetchData { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedIError as NSError), .failure(expectedIError as NSError)):
                XCTAssertEqual(receivedIError, expectedIError, file: file, line: line)
            default:
                XCTFail("Expected result \(receivedResult) got \(expectedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        execute()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failure(_ error: Error) -> MainServiceResult {
        return .failure(error)
    }
    
    private var unnexpectedError: UnnexpectedError {
        return .unowned
    }
    
    private func makeItemsJSON(_ values: [[String: Any]]) -> Data {
        let json = ["values": values]
        return try! JSONSerialization.data(withJSONObject: json)
    }
}
