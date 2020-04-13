import Foundation

class Item: Identifiable, ObservableObject {
	let uuid: UUID
	private(set) var name: String
	weak var store: Store?
	weak var parent: Folder? {
		didSet {
			store = parent?.store
		}
	}
    
    var id: UUID { uuid }
    
	init(name: String, uuid: UUID) {
		self.name = name
		self.uuid = uuid
		self.store = nil
	}
	
	func setName(_ newName: String) {
        objectWillChange.send()
		name = newName
		if let p = parent {
			let (oldIndex, newIndex) = p.reSort(changedItem: self)
			store?.save(self, userInfo: [Item.changeReasonKey: Item.renamed, Item.oldValueKey: oldIndex, Item.newValueKey: newIndex, Item.parentFolderKey: p])
		}
	}
	
	func deleted() {
        objectWillChange.send()
		parent = nil
	}
	
	var uuidPath: [UUID] {
		var path = parent?.uuidPath ?? []
		path.append(uuid)
		return path
	}
	
	func item(atUUIDPath path: ArraySlice<UUID>) -> Item? {
		guard let first = path.first, first == uuid else { return nil }
		return self
	}
}

extension Item {
	static let changeReasonKey = "reason"
	static let newValueKey = "newValue"
	static let oldValueKey = "oldValue"
	static let parentFolderKey = "parentFolder"
	static let renamed = "renamed"
	static let added = "added"
	static let removed = "removed"
}

