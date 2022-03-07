//
//  MPMediaService.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/03.
//

import MediaPlayer

class MPMediaService {
    private static var isAuth: Bool {
        return MPMediaLibrary.authorizationStatus() == .authorized
    }
    
    static func getAlbums(artistPersistentID: MPMediaEntityPersistentID) -> [MPMediaItem] {
        if !isAuth { return [] }
        let query = MPMediaQuery.albums()
        query.groupingType = .artist
        let predicate = MPMediaPropertyPredicate(value: artistPersistentID, forProperty: MPMediaItemPropertyArtistPersistentID, comparisonType: .equalTo)
        query.addFilterPredicate(predicate)
        
        // remove depulicated
        let results = query.items ?? []
        let uniqueResults = results.reduce([MPMediaItem]()) { partialResult, other in
            if partialResult.contains(where: { item in
                return item.albumPersistentID == other.albumPersistentID
            }) {
                return partialResult
            }
            return  partialResult + [other]
        }
        
        // sort
        let sorted = uniqueResults.sorted { item1, item2 in
            return item1.year ?? 0 < item2.year ?? 0
        }
        return sorted
    }
    
    static func getAlbumCount(artistPersistentID: MPMediaEntityPersistentID) -> Int {
        return getAlbums(artistPersistentID: artistPersistentID).count
    }
    
    static func getSongs(albumPersistentID: MPMediaEntityPersistentID) -> [MPMediaItem] {
        if !isAuth { return [] }
        let predicate: MPMediaPropertyPredicate = .init(value: albumPersistentID, forProperty: MPMediaItemPropertyAlbumPersistentID, comparisonType: .equalTo)
        return MPMediaQuery(filterPredicates: [predicate]).items ?? []
    }
    
    static func getSongs(artistPersistentID: MPMediaEntityPersistentID) -> [MPMediaItem] {
        if !isAuth { return [] }
        let predicate: MPMediaPropertyPredicate = .init(value: artistPersistentID, forProperty: MPMediaItemPropertyArtistPersistentID, comparisonType: .equalTo)
        return MPMediaQuery(filterPredicates: [predicate]).items ?? []
    }
    
    static func getAllSongs() -> [MPMediaItem] {
        if !isAuth { return [] }
        return MPMediaQuery.songs().items ?? []
    }
}
