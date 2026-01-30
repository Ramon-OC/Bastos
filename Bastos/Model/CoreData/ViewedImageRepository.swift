//
//  ViewedImageRepository.swift
//  Bastos
//
//  Created by José Ramón Ortiz Castañeda on 28/01/26.
//
import CoreData

final class ViewedImageRepository: ViewedImageRepositoryProtocol {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchReadAssetIDs() -> Set<String> {
        let request = NSFetchRequest<NSDictionary>(entityName: "ViewedImage")
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = ["imageId"]
        request.returnsDistinctResults = true

        do {
            let results = try context.fetch(request)
            let ids = results.compactMap { $0["imageId"] as? String }
            print("Se leyeron en el repo \(ids.count) assets")
            return Set(ids)
        } catch {
            print("An error with CoreData has ocurred:", error)
            return []
        }
    }

    func markAssetAsViewed(asset: Media) {
        let viewed = ViewedImage(context: context)
        viewed.imageId = asset.id
        try? context.save()
    }

    func markMultipleAssetsAsViewed(assets: [Media]) {
        print("se quieren guardar \(assets.count)")
        let now = Date()

        for asset in assets {
            let viewed = ViewedImage(context: context)
            viewed.imageId = asset.id
            viewed.viewedAt = now
        }

        do {
            try context.save()
            print("Guardados correctamente")
        } catch {
            print("Error de guardando:", error)
        }
    }

}
