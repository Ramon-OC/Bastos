//
//  MediaDeckView.swift
//  Bastos
//
//  Created by José Ramón Ortiz Castañeda on 09/01/26.
//

import SwiftUI
import CoreData

struct MediaDeckView: View {

    @Environment(\.managedObjectContext) private var context

    @GestureState private var dragState = DragState.inactive
    @State private var viewModel: MediaDeckViewModel
    @State private var dismissingCardId: String? // ID de la carta que se está descartando
    @State private var dismissOffset: CGSize = .zero // Offset de descarte

    init() {
         // Inicialización temporal
         let tempContext = PersistenceController.shared.container.viewContext
         let repository = ViewedImageRepository(context: tempContext)
         _viewModel = State(wrappedValue: MediaDeckViewModel(repository: repository))
     }

    var body: some View {
        ZStack {

            Background(viewModel: viewModel)
                .ignoresSafeArea()

            VStack {

                Image("BNW-ICON")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)

                UpcomingBarView(viewModel: viewModel, media: $viewModel.upcomingMedia)

                ZStack {
                    ForEach(viewModel.deckMedia) { media in
                        PhotoCardView(viewModel: viewModel, media: media)
                            .zIndex(viewModel.isTopCard(media) ? 1 : 0)
                            .overlay {
                                ZStack {
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 100))
                                        .opacity(self.dragState.translation.width < (-viewModel.dragThreshold)
                                                 && viewModel.isTopCard(media)
                                                 ? 1.0 : 0)

                                    Image(systemName: "square.and.arrow.down.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 100))
                                        .opacity(self.dragState.translation.width > (viewModel.dragThreshold)
                                                 && viewModel.isTopCard(media)
                                                 ? 1.0 : 0.0)
                                }
                            }
                            .offset(
                                x: dismissingCardId == media.id ? dismissOffset.width : (viewModel.isTopCard(media) ? self.dragState.translation.width : 0),
                                y: dismissingCardId == media.id ? dismissOffset.height : (viewModel.isTopCard(media) ? self.dragState.translation.height : 0)
                            )
                            .scaleEffect(self.dragState.isDragging && viewModel.isTopCard(media) ? 0.90 : 1.0)
                            .rotationEffect(Angle(degrees: viewModel.isTopCard(media)
                                                  ? Double(self.dragState.translation.width / 10) : 0))
                            .animation(.interpolatingSpring(stiffness: 180, damping: 100),
                                       value: self.dragState.translation)
                            .animation(.easeInOut(duration: 0.3), value: dismissOffset)
                            .opacity(dismissingCardId == media.id ? 0 : 1)
                            .animation(.easeInOut(duration: 0.3), value: dismissingCardId)

                            .gesture(LongPressGesture(minimumDuration: 0.01)
                                .sequenced(before: DragGesture())
                                .updating(self.$dragState, body: { (value, state, _) in
                                    switch value {
                                    case .first(true):
                                        state = .pressing
                                    case .second(true, let drag):
                                        state = .dragging(translation: drag?.translation ?? .zero)
                                    default:
                                        break
                                    }

                                })
                                    .onChanged({ (value) in
                                        guard case .second(true, let drag?) = value else {
                                            return
                                        }

                                        if drag.translation.width < -viewModel.dragThreshold {
                                            viewModel.removalTransition = .leadingBottom
                                        }

                                        if drag.translation.width > viewModel.dragThreshold {
                                            viewModel.removalTransition = .trailingBottom
                                        }

                                    })
                                        .onEnded({ (value) in

                                            guard case .second(true, let drag?) = value else {
                                                return
                                            }

                                            if drag.translation.width < -viewModel.dragThreshold {
                                                // Animar hacia la esquina inferior izquierda
                                                dismissingCardId = media.id
                                                dismissOffset = CGSize(width: -400, height: 600)

                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                    viewModel.leftCardSwipe(media: media)
                                                    dismissingCardId = nil
                                                    dismissOffset = .zero
                                                }
                                            } else if drag.translation.width > viewModel.dragThreshold {
                                                // Animar hacia la esquina inferior derecha
                                                dismissingCardId = media.id
                                                dismissOffset = CGSize(width: 400, height: 600)

                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                    viewModel.rightCardSwipe(media: media)
                                                    dismissingCardId = nil
                                                    dismissOffset = .zero
                                                }
                                            }
                                        })
                            )
                    }

                }

                BottomBar(viewModel: viewModel)

            }
        }
    }

}
