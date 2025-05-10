import Foundation

enum APIError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case invalidData
    case decodingError
    case unauthorized
    case rateLimited
    case serverError(statusCode: Int? = nil)
    case networkError
    case maxRetriesExceeded
} 