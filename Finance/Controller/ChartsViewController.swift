import UIKit
import Charts

class ChartsViewController: UIViewController {
    
    var fromTransactions: Bool = false
    var category = ""
    var chart = Chart()

    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var chartSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chart.lineChartView.frame = CGRect(x: 0, y: 0, width: chartView.frame.width, height: chartView.frame.height)
        chartView.addSubview(chart.lineChartView)
        chart.showChart(fromTransactions: fromTransactions, category: category, period: .week)
    }
    override func viewWillAppear(_ animated: Bool) {
        if !fromTransactions {
            let expenses = Persistance.shared.getTransactions(.Expense, category: nil)
            let incomes = Persistance.shared.getTransactions(.Income, category: nil)
            chart.setData(expenseValues: expenses, incomeValues: incomes, period: .week)
        }
    }

    @IBAction func indexChanged(_ sender: Any) {
        switch chartSegmentedControl.selectedSegmentIndex {
            case 0:
                chart.showChart(fromTransactions: fromTransactions, category: category, period: .week)
            case 1:
                chart.showChart(fromTransactions: fromTransactions, category: category, period: .month)
            case 2:
                chart.showChart(fromTransactions: fromTransactions, category: category, period: .quarter)
            case 3:
                chart.showChart(fromTransactions: fromTransactions, category: category, period: .all)
            default:
                break
        }
    }
}
