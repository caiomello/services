//
//  DataStack.swift
//  DataStack
//
//  Created by Caio Mello on August 17, 2017.
//  Copyright © 2017 Caio Mello. All rights reserved.
//

import Foundation
import CoreData

public final class DataStack {
	private let modelName: String
	
	public init(modelName: String) {
		self.modelName = modelName
	}
	
	private lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: self.modelName)
		
		container.loadPersistentStores(completionHandler: { (description, error) in
			if let error = error {
				print("Error loading persistent store: \(error)")
			}
		})
		
		return container
	}()
	
	private(set) lazy var mainContext: NSManagedObjectContext = {
		self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
		self.persistentContainer.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
		return self.persistentContainer.viewContext
	}()
	
	public func performBackgroundTask(block: @escaping (NSManagedObjectContext) -> Void) {
		persistentContainer.performBackgroundTask { (context) in
			context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
			block(context)
		}
	}
	
	public func save(_ context: NSManagedObjectContext) {
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				print("Error saving to persistent store: \(error)")
			}
		}
	}
}