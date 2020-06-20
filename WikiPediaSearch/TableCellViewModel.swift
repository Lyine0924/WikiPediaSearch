//
//  ColorCellViewModel.swift
//  ColorMVVM
//
//  Created by Seokho on 2020/04/01.
//

import Foundation

protocol TableCellViewModelOutput {
    var result: searchResult  { get }
}

protocol TableCellViewModelType {
    var output: TableCellViewModelOutput { get }
}

class TableCellViewModel: TableCellViewModelType, TableCellViewModelOutput {
    var output: TableCellViewModelOutput { self }
    var result: searchResult
    
    init(_ result: searchResult) {
        self.result = result
    }
}
