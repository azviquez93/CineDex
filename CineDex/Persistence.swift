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
    container.loadPersistentStores(completionHandler: { _, error in
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
        if let directorsInfo = movieInfo.directors {
          for directorInfo in directorsInfo {
            let director = createOrFindDirector(from: directorInfo, in: viewContext)
            let movieDirector = MovieDirector(context: viewContext)
            movieDirector.director = director
            movieDirector.movie = movie
            director.addToMovies(movieDirector)
          }
        }
        if let starsInfo = movieInfo.stars {
          for starInfo in starsInfo {
            let star = createOrFindStar(from: starInfo, in: viewContext)
            let movieStar = MovieStar(context: viewContext)
            movieStar.star = star
            movieStar.movie = movie
            star.addToMovies(movieStar)
          }
        }
        
        if let genresInfo = movieInfo.genres {
          for genreInfo in genresInfo {
            let genre = createOrFindGenre(from: genreInfo, in: viewContext)
            let movieDirector = MovieGenre(context: viewContext)
            movieDirector.genre = genre
            movieDirector.movie = movie
            genre.addToMovies(movieDirector)
          }
        }
        
        if let writersInfo = movieInfo.writers {
          for writerInfo in writersInfo {
            let writer = createOrFindWriter(from: writerInfo, in: viewContext)
            let movieWriter = MovieWriter(context: viewContext)
            movieWriter.writer = writer
            movieWriter.movie = movie
            writer.addToMovies(movieWriter)
          }
        }
        
        if let contentRatingInfo = movieInfo.contentRating {
          let contentRating = createOrFindContentRating(from: contentRatingInfo, in: viewContext)
          let movieContentRating = MovieContentRating(context: viewContext)
          movieContentRating.contentRating = contentRating
          movieContentRating.movie = movie
          contentRating.addToMovies(movieContentRating)
        }
        
        if let studioInfo = movieInfo.studio {
          let studio = createOrFindStudio(from: studioInfo, in: viewContext)
          let movieStudio = MovieStudio(context: viewContext)
          movieStudio.studio = studio
          movieStudio.movie = movie
          studio.addToMovies(movieStudio)
        }
        
        if let countriesInfo = movieInfo.countries {
          for countryInfo in countriesInfo {
            let country = createOrFindCountry(from: countryInfo, in: viewContext)
            let movieCountry = MovieCountry(context: viewContext)
            movieCountry.country = country
            movieCountry.movie = movie
            country.addToMovies(movieCountry)
          }
        }
        
        if let movieImdbInfo = movieInfo.imdb {
          let imdb = Imdb(context: viewContext)
          imdb.siteId = movieImdbInfo.siteId
          imdb.siteRatingCount = movieImdbInfo.siteRatingCount ?? 0
          imdb.siteRatingValue = movieImdbInfo.siteRatingValue ?? 0
          imdb.movie = movie
          movie.imdb = imdb
        }
        
        if let movieRottentomatoesInfo = movieInfo.rottentomatoes {
          let rottentomatoes = Rottentomatoes(context: viewContext)
          rottentomatoes.siteId = movieRottentomatoesInfo.siteId
          rottentomatoes.siteRatingCount = movieRottentomatoesInfo.siteRatingCount ?? 0
          rottentomatoes.siteRatingValue = movieRottentomatoesInfo.siteRatingValue ?? 0
          rottentomatoes.userRatingCount = movieRottentomatoesInfo.userRatingCount ?? 0
          rottentomatoes.userRatingValue = movieRottentomatoesInfo.userRatingValue ?? 0
          rottentomatoes.movie = movie
          movie.rottentomatoes = rottentomatoes
        }
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
  
  private func createOrFindDirector(from directorInfo: DirectorInfo, in context: NSManagedObjectContext) -> Director {
    let personName = directorInfo.name
    
    // Check if the director already exists
    let existingDirectorFetchRequest: NSFetchRequest<Director> = Director.fetchRequest()
    existingDirectorFetchRequest.predicate = NSPredicate(format: "person.name == %@", personName)
    
    do {
      let existingDirectors = try context.fetch(existingDirectorFetchRequest)
      
      if let existingDirector = existingDirectors.first {
        return existingDirector // Director already exists, return it
      }
    } catch {
      print("Error fetching existing directors: \(error)")
    }
    
    // If the director does not exist, create a new one
    let newDirector = Director(context: context)
    newDirector.person = createOrFindPerson(from: directorInfo.name, in: context)
    
    return newDirector
  }
  
  private func createOrFindWriter(from writerInfo: WriterInfo, in context: NSManagedObjectContext) -> Writer {
    let personName = writerInfo.name
    
    // Check if the writer already exists
    let existingWriterFetchRequest: NSFetchRequest<Writer> = Writer.fetchRequest()
    existingWriterFetchRequest.predicate = NSPredicate(format: "person.name == %@", personName)
    
    do {
      let existingWriters = try context.fetch(existingWriterFetchRequest)
      
      if let existingWriter = existingWriters.first {
        return existingWriter // Writer already exists, return it
      }
    } catch {
      print("Error fetching existing writers: \(error)")
    }
    
    // If the writer does not exist, create a new one
    let newWriter = Writer(context: context)
    newWriter.person = createOrFindPerson(from: writerInfo.name, in: context)
    
    return newWriter
  }
  
  private func createOrFindStar(from starInfo: StarInfo, in context: NSManagedObjectContext) -> Star {
    let personName = starInfo.name
    
    // Check if the star already exists
    let existingStarFetchRequest: NSFetchRequest<Star> = Star.fetchRequest()
    existingStarFetchRequest.predicate = NSPredicate(format: "person.name == %@", personName)
    
    do {
      let existingStars = try context.fetch(existingStarFetchRequest)
      
      if let existingStar = existingStars.first {
        return existingStar // Star already exists, return it
      }
    } catch {
      print("Error fetching existing stars: \(error)")
    }
    
    // If the star does not exist, create a new one
    let newStar = Star(context: context)
    
    newStar.person = createOrFindPerson(from: starInfo.name, in: context)
    
    return newStar
  }
  
  private func createOrFindGenre(from genreInfo: GenreInfo, in context: NSManagedObjectContext) -> Genre {
    let existingGenresFetchRequest: NSFetchRequest<Genre> = Genre.fetchRequest()
    existingGenresFetchRequest.predicate = NSPredicate(format: "name == %@", genreInfo.name)
    
    do {
      let existingGenres = try context.fetch(existingGenresFetchRequest)
      
      if let existingGenre = existingGenres.first {
        return existingGenre // Genre already exists, return it
      }
    } catch {
      print("Error fetching existing genres: \(error)")
    }
    
    let newGenre = Genre(context: context)
    
    newGenre.name = genreInfo.name
    
    return newGenre
  }
  
  private func createOrFindCountry(from countryInfo: CountryInfo, in context: NSManagedObjectContext) -> Country {
    let existingCountriesFetchRequest: NSFetchRequest<Country> = Country.fetchRequest()
    existingCountriesFetchRequest.predicate = NSPredicate(format: "name == %@", countryInfo.name)
    
    do {
      let existingCountries = try context.fetch(existingCountriesFetchRequest)
      
      if let existingCountry = existingCountries.first {
        return existingCountry // Country already exists, return it
      }
    } catch {
      print("Error fetching existing countries: \(error)")
    }
    
    let newCountry = Country(context: context)
    
    newCountry.name = countryInfo.name
    
    return newCountry
  }
  
  private func createOrFindPerson(from name: String, in context: NSManagedObjectContext) -> Person {
    let existingPersonFetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
    existingPersonFetchRequest.predicate = NSPredicate(format: "name == %@", name)
    
    do {
      let existingPeople = try context.fetch(existingPersonFetchRequest)
      
      if let existingPerson = existingPeople.first {
        return existingPerson // Person already exists, return it
      }
    } catch {
      print("Error fetching existing directors: \(error)")
    }
    
    let newPerson = Person(context: context)
    
    newPerson.name = name
    
    return newPerson
  }
  
  private func createOrFindContentRating(from contentRatingInfo: ContentRatingInfo, in context: NSManagedObjectContext) -> ContentRating {
    let existingContentRatingsFetchRequest: NSFetchRequest<ContentRating> = ContentRating.fetchRequest()
    existingContentRatingsFetchRequest.predicate = NSPredicate(format: "name == %@", contentRatingInfo.name)
    
    do {
      let existingContentRatings = try context.fetch(existingContentRatingsFetchRequest)
      
      if let existingContentRating = existingContentRatings.first {
        return existingContentRating
      }
    } catch {
      print("Error fetching existing content ratings: \(error)")
    }
    
    let newContentRating = ContentRating(context: context)
    
    newContentRating.name = contentRatingInfo.name
    
    return newContentRating
  }
  
  private func createOrFindStudio(from studioInfo: StudioInfo, in context: NSManagedObjectContext) -> Studio {
    let existingStudioFetchRequest: NSFetchRequest<Studio> = Studio.fetchRequest()
    existingStudioFetchRequest.predicate = NSPredicate(format: "name == %@", studioInfo.name)
    
    do {
      let existingStudios = try context.fetch(existingStudioFetchRequest)
      
      if let existingStudio = existingStudios.first {
        return existingStudio
      }
    } catch {
      print("Error fetching existing studios: \(error)")
    }
    
    let newStudio = Studio(context: context)
    
    newStudio.name = studioInfo.name
    
    return newStudio
  }
  
  // Helper functions to create Metadata and Specification entities
  private func createMetadata(from metadataInfo: MetadataInfo, in context: NSManagedObjectContext) -> Metadata {
    let metadata = Metadata(context: context)
    metadata.id = metadataInfo.id
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
    specification.file = specificationInfo.file
    specification.width = Int16(specificationInfo.width ?? 0)
    specification.height = Int16(specificationInfo.height ?? 0)
    specification.size = Int64(specificationInfo.size ?? 0)
    specification.duration = Int32(specificationInfo.duration ?? 0)
    specification.bitrate = Int32(specificationInfo.bitrate ?? 0)
    specification.container = specificationInfo.container
    specification.videoCodec = specificationInfo.videoCodec
    specification.audioCodec = specificationInfo.audioCodec
    specification.framesPerSecond = specificationInfo.framesPerSecond ?? 0.0
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
