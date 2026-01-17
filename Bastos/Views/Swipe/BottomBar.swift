//
//  BottomBar.swift
//  Bastos
//
//  Created by José Ramón Ortiz Castañeda on 09/01/26.
//

import SwiftUI

struct BottomBar: View {

    @Binding var centerButtonMessage: String
    let rightButton: () -> Void
    let leftButton: () -> Void
    let centerButton: () -> Void

    var body: some View {
        HStack {

            Button {
                rightButton()
            }label: {
                Image(systemName: "arrow.trianglehead.counterclockwise.rotate.90")
                    .frame(width: 60, height: 60)
                    .font(.system(size: 25))
                    .foregroundStyle(.secondary)
                    .glassEffect()
            }

            Button {
                centerButton()
            }label: {
                Text(centerButtonMessage)
                    .font(.title)
                    .padding()
                    .glassEffect(.regular)
            }

            Button {
                leftButton()
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
