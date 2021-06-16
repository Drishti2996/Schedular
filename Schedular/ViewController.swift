//
//  ViewController.swift
//  Schedular
//
//  Created by Local User on 29/05/21.
//  Copyright © 2021 Local User. All rights reserved.
//

import UIKit

class MeetingScheduleViewController: UIViewController {
    var data = [DatabaseModel(startTime: "11:00", endTime: "12:00"), DatabaseModel(startTime: "13:00", endTime: "14:00")]
    
    private lazy var meetingDate: TextFieldWithPadding = {
        let textField = TextFieldWithPadding()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 1
        textField.rightViewMode = .always
        textField.isEnabled = false
        return textField
    }()
    
    private lazy var startTime: TextFieldWithPadding = {
        let textField = TextFieldWithPadding()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 1
        textField.rightViewMode = .always
        return textField
    }()
    
    private lazy var endTime: TextFieldWithPadding = {
        let textField = TextFieldWithPadding()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 1
        textField.rightViewMode = .always
        return textField
    }()
    
    private lazy var descriptionTextBox: TextFieldWithPadding = {
        let textView = TextFieldWithPadding()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.borderColor = UIColor.black.cgColor
        textView.layer.borderWidth = 1
        return textView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 16.0
        return stackView
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitle("Submit", for: .normal)
        return button
    }()
    
    private let timePickerView: UIPickerView = UIPickerView()
    private var dataArray = [String]()
    private var recommendTimeArray = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
        setupConstraints()
        setupData()
        setupPickerView()
        sortTime()
    }
    
    private func setupView() {
        view.addSubview(stackView)
        stackView.addArrangedSubview(meetingDate)
        stackView.addArrangedSubview(startTime)
        stackView.addArrangedSubview(endTime)
        stackView.addArrangedSubview(descriptionTextBox)
        view.addSubview(submitButton)
        submitButton.addTarget(self, action: #selector(submitButtonAction), for: .touchUpInside)
        arrowDownImageSetup(textField: meetingDate)
        arrowDownImageSetup(textField: startTime)
        arrowDownImageSetup(textField: endTime)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32.0),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16.0),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16.0),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: submitButton.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            submitButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16.0),
            submitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16.0),
            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16.0),
            submitButton.heightAnchor.constraint(equalToConstant: 48.0)
            
        ])
    }
    
    private func setupData() {
        meetingDate.placeholder = "Meeting Date"
        startTime.placeholder = "Start Time"
        endTime.placeholder = "EndTime"
        descriptionTextBox.placeholder = "Description"
    }
    
    private func arrowDownImageSetup(textField: TextFieldWithPadding) {
        let image = UIImageView(image: UIImage(named: "downArrowChevron"))
        NSLayoutConstraint.activate([
            image.widthAnchor.constraint(equalToConstant: 20.0),
            image.heightAnchor.constraint(equalToConstant: 20.0)
        ])
        textField.rightView = image
    }
    
    private func setupPickerView() {
        timePickerView.delegate = self
        timePickerView.dataSource = self
        
        startTime.inputView = timePickerView
        endTime.inputView = timePickerView
        
        uploadDataInPickerView()
        addToolBar()
    }
    
    private func uploadDataInPickerView() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        
        let startTime = "09:00 AM"
        let endTime = "05:00 PM"
        
        let date1 = formatter.date(from: startTime) ?? Date()
        let date2 = formatter.date(from: endTime) ?? Date()
        var i = 0
        while true {
            let date = date1.addingTimeInterval(TimeInterval(i*30*60))
            let time = formatter.string(from: date)
            
            if date > date2 {
                break;
            }
            
            i += 1
            dataArray.append(time)
        }
    }
    
    func addToolBar() {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.tintColor = .blue
        
        let doneButton = UIBarButtonItem(title: "Dismiss", style: .done, target: self, action: #selector(donePicker))
        toolbar.setItems([doneButton], animated: true)
        toolbar.isUserInteractionEnabled = true
        toolbar.sizeToFit()
        
        startTime.inputAccessoryView = toolbar
        endTime.inputAccessoryView = toolbar
    }
    
    @objc func donePicker() {
        if startTime.isEditing {
            startTime.resignFirstResponder()
        } else {
            endTime.resignFirstResponder()
        }
        recommendTimeArray.removeAll()
    }
    
    @objc func submitButtonAction() {
        var notInRange: Bool = true
        for item in data {
            if checkIfTimeExistsInRange(originalRange: (item.startTime, item.endTime), newRange: (startTime.text?.convert12To24() ?? "", endTime.text?.convert12To24() ?? ""), call: true) {
                notInRange = false
                break
            }
        }
        
        if !notInRange {
            let duration = 60
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            
            let startTime = "09:00 AM"
            let endTime = "05:00 PM"
            
            var date1 = formatter.date(from: startTime) ?? Date()
            let date2 = formatter.date(from: endTime) ?? Date()
            var previousTime = startTime
            var exists: Bool = false
            while true {
                date1 = date1.addingTimeInterval(TimeInterval(duration*60))
                let time = formatter.string(from: date1)
                if date1 > date2 {
                    break;
                }
                for item in data {
                    if checkIfTimeExistsInRange(originalRange: (item.startTime, item.endTime), newRange: (previousTime.convert12To24(), time.convert12To24()), call: false) {
                        exists = true
                        break
                    }
                    
                }
                if !exists {
                    recommendTimeArray.append("\(previousTime) - \(time)")
                    previousTime = time
                    continue
                }
                
                date1 = date1.addingTimeInterval(TimeInterval(30*60))
                previousTime = formatter.string(from: date1)
                exists = false
            }
            print(recommendTimeArray)
            presentAlertBox(message: "Please select from suggested slots", completionHandler: { [weak self] in
                guard let strongSelf = self else {return}
                strongSelf.dismiss(animated: true)
                strongSelf.startTime.becomeFirstResponder()
            })

        } else  {
            presentAlertBox(message: "Meeting Booked", completionHandler: { [weak self] in
                guard let strongSelf = self else {return}
                strongSelf.dismiss(animated: true)
            })
        }
    }
    
    private func checkIfTimeExistsInRange(originalRange: (startTime: String, endTime: String), newRange: (startTime: String, endTime: String), call: Bool) -> Bool {
        
        return originalRange.startTime.addTime(duration: 60) <= newRange.endTime.addTime(duration: -60) && newRange.startTime.addTime(duration: 60) <= originalRange.endTime.addTime(duration: -60)
    }
    
    private func sortTime() {
        data.sort { $0.startTime.localizedStandardCompare($1.startTime) == .orderedAscending }
    }
    
    private func presentAlertBox(message: String, completionHandler: @escaping (()-> Void)) {
        
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completionHandler()
        }
        ))
        self.present(alert, animated: true, completion: nil)
    }
}

