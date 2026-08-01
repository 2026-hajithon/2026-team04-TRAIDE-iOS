import Foundation

protocol ImageServiceProtocol {
    func uploadImage(data: Data) async throws -> ImageUploadResponse
}

final class ImageService: ImageServiceProtocol {
    private let baseURL = URL(string: "https://api.traide.com")!
    
    func uploadImage(data: Data) async throws -> ImageUploadResponse {
        let route = ImageRouter.upload(imageData: data)
        let (responseData, _) = try await URLSession.shared.data(for: route.asURLRequest(baseURL: baseURL))
        return try JSONDecoder().decode(ImageUploadResponse.self, from: responseData)
    }
}
