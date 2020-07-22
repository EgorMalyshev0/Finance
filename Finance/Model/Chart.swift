import Foundation
import Charts

class Chart {
    
    enum Period {
        case week
        case month
        case quarter
        case all
    }
    
    var lineChartView: LineChartView = {
        let view = LineChartView()
        view.backgroundColor = .white
        view.rightAxis.enabled = false
        view.xAxis.labelPosition = .bottom
        return view
    }()
    
    func getEntries(days: [Date], transactions: [Transaction]) -> [ChartDataEntry] {
        let calendar = Calendar(identifier: .iso8601)
        var entry: [ChartDataEntry] = []
        for (i, day) in days.enumerated() {
            var sum: Double = 0
            for t in transactions{
                if calendar.dateComponents([.day, .month, .year], from: t.date) == calendar.dateComponents([.day, .month, .year], from: day){
                    sum += t.cost
                }
            }
            entry.append(ChartDataEntry(x: Double(i), y: sum))
        }
        return entry
    }
    
    func getData(period: Period, transactions: [Transaction]) -> [ChartDataEntry]{
        let date = Date()
        let calendar = Calendar(identifier: .iso8601)
        switch period {
        case .week:
            let weekNumber = calendar.component(.weekOfYear, from: date)
            let result = transactions.filter { weekNumber == calendar.component(.weekOfYear, from: $0.date)}
            let startOfWeek = date.startOfWeek
            let dates = calendar.range(of: .weekday, in: .weekOfYear, for: date)!
            let days = (dates.lowerBound ..< dates.upperBound).compactMap {calendar.date(byAdding: .day, value: $0 - 1, to: startOfWeek)}
            return getEntries(days: days, transactions: result)
        case .month:
            let monthNumber = calendar.component(.month, from: date)
            let result = transactions.filter { monthNumber == calendar.component(.month, from: $0.date)}
            let startOfMonth = date.startOfMonth
            let dates = calendar.range(of: .day, in: .month, for: date)!
            let days = (dates.lowerBound ..< dates.upperBound).compactMap {calendar.date(byAdding: .day, value: $0 - 1, to: startOfMonth)}
            return getEntries(days: days, transactions: result)
        case .quarter:
            let quarterNumber = calendar.component(.quarter, from: date)
            let result = transactions.filter { quarterNumber == calendar.component(.quarter, from: $0.date)}
            let startOfQuarter = date.startOfQuarter
            let dates = calendar.range(of: .day, in: .quarter, for: date)!
            let days = (dates.lowerBound ..< dates.upperBound).compactMap {calendar.date(byAdding: .day, value: $0 - 1, to: startOfQuarter)}
            return getEntries(days: days, transactions: result)
        case .all:
            guard transactions.count != 0 else {
                let result: [ChartDataEntry] = [ChartDataEntry(x: 0, y: 0)]
                return result
            }
            let sortedTransactions = transactions.sorted {$0.date < $1.date}
            let firstDate = sortedTransactions[0].date
            let q = calendar.dateComponents([.day], from: firstDate, to: date)
            var days: [Date] = []
            for i in 0...q.day! {
                days.append(calendar.date(byAdding: .day, value: i, to: firstDate)!)
            }
            return getEntries(days: days, transactions: sortedTransactions)
        }
    }
    
    func setData(expenseValues: [Transaction], incomeValues: [Transaction]?, period: Period){
        let set = LineChartDataSet(entries: getData(period: period, transactions: expenseValues), label: "расходы")
        set.circleRadius = 2
        set.setCircleColor(.black)
        if period == .quarter || period == .all {
            set.drawCirclesEnabled = false
        }
        set.lineWidth = 1
        set.setColor(.red)
        if let incomes = incomeValues {
            let incomesSet = LineChartDataSet(entries: getData(period: period, transactions: incomes), label: "доходы")
            incomesSet.circleRadius = 2
            incomesSet.setCircleColor(.black)
            if period == .quarter || period == .all {
                incomesSet.drawCirclesEnabled = false
            }
            incomesSet.lineWidth = 1
            incomesSet.setColor(.green)
            let data = LineChartData(dataSets: [set, incomesSet])
            data.setDrawValues(false)
            lineChartView.data = data
        } else {
            let data = LineChartData(dataSet: set)
            data.setDrawValues(false)
            lineChartView.data = data
        }
    }
    
    func showChart(fromTransactions: Bool, category: String, period: Period){
        if fromTransactions {
            let expenses = Persistance.shared.getTransactions(.Expense, category: category)
            setData(expenseValues: expenses, incomeValues: nil, period: period)
        } else {
            let expenses = Persistance.shared.getTransactions(.Expense, category: nil)
            let incomes = Persistance.shared.getTransactions(.Income, category: nil)
            setData(expenseValues: expenses, incomeValues: incomes, period: period)
        }
    }
}

extension Date {
    var startOfMonth: Date {
        let calendar = Calendar(identifier: .iso8601)
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }
    
    var startOfWeek: Date {
        let calendar = Calendar(identifier: .iso8601)
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)!
    }
    
    var startOfQuarter: Date {
        let calendar = Calendar(identifier: .iso8601)
        let components = calendar.dateComponents([.year, .quarter, .month], from: self)
        return calendar.date(from: components)!
    }
}
