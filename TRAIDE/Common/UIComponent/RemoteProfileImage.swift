//
//  RemoteProfileImage.swift
//  TRAIDE
//

import SwiftUI

/// Renders the server-provided sport profile image URL without client-side sport mapping.
struct RemoteProfileImage: View {
    let imageUrl: String?
    let size: CGFloat

    var body: some View {
        Group {
            if let imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var placeholder: some View {
        Circle()
            .fill(Color(._200))
    }
}
