//
//  FilesManager.swift
//  SmartShoppingModule
//
//  Created by Lenad on 30.01.2023.
//

import Foundation

/**
 A singleton manager class that provides methods for saving and reading files to/from the device's document directory.
 
 - Note: The manager instance can be accessed through the shared property.
 
 - Warning: The file names should be unique to avoid overwriting files.
 
 - Throws: Errors of type `FilesManager.Error` if any operation fails.
 
 */
class FilesManager {
    /// The default file manager instance.
    let fileManager: FileManager
    
    /// The shared instance of the `FilesManager` class.
    static let shared = FilesManager()
    
    enum Error: Swift.Error {
        case fileAlreadyExists
        case fileNotExists
        case invalidDirectory
        case readingFailed
        case writtingFailed
    }
    
    /**
     Writes the data to a file with the given name in the document directory.
     
     - Parameters:
     - fileNamed: The name of the file to save.
     - data: The data to be written to the file.
     
     - Throws: An error of type `FilesManager.Error` if the file already exists or the write operation fails.
     */
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
    
    /**
     Returns the data of the file with the given name from the document directory.
     
     - Parameters:
     - fileNamed: The name of the file to read.
     
     - Returns: The data of the file.
     
     - Throws: An error of type `FilesManager.Error` if the file does not exist or the read operation fails.
     */
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
    
    /**
     Returns a URL with the given file name in the document directory.
     
     - Parameters:
     - fileName: The name of the file.
     
     - Returns: The URL with the given file name.
     
     - Note: The URL is `nil` if the file name is not valid.
     */
    private func makeURL(forFileNamed fileName: String) -> URL? {
        guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return url.appendingPathComponent(fileName)
    }
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
}

