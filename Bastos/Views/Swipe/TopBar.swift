//
//  TopBar.swift
//  Bastos
//
//  Created by José Ramón Ortiz Castañeda on 23/01/26.
//

import SwiftUI

struct TopBar: View {

    @State var showConfirmationAlert: Bool = false
    let viewModel: MediaDeckView.MediaDeckViewModel

    var body: some View {
        HStack {
            Image("BNW-ICON")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)

            Button {
                // action
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .glassEffect(.clear)
            }

        }
        .frame(height: 60)
    }
}
