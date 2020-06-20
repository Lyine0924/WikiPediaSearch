//
//  MVVMViewController.swift
//  WikiPediaSearch
//
//  Created by Lyine on 2020/06/20.
//  Copyright © 2020 Lyine. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources
import SnapKit
import SafariServices

enum Cell {
    static let identifier = "\(TableViewCell.self)"
}

class MVVMViewController: UIViewController {
    
    weak var indicator: UIActivityIndicatorView?
    weak var tableView: UITableView?
    
    let viewModel: MainViewModelType
    let disposeBag = DisposeBag()
    
    private var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search Here"
        return searchController
    }()
    
    private let dataSource = RxTableViewSectionedReloadDataSource<TableCellSection>(configureCell: { dataSource, tableView, indexPath, viewModel in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier, for: indexPath) as? TableViewCell else { fatalError() }
        cell.viewModel = viewModel
        return cell
    })
    
    init(viewModel: MainViewModelType = MainViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func loadView() {
        configureLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureProperties()
        bindUI()
        // Do any additional setup after loading the view.
    }
    
    private func configureProperties() {
        navigationItem.searchController = searchController
        navigationItem.title = "Wikipedia finder"
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func configureLayout() {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.view = view
        
        let tableView = UITableView()
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.register(TableViewCell.self, forCellReuseIdentifier: Cell.identifier)
        
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        
        tableView.contentInset.bottom = view.safeAreaInsets.bottom
        
        self.tableView = tableView
        
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.color = .white
        indicator.backgroundColor = UIColor(white: 0.3, alpha: 0.8)
        indicator.layer.cornerRadius = 10
        indicator.clipsToBounds = true

        self.indicator = indicator
        view.addSubview(indicator)

        indicator.translatesAutoresizingMaskIntoConstraints = true
        
        indicator.snp.makeConstraints {
            $0.width.equalTo(60)
            $0.height.equalTo(60)
            $0.centerX.equalTo(view.safeAreaLayoutGuide.snp.centerX)
            $0.centerY.equalTo(view.safeAreaLayoutGuide.snp.centerY)
        }
    }

    private func bindUI() {
        searchController.searchBar.rx.text.orEmpty
            .asObservable()
            .throttle(.microseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map { ($0 ?? "").lowercased().replacingOccurrences(of: " ", with: "_") }
            .map { self.viewModel.input.fetchData(request: WikipediaRequest(word: $0)) }
            .subscribe()
            .disposed(by: disposeBag)
        
        tableView?.rx.modelSelected(TableCellViewModel.self)
            .map { URL(string: $0.result.url ?? "")! }
            .map { SFSafariViewController(url: $0) }
            .subscribe(onNext: { [weak self] safariViewController in
                self?.present(safariViewController,animated: true)
            })
            .disposed(by: disposeBag)
        
        self.viewModel.output.isLoading
            .drive(onNext: { [weak self] in $0 ? self?.indicator?.startAnimating() : self?.indicator?.stopAnimating() })
            .disposed(by: self.disposeBag)
        
        self.viewModel.output.response
            .drive(tableView!.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}
