import Foundation

enum APIError: LocalizedError {
    case invalidResponse
    case badStatus(Int, String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Некоректна відповідь сервера"
        case .badStatus(let code, let body):
            return "Сервер повернув \(code): \(body)"
        }
    }
}

/// Клієнт до бекенду AI Sport Assistant.
final class APIClient {
    static let shared = APIClient()
    private let session = URLSession.shared

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        return e
    }()

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    // MARK: - Публічне API

    /// Надіслати історію чату асистенту, отримати відповідь.
    func chat(messages: [ChatMessage]) async throws -> String {
        let body = ChatRequest(messages: messages, userId: APIConfig.userID)
        let resp: ChatResponse = try await send("chat", method: "POST", json: body)
        return resp.reply
    }

    /// Синхронізувати тренування на бекенд.
    @discardableResult
    func syncWorkouts(_ workouts: [WorkoutDTO]) async throws -> SyncResult {
        try await send("sync/workouts", method: "POST",
                       query: ["user_id": APIConfig.userID], json: workouts)
    }

    /// Прочитати профіль користувача.
    func profile() async throws -> Profile {
        try await send("profile", method: "GET", query: ["user_id": APIConfig.userID])
    }

    /// Оновити профіль (часткове).
    @discardableResult
    func updateProfile(_ profile: Profile) async throws -> Profile {
        try await send("profile", method: "PUT",
                       query: ["user_id": APIConfig.userID], json: profile)
    }

    /// Аналіз страви по фото → калорії та БЖВ.
    func analyzeFood(imageData: Data, fileName: String = "meal.jpg",
                     mimeType: String = "image/jpeg") async throws -> FoodAnalysis {
        let boundary = "Boundary-\(UUID().uuidString)"
        var req = makeRequest("vision", method: "POST")
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"photo\"; filename=\"\(fileName)\"\r\n")
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(imageData)
        data.appendString("\r\n--\(boundary)--\r\n")
        req.httpBody = data

        return try await perform(req)
    }

    // MARK: - Внутрішнє

    private func makeRequest(_ path: String, method: String,
                             query: [String: String] = [:]) -> URLRequest {
        var components = URLComponents(
            url: APIConfig.baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )!
        if !query.isEmpty {
            components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        var req = URLRequest(url: components.url!)
        req.httpMethod = method
        return req
    }

    private func send<Body: Encodable, T: Decodable>(
        _ path: String, method: String, query: [String: String] = [:], json: Body
    ) async throws -> T {
        var req = makeRequest(path, method: method, query: query)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try encoder.encode(json)
        return try await perform(req)
    }

    private func send<T: Decodable>(
        _ path: String, method: String, query: [String: String] = [:]
    ) async throws -> T {
        let req = makeRequest(path, method: method, query: query)
        return try await perform(req)
    }

    private func perform<T: Decodable>(_ req: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.badStatus(http.statusCode, String(data: data, encoding: .utf8) ?? "")
        }
        return try decoder.decode(T.self, from: data)
    }
}

private extension Data {
    mutating func appendString(_ string: String) {
        if let d = string.data(using: .utf8) { append(d) }
    }
}
