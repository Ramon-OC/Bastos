//
//  MediaDeckView.swift
//  Bastos
//
//  Created by José Ramón Ortiz Castañeda on 09/01/26.
//

import SwiftUI

struct MediaDeckView: View {

    @GestureState private var dragState = DragState.inactive
    @State private var viewModel = ViewModel()

    var body: some View {
        VStack {
            Image("app_logo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)

            Spacer(minLength: 10)

            UpcomingBarView(viewModel: viewModel, media: $viewModel.showingUpcomingMedia)

            ZStack {
                ForEach(viewModel.showingMedia) { media in
                    PhotoCardView(viewModel: viewModel, media: media)
                        .zIndex(viewModel.isTopCard(media) ? 1 : 0)
                        .overlay {
                            ZStack {
                                Image(systemName: "trash.circle")
                                    .foregroundColor(.white)
                                    .font(.system(size: 100))
                                    .opacity(self.dragState.translation.width < (-viewModel.dragThreshold)
                                             && viewModel.isTopCard(media)
                                             ? 1.0 : 0)

                                Image(systemName: "heart.circle")
                                    .foregroundColor(.white)
                                    .font(.system(size: 100))
                                    .opacity(self.dragState.translation.width > (viewModel.dragThreshold)
                                             && viewModel.isTopCard(media)
                                             ? 1.0 : 0.0)
                            }
                        }
                        .offset(x: viewModel.isTopCard(media) ? self.dragState.translation.width : 0,
                                y: viewModel.isTopCard(media) ? self.dragState.translation.height : 0)
                        .scaleEffect(self.dragState.isDragging && viewModel.isTopCard(media) ? 0.90 : 1.0)
                        .rotationEffect(Angle(degrees: viewModel.isTopCard(media)
                                              ? Double( self.dragState.translation.width / 10) : 0))
                        .animation(.interpolatingSpring(stiffness: 180, damping: 100),
                                   value: self.dragState.translation)
                        .transition(viewModel.removalTransition)

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
                                            viewModel.leftCardSwipe(asset: media.asset)
                                        } else if drag.translation.width > viewModel.dragThreshold {
                                            viewModel.rightCardSwipe(asset: media.asset)
                                        }
                                    })
                        )
                }
            }

            BottomBar(centerButtonMessage: $viewModel.remainMessage,
                      rightButton: viewModel.rightButtonPressed,
                      leftButton: viewModel.leftButtonPressed,
                      centerButton: viewModel.centerButtonPressed)

            Spacer(minLength: 10)
        }
    }

}
