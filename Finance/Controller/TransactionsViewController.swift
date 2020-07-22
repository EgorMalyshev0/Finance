import UIKit

class TransactionsViewController: UIViewController {

    var name: String = ""
    var transactions: [Transaction] = []
    
    @IBOutlet weak var transactionsTableview: UITableView!
    @IBOutlet weak var addTransactionButton: UIButton!
    @IBOutlet weak var transactionsGraphButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = name
        addTransactionButton.layer.cornerRadius = addTransactionButton.frame.size.height / 2
        transactionsGraphButton.layer.cornerRadius = transactionsGraphButton.frame.size.height / 2
        transactions = Persistance.shared.getTransactions(.Expense, category: name)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddingViewController, segue.identifier == "addExpense" {
            vc.delegate = self
            vc.segueType = .addExpense
        } else if let vc = segue.destination as? ChartsViewController, segue.identifier == "showExpensesChart" {
            vc.fromTransactions = true
            vc.category = name
        }
    }

}

extension TransactionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "incomes") as! IncomesTableViewCell
        cell.nameLabel.text = transactions[indexPath.row].name
        cell.dateLabel.text = transactions[indexPath.row].dateString
        cell.countLabel.text = "\(transactions[indexPath.row].cost) ₽"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        transactionsTableview.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let transaction = transactions[indexPath.row]
            Persistance.shared.currentBalance += transaction.cost
            transactions.remove(at: indexPath.row)
            Persistance.shared.deleteObject(object: transaction)
            transactionsTableview.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension TransactionsViewController: AddNewItemDelegate {
    func addNewItem(_ income: Double?, _ name: String?,_ date: Date?) {
        if let name = name, let income = income, let date = date {
            let newExpense = Transaction(type: .Expense, cost: income, date: date, category: self.name, name: name)
            transactions.append(newExpense)
            Persistance.shared.addObject(object: newExpense)
            transactionsTableview.reloadData()
            Persistance.shared.currentBalance -= income
        }
    }
}
