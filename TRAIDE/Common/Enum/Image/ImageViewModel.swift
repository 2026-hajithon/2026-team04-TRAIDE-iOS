//
//  ImageViewModel.swift
//  TRAIDE
//
//  Created by 김지우 on 8/2/26.
//

import Foundation
import Combine

@MainActor
final class ImageViewModel: ObservableObject {
    @Published var uploadedImageUrl: String?
    @Published var isLoading = false
    
    private let imageService: ImageServiceProtocol
    
    init(imageService: ImageServiceProtocol? = nil) {
        self.imageService = imageService ?? ImageService()
    }
    
    func upload(imageData: Data) async {
        isLoading = true
        do {
            let response = try await imageService.uploadImage(data: imageData)
            uploadedImageUrl = response.imageUrl
        } catch {
            print("이미지 업로드 실패: \(error)")
        }
        isLoading = false
    }
}
