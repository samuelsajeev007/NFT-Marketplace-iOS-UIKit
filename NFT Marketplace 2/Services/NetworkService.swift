//
//  NetworkService.swift
//  NFT Marketplace 2
//
//  Created by Samuel Sajeev on 12/08/26.
//

import Foundation

// MARK: - NetworkError

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingFailed(Error)
    case serverError(statusCode: Int)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .noData:
            return "No data was received from the server."
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let code):
            if code == 409 {
                return "This NFT is not available for purchase (you may already own it)."
            }
            return "Server returned an error with status code \(code)."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - NetworkServiceProtocol

protocol NetworkServiceProtocol {
    func request<T: Decodable>(
        endpoint: NFTEndpoint,
        responseType: T.Type
    ) async throws -> T
}

// MARK: - NetworkService

final class NetworkService: NetworkServiceProtocol {

    private let session: URLSession
    private let decoder: JSONDecoder
    private let baseURL: String

    init(
        session: URLSession = .shared,
        baseURL: String = AppConstants.API.baseURL
    ) {
        self.session = session
        self.baseURL = baseURL
        self.decoder = JSONDecoder()
    }

    func request<T: Decodable>(
        endpoint: NFTEndpoint,
        responseType: T.Type
    ) async throws -> T {
        guard var components = URLComponents(string: baseURL + endpoint.path) else {
            throw NetworkError.invalidURL
        }

        if let queryItems = endpoint.queryItems {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url, timeoutInterval: AppConstants.API.timeoutInterval)
        urlRequest.httpMethod = endpoint.httpMethod
        urlRequest.setValue(AppConstants.API.apiKey, forHTTPHeaderField: "x-api-key")

        // Handle multipart form data for NFT upload
        if case let .uploadNFT(imageData, imageName, title, description, price, userid, email) = endpoint {
            let boundary = "Boundary-\(UUID().uuidString)"
            urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = createMultipartBody(
                boundary: boundary,
                imageData: imageData,
                imageName: imageName,
                title: title,
                description: description,
                price: price,
                userid: userid,
                email: email
            )
        }

        // Handle JSON body for purchase
        if case let .purchaseNFT(nftID, userId, email) = endpoint {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let parameters: [String: String] = [
                "email":   email,
                "userid":  userId,
                "nft_id":  nftID
            ]
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        }

        do {
            let (data, response) = try await session.data(for: urlRequest)

            if let httpResponse = response as? HTTPURLResponse,
               !(200..<300).contains(httpResponse.statusCode) {
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }

            if data.isEmpty {
                if T.self == EmptyResponse.self {
                    return EmptyResponse() as! T
                }
                throw NetworkError.noData
            }

            return try decoder.decode(T.self, from: data)

        } catch let error as NetworkError {
            throw error
        } catch let error as DecodingError {
            throw NetworkError.decodingFailed(error)
        } catch {
            throw NetworkError.unknown(error)
        }
    }

    // MARK: - Multipart Helpers

    private func createMultipartBody(
        boundary: String,
        imageData: Data,
        imageName: String,
        title: String,
        description: String,
        price: String,
        userid: String,
        email: String
    ) -> Data {
        var body = Data()
        let lineBreak = "\r\n"

        let parameters = [
            "title":          title,
            "description":    description,
            "selling_price":  price,
            "userid":         userid,
            "email":          email
        ]

        for (key, value) in parameters {
            body.append("--\(boundary)\(lineBreak)".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak)\(lineBreak)".data(using: .utf8)!)
            body.append("\(value)\(lineBreak)".data(using: .utf8)!)
        }

        body.append("--\(boundary)\(lineBreak)".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"Nft_image\"; filename=\"\(imageName)\"\(lineBreak)".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\(lineBreak)\(lineBreak)".data(using: .utf8)!)
        body.append(imageData)
        body.append(lineBreak.data(using: .utf8)!)
        body.append("--\(boundary)--\(lineBreak)".data(using: .utf8)!)

        return body
    }
}
