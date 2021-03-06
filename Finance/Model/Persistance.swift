import Foundation
import RealmSwift
import Realm

enum TransactionType: String {
    case Income
    case Expense
}

class Transaction: Object {
    
    @objc dynamic var type: String = ""
    @objc dynamic var cost: Double = 0
    @objc dynamic var date: Date = Date()
    @objc dynamic var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: self.date)
    }
    @objc dynamic var category: String?
    @objc dynamic var name: String?
    convenience init(type: TransactionType, cost: Double, date: Date, category: String?, name: String?) {
        self.init()
        self.type = type.rawValue
        self.cost = cost
        self.date = date
        self.category = category
        self.name = name
    }
}

class Category: Object {
    @objc dynamic var category: String = ""
    convenience init(_ category: String) {
        self.init()
        self.category = category
    }
}

class Persistance {
    
    static let shared = Persistance()
    
    private let currentBalanceKey = "Persistance.currentBalanceKey"
    private let hasAlreadyLaunchedKey = "Persistance.hasAlreadyLaunched"

    var currentBalance: Double {
        set {UserDefaults.standard.set(newValue, forKey: currentBalanceKey)}
        get {UserDefaults.standard.double(forKey: currentBalanceKey)}
    }
    var hasAlreadyLaunched: Bool {
        set {UserDefaults.standard.set(newValue, forKey: hasAlreadyLaunchedKey)}
        get {UserDefaults.standard.bool(forKey: hasAlreadyLaunchedKey)}
    }
    
    private let realm = try! Realm()
    
    func addObject<T: Object>(object: T){
        try! realm.write {
            realm.add(object)
        }
    }
    
    func deleteObject<T: Object>(object: T){
        try! realm.write {
            realm.delete(object)
        }
    }

    func getTransactions(_ type: TransactionType, category: String?) -> [Transaction]{
        let objects = realm.objects(Transaction.self)
            .filter("type == '\(type.rawValue)'")
        if let category = category {
            let result = objects.filter("category == '\(category)'")
            return Array(result)
        }
        return Array(objects)
    }
    
    func getCategories() -> [Category]{
        let objects = realm.objects(Category.self)
        return Array(objects)
    }
    
    func updateBalance(label: UILabel) {
        label.text = "\(Persistance.shared.currentBalance) ₽"
    }
    
    func deletingCategory(_ category: Category){
        let transactionsToDelete = Persistance.shared.getTransactions(.Expense, category: category.category)
        for t in transactionsToDelete{
            Persistance.shared.currentBalance += t.cost
            Persistance.shared.deleteObject(object: t)
        }
        Persistance.shared.deleteObject(object: category)
    }
}
