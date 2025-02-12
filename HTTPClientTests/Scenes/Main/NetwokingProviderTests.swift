import XCTest
@testable import HTTPClient

final class NetwokingProviderTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_get_fromURL_perfoms_GET_requests_with_URL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for completion block")
        
        URLProtocolStub.observerRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSut().execute(URLRequest(url: url)) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_get_from_URL_fails_on_request_error() {
        let requestError = anyError()
        
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)
        
        XCTAssertNotNil(receivedError)
    }
    
    func test_get_from_URL_fails_on_all_invalid_representations_cases() {
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPResponse(), error: anyError()))
    }
    
    func test_get_from_URL_success_on_HTTPResponse_with_data() {
        let data = anyData()
        let response = anyHTTPResponse()

        let receivedValues = resultValuesFor(data: data, response: response, error: nil)
        
        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    
    func test_get_from_URL_success_with_empty_data_on_HTTPResponse_with_nil_data() {
        let response = anyHTTPResponse()
        let receivedValues = resultValuesFor(data: nil, response: response, error: nil)
        
        let emptyData = Data()
        
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
}

extension NetwokingProviderTests {
    // MARK: - Helpers
    private func makeSut(file: StaticString = #file, line: UInt = #line) -> HTTPClientProtocol {
        let sut = NetwokingProvider()
        trackForMemoryLeaks(for: sut, file: file, line: line)
        return sut
    }
    
    private func resultErrorFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #file,
        line: UInt = #line) -> Error? {
            
            let result = resultFor(
                data: data,
                response: response,
                error: error,
                file: file,
                line: line
            )
            
            switch result {
            case let .failure(error):
                return error
            default:
                XCTFail("Expected failure, got \(String(describing: result)) instead.", file: file, line: line)
                return nil
            }
        }
    
    private func resultValuesFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #file,
        line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
            let result = resultFor(data: data, response: response, error: error)
            switch result {
            case let .success(data, response):
                return (data, response)
            default:
                XCTFail("Expected success, got \(String(describing: result)) instead.", file: file, line: line)
                return nil
            }
        }
    
    private func resultFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #file,
        line: UInt = #line) -> HTTPClientResult? {
            
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let exp = expectation(description: "Wait for completion block")
        let sut = makeSut(file: file, line: line)
            
        var receivedResult: HTTPClientResult?
            sut.execute(URLRequest(url: anyURL())) { result in
            receivedResult = result
            exp.fulfill()
        }
            
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com") ?? .applicationDirectory
    }
    
    private func anyData() -> Data {
        return Data(_: "any data".utf8)
    }
    
    private func nonHTTPResponse() -> URLResponse {
        return URLResponse(
            url: anyURL(),
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
    }
    
    private func anyHTTPResponse() -> HTTPURLResponse {
        return  HTTPURLResponse(
            url: anyURL(),
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
    }
    
    private func anyError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
    
    private func trackForMemoryLeaks(for
        instance: AnyObject,
        file: StaticString = #file,
        line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(
                instance,
                "Instance should have been deallocated. Potential memory leak."
            )
        }
    }
}


