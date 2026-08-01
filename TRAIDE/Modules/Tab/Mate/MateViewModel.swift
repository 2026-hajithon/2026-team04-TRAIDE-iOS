//
//  MateViewModel.swift
//  TRAIDE
//
//  Created by 김지우 on 8/1/26.
//

import Foundation
import Combine

@MainActor
final class MateViewModel: ObservableObject {
    @Published var mates: [Mate] = []
    @Published var requests: [MateRequest] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let mateService: MateServiceProtocol
    
    init(mateService: MateServiceProtocol? = nil) {
        self.mateService = mateService ?? MateService()
    }
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let mateResponse = mateService.fetchMates()
            async let requestResponse = mateService.fetchRequests()
            mates = try await mateResponse.map {
                Mate(
                    id: String($0.id),
                    nickname: $0.name,
                    teachingSport: $0.sport.name,
                    learningSport: $0.region.name,
                    age: nil,
                    district: $0.region.name,
                    imageURL: $0.imageUrl,
                    appointmentCount: $0.appointmentCount,
                    chatRoomID: $0.chatRoomId
                )
            }
            requests = try await requestResponse.map {
                MateRequest(
                    id: String($0.id),
                    mate: Mate(
                        id: String($0.user.id),
                        nickname: $0.user.name,
                        teachingSport: $0.user.sport.name,
                        learningSport: $0.user.level ?? $0.user.region?.name ?? "",
                        age: $0.user.age,
                        district: $0.user.region?.name,
                        imageURL: $0.user.imageUrl,
                        appointmentCount: 0,
                        chatRoomID: nil
                    )
                )
            }
            errorMessage = nil
        } catch {
            errorMessage = "메이트 정보를 불러오지 못했어요."
        }
    }

    func accept(_ request: MateRequest) async {
        guard let requestID = Int(request.id) else { return }
        do {
            try await mateService.acceptRequest(id: requestID)
            requests.removeAll { $0.id == request.id }
            if !mates.contains(request.mate) { mates.append(request.mate) }
        } catch {
            errorMessage = "요청을 수락하지 못했어요."
        }
    }

    func reject(_ request: MateRequest) async {
        guard let requestID = Int(request.id) else { return }
        do {
            try await mateService.rejectRequest(id: requestID)
            requests.removeAll { $0.id == request.id }
        } catch {
            errorMessage = "요청을 거절하지 못했어요."
        }
    }
}
