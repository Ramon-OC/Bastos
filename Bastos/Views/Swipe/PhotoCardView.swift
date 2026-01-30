//
//  PhotoCardView.swift
//  Bastos
//
//  Created by José Ramón Ortiz Castañeda on 09/01/26.
//

//import SwiftUI
//
//struct PhotoCardView: View, Identifiable {
//    let id = UUID()
//    let viewModel: MediaDeckView.MediaDeckViewModel
//    let media: Media
//    @State private var image: UIImage?
//
//    var body: some View {
//        Group {
//            if let image = image {
//                Image(uiImage: image)
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 360, height: 500)
//                    .cornerRadius(10)
//                    .padding(15)
//                    .overlay(alignment: .bottomLeading) {
//                            Text(media.date)
//                                .foregroundColor(.white)
//                                .font(.headline)
//                                .background(
//                                    Color.black.opacity(0.4)
//                                        .blur(radius: 0)
//                                )
//                                .padding(30)
//                    }
//                    .overlay(alignment: .topTrailing){
//                        Button(action: {
//                            
//                        }, label: {
//                            Image(systemName: "arrow.down.left.and.arrow.up.right")
//                                .frame(width: 40, height: 40)
//                                .font(.system(size: 20))
//                                .foregroundStyle(.white)
//                                .glassEffect(.clear)
//                                .padding(30)
//                        })
//                    }
//
//            } else {
//                Rectangle()
//                    .fill(Color.gray.opacity(0.3))
//                    .frame(width: 360, height: 500)
//                    .cornerRadius(10)
//                    .padding(15)
//                    .overlay(
//                        ProgressView()
//                    )
//
//            }
//        }
//        .onAppear {
//            loadThumbnail()
//        }
//    }
//
//    private func loadThumbnail() {
//        let targetSize = CGSize(width: 720, height: 1000)
//
//        viewModel.loadSingleUIImage(for: media, targetSize: targetSize) { loadedImage in
//            self.image = loadedImage
//        }
//    }
//
//}


import SwiftUI

struct PhotoCardView: View, Identifiable {
    let id = UUID()
    let viewModel: MediaDeckView.MediaDeckViewModel
    let media: Media
    @State private var image: UIImage?
    @State private var isExpanded = false

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 360, height: 500)
                    .cornerRadius(10)
                    .padding(15)
                    .overlay(alignment: .bottomLeading) {
                        Text(media.date)
                            .foregroundColor(.white)
                            .font(.headline)
                            .background(
                                Color.black.opacity(0.4)
                                    .blur(radius: 0)
                            )
                            .padding(30)
                    }
                    .overlay(alignment: .topTrailing){
                        Button(action: {
                            isExpanded = true
                        }, label: {
                            Image(systemName: "arrow.down.left.and.arrow.up.right")
                                .frame(width: 40, height: 40)
                                .font(.system(size: 20))
                                .foregroundStyle(.white)
                                .glassEffect(.clear)
                                .padding(30)
                        })
                    }
                    .fullScreenCover(isPresented: $isExpanded) {
                        ExpandedImageView(image: image, media: media, isPresented: $isExpanded)
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

struct ExpandedImageView: View {
    let image: UIImage
    let media: Media
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
//            Color.black.ignoresSafeArea()
            
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 360) // Mantiene el ancho de 360
            }
        
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.white)
                            .padding()
                    }
                }
                Spacer()
            }
            
            VStack {
                Spacer()
                HStack {
                    Text(media.date)
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                        .padding()
                    Spacer()
                }
            }
        }
    }
}
