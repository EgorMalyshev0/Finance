import UIKit
import Bond
import ReactiveKit

protocol AddNewItemDelegate {
    func addNewItem(_ income: Double?,_ name: String?,_ date: Date?)
}

enum SegueType {
    case addIncome
    case addExpenseCategory
    case addExpense
}

class AddingViewController: UIViewController {
    
    var delegate: AddNewItemDelegate?
    
    var segueType: SegueType = .addIncome

    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var newIncomeTextfield: UITextField!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var addIncomeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var cancelView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let combination = combineLatest(newIncomeTextfield.reactive.text, nameTextfield.reactive.text) { [unowned self] (income, name) -> Bool in
            switch self.segueType {
            case .addIncome:
                return income?.count != 0
            case .addExpense:
                return income?.count != 0 && name?.count != 0
            case .addExpenseCategory:
                return name?.count != 0
            }
        }
        combination.bind(to: addIncomeButton.reactive.isEnabled)
        combination.map { $0 ? 1 : 0.5 }
            .bind(to: addIncomeButton.reactive.alpha)
        
        addIncomeButton.layer.cornerRadius = addIncomeButton.frame.size.height / 2
        cancelButton.layer.cornerRadius = addIncomeButton.frame.size.height / 2
        cancelView.layer.cornerRadius = addIncomeButton.frame.size.height / 2
        switch segueType {
        case .addIncome:
            nameTextfield.isHidden = true
            separatorView.isHidden = true
            addIncomeButton.setTitle("Добавить доход", for: .normal)
        case .addExpenseCategory:
            newIncomeTextfield.isHidden = true
            separatorView.isHidden = true
            datePicker.isHidden = true
            addIncomeButton.setTitle("Добавить категорию расходов", for: .normal)
        case .addExpense:
            addIncomeButton.setTitle("Добавить расход", for: .normal)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addIncome(_ sender: Any) {
            switch segueType {
            case .addIncome:
                if let text = newIncomeTextfield.text {
                    if let double = Double(text){
                        delegate?.addNewItem(double, nil, datePicker.date)
                        dismiss(animated: true, completion: nil)
                    }
                }
            case .addExpenseCategory:
                if let text = nameTextfield.text {
                    delegate?.addNewItem(nil, text, nil)
                    dismiss(animated: true, completion: nil)
                }
            case .addExpense:
                if let text = newIncomeTextfield.text, let text2 = nameTextfield.text {
                    if let double = Double(text){
                        delegate?.addNewItem(double, text2, datePicker.date)
                        dismiss(animated: true, completion: nil)
                    }
                }
            }
    }
}
