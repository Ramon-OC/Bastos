//
//  BottomBar.swift
//  Bastos
//
//  Created by José Ramón Ortiz Castañeda on 09/01/26.
//

import SwiftUI

struct BottomBar: View {

    @Binding var remainMessage: String

    var body: some View {
        HStack {

            Button {
                // undo action
            }label: {
                Image(systemName: "arrow.trianglehead.counterclockwise.rotate.90")
                    .frame(width: 60, height: 60)
                    .font(.system(size: 25))
                    .foregroundStyle(.secondary)
                    .glassEffect()
            }

            Text(remainMessage)
                .font(.system(.subheadline, design: .rounded))
            .bold()
                .foregroundColor(.white)
                .padding(.horizontal, 35)
                .padding(.vertical, 15)
                .background(.black)
                .cornerRadius(10)
                .padding(.horizontal, 20)

            Button {
                // undo action
            }label: {
                Image(systemName: "tray.and.arrow.down.fill")
                    .frame(width: 60, height: 60)
                    .font(.system(size: 25))
                    .foregroundStyle(.secondary)
                    .glassEffect()
            }
        }

    }
}

struct BottomBar_Previews: PreviewProvider {
    @State static var previewRemain: String = "01 de 1,200"

    static var previews: some View {
        BottomBar(remainMessage: $previewRemain)
    }
}
