//
//  DataController.swift
//  UltimatePorfolio
//
//  Created by Aleksey on 2/18/23.
//

import CoreData

class DataController: ObservableObject {
	
	let container: NSPersistentCloudKitContainer
	
	// for previewing only, not saving on disk
	static var preview: DataController {
		let dataController = DataController(inMemory: true)
		dataController.createSampleData()
		return dataController
	}
	
	// inMemory - provide a path to store nowhere (old facion unix way)
	init(inMemory: Bool = false) {
		container = NSPersistentCloudKitContainer(name: "Main")
		
		if inMemory {
			container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
		}
		
		container.loadPersistentStores { storeDescription, error in
			if let error {
				fatalError("Fatal error loading store: \(error.localizedDescription)")
			}
		}
	}
	
	
	func createSampleData() {
		let viewContext = container.viewContext
		
		for i in 1...5 {
			let tag = Tag(context: viewContext)
			tag.id = UUID()
			tag.name = "Tag \(i)"
			
			for j in 1...10 {
				let issue  = Issue(context: viewContext)
				issue.title = "Issue \(j)"
				issue.content = "Description goes here"
				issue.creationDate = Date.now
				issue.completed = Bool.random()
				issue.priority = Int16.random(in: 0...2)
//				tag.addToIssues(issue) // ???
				
			}
		}
		
		try? viewContext.save()
	}
	
	
	func save() {
		if container.viewContext.hasChanges {
			try? container.viewContext.save()
		}
	}
	
	
	func delete(_ object: NSManagedObject) {
		container.viewContext.delete(object)
		save()
	}
	
	
	// helper func to remove all data
	private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
		let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
		batchDeleteRequest.resultType = .resultTypeObjectIDs
		
		if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
			let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
			NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
		}
	}
	
	
	func deleteAll() {
		let tagsRemoveRequest: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
		delete(tagsRemoveRequest)
		
		let issuesRemoveRequest: NSFetchRequest<NSFetchRequestResult> = Issue.fetchRequest()
		delete(issuesRemoveRequest)
		
		save()
	}
}
