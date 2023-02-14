//
//  FilesManager.swift
//  SmartShoppingModule
//
//  Created by Lenad on 30.01.2023.
//

import Foundation

class FilesManager {
    static let shared = FilesManager()
    
    enum Error: Swift.Error {
        case fileAlreadyExists
        case fileNotExists
        case invalidDirectory
        case readingFailed
        case writtingFailed
    }
    
    let fileManager: FileManager
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    func save(fileNamed: String, data: Data) throws {
        guard let url = makeURL(forFileNamed: fileNamed) else {
            throw Error.invalidDirectory
        }
        if fileManager.fileExists(atPath: url.absoluteString) {
            throw Error.fileAlreadyExists
        }
        do {
            try data.write(to: url)
        } catch {
            debugPrint(error)
            throw Error.writtingFailed
        }
    }
    
    private func makeURL(forFileNamed fileName: String) -> URL? {
        guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return url.appendingPathComponent(fileName)
    }
    
    func read(fileNamed: String) throws -> Data {
        guard let url = makeURL(forFileNamed: fileNamed) else {
            throw Error.invalidDirectory
        }
        do {
            return try Data(contentsOf: url)
        } catch {
            debugPrint(error)
            throw Error.readingFailed
        }
    }
    
}
