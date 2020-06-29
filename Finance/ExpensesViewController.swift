import UIKit

class ExpensesViewController: UIViewController {

    var expensesCategories: [Category] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var expensesTableView: UITableView!
    @IBOutlet weak var currentBalanceLabel: UILabel!
    @IBOutlet weak var addexpensesCategoryButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !appDelegate.hasAlreadyLaunched {
            appDelegate.sethasAlreadyLaunched()
            addFirstCategories()
            print("This is first start")
        }
        addexpensesCategoryButton.layer.cornerRadius = addexpensesCategoryButton.frame.size.height / 2
        currentBalanceLabel.text = "\(Persistance.shared.currentBalance) ₽"
        expensesCategories = Persistance.shared.getCategories()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        currentBalanceLabel.text = "\(Persistance.shared.currentBalance) ₽"
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func addFirstCategories(){
        let firstStartCategories = [Category("Дом"), Category("Продукты"), Category("Досуг"), Category("Постоянные траты"), Category("Путешествия")]
        for category in firstStartCategories {
            expensesCategories.append(category)
            Persistance.shared.addObject(object: category)
            expensesTableView.reloadData()
        }
    }
    
    @IBAction func addExpenseCategory(_ sender: Any) {
        performSegue(withIdentifier: "addExpenseCategory", sender: Any?.self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddIncomeViewController, segue.identifier == "addExpenseCategory" {
            vc.delegate = self
            vc.segueType = .addExpenseCategory
        } else if let cell = sender as? UITableViewCell, let index = expensesTableView.indexPath(for: cell), let vc = segue.destination as? TransactionsViewController, segue.identifier == "showExpensesFromCategory" {
            vc.name = expensesCategories[index.row].category
        }
    }
    
}

extension ExpensesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        expensesCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "expensesCategory") as! ExpencesTableViewCell
        cell.categoryNameLabel.text = expensesCategories[indexPath.row].category
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        expensesTableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showExpensesFromCategory", sender: tableView.cellForRow(at: indexPath))
    }
    
}

extension ExpensesViewController: IncomeDelegate{
    func addNewIncome(_ income: Double?, _ name: String?) {
        if let category = name {
            let newCategory = Category(category)
            expensesCategories.append(newCategory)
            Persistance.shared.addObject(object: newCategory)
            expensesTableView.reloadData()
        }
    }
}
