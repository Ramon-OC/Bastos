//
//  BottomBar.swift
//  Bastos
//
//  Created by José Ramón Ortiz Castañeda on 09/01/26.
//

import SwiftUI

struct BottomBar: View {

    let viewModel: MediaDeckView.MediaDeckViewModel

    var body: some View {
        HStack {

            Button {
                viewModel.leftButtonPressed()
            }label: {
                Image(systemName: "arrow.trianglehead.counterclockwise.rotate.90")
                    .frame(width: 60, height: 60)
                    .font(.system(size: 25))
                    .foregroundStyle(.secondary)
                    .glassEffect()
            }

            Button {
                viewModel.centerButtonPressed()
            }label: {
                Text(viewModel.remainMessage)
                    .frame(width: 150, height: 40)
                    .font(.subheadline)
                    .padding()
                    .glassEffect(.regular)
            }
            .disabled(viewModel.centerButtonIsDisabled())

            Button {
                viewModel.rightButtonPressed()
            }label: {
                Image(systemName: "eye.slash.fill")
                    .frame(width: 60, height: 60)
                    .font(.system(size: 25))
                    .foregroundStyle(.secondary)
                    .glassEffect()
            }
        }

    }
}
