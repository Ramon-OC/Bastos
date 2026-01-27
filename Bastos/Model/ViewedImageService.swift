//
//  ViewedImageService.swift
//  Bastos
//
//  Created by José Ramón Ortiz Castañeda on 16/01/26.
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
        for asset in assets {
            markAssetAsViewed(asset: asset)
        }
    }

}
