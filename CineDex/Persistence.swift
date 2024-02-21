//
//  Persistence.swift
//  CineDex
//
//  Created by Andrés Zamora on 20/2/24.
//

import CoreData

struct PersistenceController {
  static let shared = PersistenceController()
  
  static var preview: PersistenceController = {
    let result = PersistenceController(inMemory: true)
    let viewContext = result.container.viewContext
    return result
  }()
  
  let container: NSPersistentContainer
  
  init(inMemory: Bool = false) {
    container = NSPersistentContainer(name: "CineDex")
    if inMemory {
      container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
    }
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        
        /*
         Typical reasons for an error here include:
         * The parent directory does not exist, cannot be created, or disallows writing.
         * The persistent store is not accessible, due to permissions or data protection when the device is locked.
         * The device is out of space.
         * The store could not be migrated to the current model version.
         Check the error message to determine what the actual problem was.
         */
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    container.viewContext.automaticallyMergesChangesFromParent = true
  }
  
  func batchInsertMovies(_ movieInfoArray: [MovieInfo], completion: @escaping () -> Void) {
    let viewContext = container.viewContext
    
    viewContext.perform {
      for movieInfo in movieInfoArray {
        let movie = Movie(context: viewContext)
        movie.id = movieInfo.id
        movie.createdAt = movieInfo.createdAt
        movie.updatedAt = movieInfo.updatedAt
        
        // Set up relationships for Metadata and Specification
        movie.metadata = createMetadata(from: movieInfo.metadata, in: viewContext)
        movie.specification = createSpecification(from: movieInfo.specification, in: viewContext)
      }
      
      do {
        try viewContext.save()
        completion()
      } catch {
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
      }
    }
  }
  
  // Helper functions to create Metadata and Specification entities
  private func createMetadata(from metadataInfo: MetadataInfo, in context: NSManagedObjectContext) -> Metadata {
    let metadata = Metadata(context: context)
    metadata.id = metadataInfo.id
    metadata.createdAt = metadataInfo.createdAt
    metadata.updatedAt = metadataInfo.updatedAt
    metadata.alternativeTitle = metadataInfo.alternativeTitle
    metadata.originalTitle = metadataInfo.originalTitle
    metadata.artwork = metadataInfo.artwork
    metadata.summary = metadataInfo.summary
    metadata.duration = Int32(metadataInfo.duration ?? 0)
    metadata.year = Int16(metadataInfo.year ?? 0)
    metadata.addedAt = metadataInfo.addedAt
    
    return metadata
  }
  
  private func createSpecification(from specificationInfo: SpecificationInfo, in context: NSManagedObjectContext) -> Specification {
    let specification = Specification(context: context)
    specification.id = specificationInfo.id
    specification.createdAt = specificationInfo.createdAt
    specification.updatedAt = specificationInfo.updatedAt
    specification.file = specificationInfo.file
    specification.width = Int16(specificationInfo.width ?? 0)
    specification.height = Int16(specificationInfo.height ?? 0)
    specification.size = Int64(specificationInfo.size ?? 0)
    specification.duration = Int32(specificationInfo.duration ?? 0)
    specification.bitrate = Int32(specificationInfo.bitrate ?? 0)
    specification.container = specificationInfo.container
    specification.videoCodec = specificationInfo.videoCodec
    specification.audioCodec = specificationInfo.audioCodec
    specification.framesPerSecond = specificationInfo.framesPerSecond
    specification.audioChannels = Int16(specificationInfo.audioChannels ?? 0)
    
    return specification
  }
  
  func resetCoreData() {
    let context = container.viewContext
    let entities = container.managedObjectModel.entities
    
    for entity in entities {
      if let entityName = entity.name {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
          try context.execute(deleteRequest)
          try context.save()
        } catch {
          print("Error deleting all data: \(error)")
        }
      }
    }
  }
  
  
}
