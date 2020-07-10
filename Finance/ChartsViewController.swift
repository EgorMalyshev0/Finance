import UIKit
import Charts

class ChartsViewController: UIViewController {
    
    var fromTransactions: Bool = false
    var allExpenseTransactions: [Transaction] = []
    var allIncomeTransactions: [Transaction]? = nil
    var chart = Chart()

    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var chartSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chart.lineChartView.frame = CGRect(x: 0, y: 0, width: chartView.frame.width, height: chartView.frame.height)
        chartView.addSubview(chart.lineChartView)
        if fromTransactions {
            chart.setData(expenseValues: allExpenseTransactions, incomeValues: nil, period: .week)
        } else{
            allIncomeTransactions = Persistance.shared.getTransactions(.Income, category: nil)
            allExpenseTransactions = Persistance.shared.getTransactions(.Expense, category: nil)
            chart.setData(expenseValues: allExpenseTransactions, incomeValues: allIncomeTransactions, period: .week)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if !fromTransactions {
            allIncomeTransactions = Persistance.shared.getTransactions(.Income, category: nil)
            allExpenseTransactions = Persistance.shared.getTransactions(.Expense, category: nil)
            chart.setData(expenseValues: allExpenseTransactions, incomeValues: allIncomeTransactions, period: .week)
        }
    }

    @IBAction func indexChanged(_ sender: Any) {
        switch chartSegmentedControl.selectedSegmentIndex {
            case 0:
                chart.setData(expenseValues: allExpenseTransactions, incomeValues: allIncomeTransactions, period: .week)
            case 1:
                chart.setData(expenseValues: allExpenseTransactions, incomeValues: allIncomeTransactions, period: .month)
            case 2:
                chart.setData(expenseValues: allExpenseTransactions, incomeValues: allIncomeTransactions, period: .quarter)
            case 3:
                chart.setData(expenseValues: allExpenseTransactions, incomeValues: allIncomeTransactions, period: .all)
            default:
                break
        }
    }
}
