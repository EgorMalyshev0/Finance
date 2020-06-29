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
    
    @IBAction func showExpensesChart(_ sender: Any) {
//        performSegue(withIdentifier: "showExpensesChart", sender: Any?.self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddIncomeViewController, segue.identifier == "addExpense" {
            vc.delegate = self
            vc.segueType = .addExpense
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
        cell.dateLabel.text = transactions[indexPath.row].date
        cell.countLabel.text = "\(transactions[indexPath.row].cost) ₽"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        transactionsTableview.deselectRow(at: indexPath, animated: true)
    }
    
}

extension TransactionsViewController: IncomeDelegate {
    func addNewIncome(_ income: Double?, _ name: String?) {
        if let name = name, let income = income {
            let currentDate = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            let dateString = formatter.string(from: currentDate)
            let newExpense = Transaction(type: .Expense, cost: income, date: dateString, category: self.name, name: name)
            transactions.append(newExpense)
            Persistance.shared.addObject(object: newExpense)
            transactionsTableview.reloadData()
            Persistance.shared.currentBalance -= income
        }
    }
}
