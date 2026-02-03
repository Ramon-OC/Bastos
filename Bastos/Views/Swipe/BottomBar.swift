//
//  BottomBar.swift
//  Bastos
//
//  Created by José Ramón Ortiz Castañeda on 09/01/26.
//

import SwiftUI

struct BottomBar: View {

    @State var showConfirmationAlert: Bool = false
    let viewModel: MediaDeckView.MediaDeckViewModel

    var body: some View {
        HStack {

            Button {
                viewModel.leftButtonPressed()
            }label: {
                Image(systemName: "arrow.trianglehead.counterclockwise.rotate.90")
                    .frame(width: 50, height: 50)
                    .font(.system(size: 25))
                    .foregroundStyle(.white)
                    .glassEffect(.clear)
            }

            Button {
                viewModel.centerButtonPressed()
            }label: {
                Text(viewModel.remainMessage)
                    .frame(width: 180, height: 50)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .glassEffect(.clear)
            }
            .disabled(viewModel.centerButtonIsDisabled())

            Button {
                showConfirmationAlert = true
            }label: {
                Image(systemName: "eye.slash.fill")
                    .frame(width: 50, height: 50)
                    .font(.system(size: 25))
                    .foregroundStyle(.white)
                    .glassEffect(.clear)
            }
            .alert(String(localized: .doYouWantToHideThisImage), isPresented: $showConfirmationAlert) {
                Button(String(localized: .cancel), role: .cancel) {
                    return
                }
                Button(String(localized: .hide), role: .destructive) {
                    viewModel.right01ButtonPressed()
                }
            } message: {
                Text(String(localized: .atTheEndYouWillConfirmAgainAllTheImagesThatWillBeHidden))
            }

            Button {
                Task {
                        await viewModel.right02ButtonPressed()
                    }
            }label: {
                Image(systemName: viewModel.isCurrentAssetFavorite() ? "heart.fill" : "heart")
                    .frame(width: 50, height: 50)
                    .font(.system(size: 25))
                    .foregroundStyle(viewModel.isCurrentAssetFavorite() ? .red: .white)
                    .glassEffect(.clear)
            }
        }
    }
}
