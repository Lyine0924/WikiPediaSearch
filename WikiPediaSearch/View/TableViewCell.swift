//
//  TableViewCell.swift
//  RxNetworkExample
//
//  Created by Lyine on 2020/05/09.
//  Copyright © 2020 Lyine. All rights reserved.
//

import UIKit

import UIKit


class TableViewCell: UITableViewCell {
    
    var viewModel: TableCellViewModelType? {
        didSet  {
            guard let viewModel = self.viewModel else { return }
            
            let output = viewModel.output
            self.titleLabel?.text = output.result.title
            self.url? = output.result.url
        }
    }
    
    private weak var titleLabel: UILabel?
    private var url:String?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
        ])
        self.titleLabel = titleLabel
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
