import UIKit

class IncomesViewController: UIViewController {
    
    var incomes: [Transaction] = []

    @IBOutlet weak var incomesTableView: UITableView!
    @IBOutlet weak var currentBalanceLabel: UILabel!
    @IBOutlet weak var addIncomeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addIncomeButton.layer.cornerRadius = addIncomeButton.frame.size.height / 2
        currentBalanceLabel.text = "\(Persistance.shared.currentBalance) ₽"
        incomes = Persistance.shared.getTransactions(.Income, category: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        currentBalanceLabel.text = "\(Persistance.shared.currentBalance) ₽"
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddIncomeViewController, segue.identifier == "addIncome" {
            vc.delegate = self
            vc.segueType = .addIncome
        }
    }
    @IBAction func addIncome(_ sender: Any) {
        performSegue(withIdentifier: "addIncome", sender: UIButton.self)
    }
    
}

extension IncomesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        incomes.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "incomes") as! IncomesTableViewCell
        cell.countLabel.text = "\(incomes[indexPath.row].cost) ₽"
        cell.dateLabel.text = incomes[indexPath.row].dateString
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        incomesTableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let income = incomes[indexPath.row]
            Persistance.shared.currentBalance -= income.cost
            incomes.remove(at: indexPath.row)
            Persistance.shared.deleteObject(object: income)
            incomesTableView.deleteRows(at: [indexPath], with: .fade)
            currentBalanceLabel.text = "\(Persistance.shared.currentBalance) ₽"
        }
    }
}

extension IncomesViewController: IncomeDelegate{
    func addNewIncome(_ income: Double?, _ name: String?,_ date: Date?) {
        if let income = income, let date = date {
            let newIncome = Transaction(type: TransactionType.Income, cost: income, date: date, category: nil, name: nil)
            incomes.append(newIncome)
            Persistance.shared.addObject(object: newIncome)
            incomesTableView.reloadData()
            Persistance.shared.currentBalance += income
            currentBalanceLabel.text = "\(Persistance.shared.currentBalance) ₽"
        }
    }
}
