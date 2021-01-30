//
//  SearchQuestionView.swift
//  Memoir
//
//  Created by Yura on 9/26/20.
//  Copyright © 2020 Symbiosis. All rights reserved.
//

import UIKit

class SearchQuestionView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray.cgColor
        clipsToBounds = true
        
        configureTextView()
    }
    
    private func configureTextView() {
        let textView = UITextView(frame: CGRect(origin: .zero, size: .zero))
        
        addSubview(textView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        let tips = NSMutableAttributedString(string: "")
        tips.append(NSAttributedString(string: "\tHere are some tips to make your search more effective and refined:", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .regular)]))
        tips.append(NSAttributedString(string: "\n\n\n"))
        // ,
        tips.append(NSAttributedString(string: "- Use comma to find memories with any tags", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium)]))
        tips.append(NSAttributedString(string: "\n\tExample: ", attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular)]))
        tips.append(NSAttributedString(string: "2020, summer, kids, nature", attributes: [.font: UIFont.italicSystemFont(ofSize: 15)]))
        tips.append(NSAttributedString(string: "\n\tResult: Every memory that was tagged with ANY of these tags will be displayed. Comma is an OR.", attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular)]))
        tips.append(NSAttributedString(string: "\n\n"))
        // +
        tips.append(NSAttributedString(string: "- Use plus sign to find memories that include 2 or more tags", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium)]))
        tips.append(NSAttributedString(string: "\n\tExample: ", attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular)]))
        tips.append(NSAttributedString(string: "animals+2020+kids", attributes: [.font: UIFont.italicSystemFont(ofSize: 15)]))
        tips.append(NSAttributedString(string: "\n\tResult: Every memory that was tagged with ALL of these tags will be displayed. Plus is an AND. In this example, all photos or videos of kids with animals in 2020 will be displayed.", attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular)]))
        tips.append(NSAttributedString(string: "\n\n"))
        //
        tips.append(NSAttributedString(string: "- Combine commas and plus sign together", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium)]))
        //
        textView.isEditable = false
        textView.isSelectable = false
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        textView.attributedText = tips
        textView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    }
}
