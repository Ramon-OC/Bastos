//
//  SettingsSheetView.swift
//  Bastos
//
//  Created by José Ramón Ortiz Castañeda on 03/02/26.
//

import SwiftUI
import StoreKit

enum SettingsAction {
    case review
    case contact
    case privacy
    case terms
}

struct SettingsItem: Identifiable {
    let id = UUID()
    let title: String
    let leftIcon: String
    let rightIcon: String
    let action: SettingsAction
}


struct SettingsSheetView: View {
    @Environment(\.dismiss) private var dismiss

    @Bindable var viewModel: MediaDeckView.MediaDeckViewModel
    
    let aboutItems: [SettingsItem] = [
        SettingsItem(title: String(localized: .review), leftIcon: "heart", rightIcon: "arrow.up.forward", action: .review),
        SettingsItem(title: String(localized: .contactMe), leftIcon: "envelope", rightIcon: "arrow.up.forward", action: .contact),
        SettingsItem(title: String(localized: .privacyPolicy), leftIcon: "lock", rightIcon: "arrow.up.forward", action: .privacy),
        SettingsItem(title: String(localized: .termsService), leftIcon: "text.document", rightIcon: "arrow.up.forward", action: .terms)
    ]

    var body: some View {
        VStack{
            
            HStack(alignment: .lastTextBaseline){
                Text("Bastos")
                    .font(.title2)
                    .bold()
                Text("V.1.0")
                    .font(.caption2)
                    .foregroundStyle(.gray)
                Spacer()
                
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: "xmark")
                        .frame(width: 20, height: 20)
                        .font(.system(size: 10))
                        .foregroundStyle(.primary)
                        .glassEffect(.clear)
                        .glassEffect()
                })
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text(String(localized: .sortTitle))
                    .font(.headline)
                
                Text(String(localized: .sortIntruction))
                    .font(.caption)
                
                Picker("MediaSortType", selection: $viewModel.selectedSort) {
                    ForEach(MediaSort.allCases) { sortType in
                        Text(sortType.title)
                            .tag(sortType)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            VStack(alignment: .leading, spacing: 10){
                Text(String(localized: .about))
                    .font(.headline)

                List(aboutItems) { item in
                    Button {
                        handleAction(item.action)
                    }label: {
                        HStack {
                            Image(systemName: item.leftIcon)
                                .foregroundColor(.primary)

                            Text(item.title)
                                .font(.caption)
                                .foregroundColor(.primary)

                            Spacer()
                            
                            Image(systemName: item.rightIcon)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    func handleAction(_ action: SettingsAction) {
        switch action {
        case .review:
            if let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {

                AppStore.requestReview(in: scene)
            }

        case .contact:
            sendEmail()

        case .privacy:
            openURL("https://tusitio.com/privacy")

        case .terms:
            openURL("https://tusitio.com/terms")
        }
    }
    
    private func openURL(_ string: String) {
        guard let url = URL(string: string) else { return }
        UIApplication.shared.open(url)
    }
    
    private func sendEmail() {
        let email = "bastos-support@ramooon.com"
        let subject = "Soporte"
        let body = "Hola, necesito ayuda con la app"

        let mailto = "mailto:\(email)?subject=\(subject)&body=\(body)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        if let url = URL(string: mailto) {
            UIApplication.shared.open(url)
        }
    }
    
}


//
//#Preview {
//    SettingsSheetView(
//        selectedMediaSort: .constant(.dateAscending)
//    )
//}
