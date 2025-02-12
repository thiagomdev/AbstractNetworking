import Foundation
@testable import HTTPClient

extension DataModel {
    static func fixture() -> Self {
        .init(page: 0, results: [], totalPages: 0, totalResults: 0)
    }
}
