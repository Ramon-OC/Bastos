//
//  PhotoCardView.swift
//  Bastos
//
//  Created by José Ramón Ortiz Castañeda on 09/01/26.
//

import SwiftUI

struct PhotoCardView: View, Identifiable {
    let id = UUID()
    let viewModel: MediaDeckView.MediaDeckViewModel
    let media: Media
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 360, height: 500)
                    .cornerRadius(10)
                    .padding(15)
                    .overlay(alignment: .bottom) {
                        VStack {
                            Text(media.date)
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.bold)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 10)
                                .frame(width: 250, height: 30)
                        }
                        .padding([.bottom], 30)
                    }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 360, height: 500)
                    .cornerRadius(10)
                    .padding(15)
                    .overlay(
                        ProgressView()
                    )

            }
        }
        .onAppear {
            loadThumbnail()
        }
    }

    private func loadThumbnail() {
        let targetSize = CGSize(width: 720, height: 1000)

        viewModel.loadSingleUIImage(for: media, targetSize: targetSize) { loadedImage in
            self.image = loadedImage
        }
    }

}