extension MeetingScheduleViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return recommendTimeArray.isEmpty ? dataArray.count : recommendTimeArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return recommendTimeArray.isEmpty ? dataArray[row] : recommendTimeArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        recommendTimeArray.isEmpty ? selectMeetingAction(row: row) : recommendTimeAction(row: row)
      
    }
    
    func selectMeetingAction(row: Int) {
        if startTime.isEditing {
                  startTime.text = dataArray[row]
              } else if endTime.isEditing {
                  endTime.text = dataArray[row]
              }
    }
    
    func recommendTimeAction(row: Int) {
        let timeArr = recommendTimeArray[row].components(separatedBy: " - ")
        startTime.text = timeArr.first
        endTime.text = timeArr.last
    }
}


fileprivate class TextFieldWithPadding: UITextField {
    var textPadding = UIEdgeInsets(
        top: 10,
        left: 20,
        bottom: 10,
        right: 20
    )
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
}


struct DatabaseModel {
    var startTime = ""
    var endTime = ""
    
}

extension String {
    
    func convert24To12() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        let date = dateFormatter.date(from: self)
        dateFormatter.dateFormat = "h:mm a"
        let date12 = dateFormatter.string(from: date!)
        return date12
    }
    
    func convert12To24() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        let date = dateFormatter.date(from: self)
        dateFormatter.dateFormat = "HH:mm"
        let date12 = dateFormatter.string(from: date!)
        return date12
    }
    
    func getDateComponent(format: String = "HH:mm") -> DateComponents {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self) ?? Date()
        let calendar = Calendar.current
        let comp = calendar.dateComponents([.hour, .minute], from: date)
        return comp
    }
    
    func addTime(duration: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        var date = dateFormatter.date(from: self) ?? Date()
        date = date.addingTimeInterval(TimeInterval(duration))
        return dateFormatter.string(from: date)
    }
}
