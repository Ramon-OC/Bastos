//
//  UpcomingBarView.swift
//  Bastos
//
//  Created by José Ramón Ortiz Castañeda on 10/01/26.
//

import SwiftUI

struct UpcomingBarView: View {

    let viewModel: MediaDeckView.MediaDeckViewModel

    @Binding var media: [Media]
    @State private var images: [UIImage?] = []

    var body: some View {
        VStack(alignment: .leading) {
//            Text("Próximas Imágenes en la Pila")
//                .font(.subheadline)
//                .bold()
//                .frame(maxWidth: .infinity)

            HStack(alignment: .center) {
                ForEach(0..<images.count, id: \.self) { index in
                    if let image = images[index] {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 70, height: 70)
                            .cornerRadius(5)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 70, height: 70)
                            .cornerRadius(5)
                            .overlay(
                                ProgressView()
                            )
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: 70)
        }
        .onAppear {
            viewModel.loadMultipleUIImages(for: media, targetSize: CGSize(width: 70, height: 70)) { loadedMedia in
                images = loadedMedia
            }
        }
        .onChange(of: media) {
            viewModel.loadMultipleUIImages(for: media, targetSize: CGSize(width: 70, height: 70)) { loadedMedia in
                images = loadedMedia
            }
        }

    }
}
