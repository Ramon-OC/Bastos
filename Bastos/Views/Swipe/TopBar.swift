//
//  TopBar.swift
//  Bastos
//
//  Created by José Ramón Ortiz Castañeda on 23/01/26.
//

import SwiftUI

struct TopBar: View {

    var deleteAssetsCount: Int
    var saveAssetsCount: Int
    var hideAssetsCount: Int

    var body: some View {
        HStack {
            
            Image("BNW-ICON")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)

            Spacer()

            // counters
            HStack {
                actionCounter(iconName: "trash.fill", count: deleteAssetsCount)
                actionCounter(iconName: "square.and.arrow.down.fill", count: saveAssetsCount)
                actionCounter(iconName: "eye.slash.fill", count: hideAssetsCount)
            }
            Spacer()

            Button(action: {
                
            }, label: {
                HStack{
                    Image(systemName: "gearshape.fill")
                        .font(.body)
                        .foregroundStyle(.white)
                }
                .padding(5)
                .glassEffect()
            })
            
        }
        .padding(30)
    }

    func actionCounter(iconName: String, count: Int) -> some View {
        HStack {
            Image(systemName: iconName)
                .font(.caption)
                .foregroundStyle(.white)
            Text("\(count)")
                .font(.caption)
                .foregroundStyle(.white)

        }
        .padding(5)
        .glassEffect(.clear)
    }
}
