import UIKit

protocol IncomeDelegate {
    func addNewIncome(_ income: Double?,_ name: String?,_ date: Date?)
}

enum SegueType {
    case addIncome
    case addExpenseCategory
    case addExpense
}

class AddIncomeViewController: UIViewController {
    
    var delegate: IncomeDelegate?
    
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
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func addIncome(_ sender: Any) {
            switch segueType {
            case .addIncome:
                if let text = newIncomeTextfield.text {
                    if let double = Double(text){
                        delegate?.addNewIncome(double, nil, datePicker.date)
                        dismiss(animated: true, completion: nil)
                    }
                }
            case .addExpenseCategory:
                if let text = nameTextfield.text {
                    delegate?.addNewIncome(nil, text, nil)
                    dismiss(animated: true, completion: nil)
                }
            case .addExpense:
                if let text = newIncomeTextfield.text, let text2 = nameTextfield.text {
                    if let double = Double(text){
                        delegate?.addNewIncome(double, text2, datePicker.date)
                        dismiss(animated: true, completion: nil)
                    }
                }
            }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true, completion: nil)
    }
}
