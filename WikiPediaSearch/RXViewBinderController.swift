//
//  ViewController.swift
//  RXViewBinderColorAPI
//
//  Created by Lyine on 2020/06/07.
//  Copyright © 2020 Lyine. All rights reserved.
//

import UIKit
import SafariServices

import RxSwift
import RxCocoa
import RxDataSources
import RxViewBinder
import SnapKit

class RXViewBinderController: UIViewController, BindView {
    typealias ViewBinder = MainViewBindable

    weak var tableView: UITableView?
    weak var indicator: UIActivityIndicatorView?
    
    private var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search Here"
        return searchController
    }()

    private let dataSource = RxTableViewSectionedReloadDataSource<TableCellSection>(configureCell: {
        dataSource, tableView, indexPath, viewModel in

        guard let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier, for: indexPath) as? TableViewCell else {
            return UITableViewCell()
        }

        cell.viewModel = viewModel
        return cell
    })

    init(viewBindable: ViewBinder = MainViewBindable()) {
        super.init(nibName: nil, bundle: nil)
        self.viewBinder = viewBindable
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        self.view = view

        // tableView
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

    override func viewDidLoad() {
        super.viewDidLoad()
        configureProperties()
        // Do any additional setup after loading the view.
    }
    
    private func configureProperties() {
        navigationItem.searchController = searchController
        navigationItem.title = "Wikipedia finder"
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    func state(viewBinder: MainViewBindable) {
        viewBinder.state
            .response
            .drive(tableView!.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        viewBinder.state
            .isLoading
            .drive(onNext: { [weak self] in
                $0 ? self?.indicator?.startAnimating() : self?.indicator?.stopAnimating()
            })
            .disposed(by: disposeBag)

        viewBinder.state
            .error
            .asObservable()
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] in
                let alertViewController = UIAlertController(title: nil, message: $0, preferredStyle: .alert)
                alertViewController.addAction(UIAlertAction(title: "확인", style: .default))

                self?.present(alertViewController, animated: true)
            })
            .disposed(by: disposeBag)
    }

    func command(viewBinder: MainViewBindable) {
        searchController.searchBar.rx.text.orEmpty
            .asObservable()
            .throttle(.microseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map { ($0 ?? "").lowercased().replacingOccurrences(of: " ", with: "_") }
            .map { MainViewBindable.Command.search(WikipediaRequest(word: $0))}
            .bind(to: viewBinder.command)
            .disposed(by: disposeBag)

        self.rx.methodInvoked(#selector(UIViewController.viewDidLoad))
            .map { _ in ViewBinder.Command.fetch }
            .bind(to: viewBinder.command)
            .disposed(by: disposeBag)
        
        tableView?.rx.modelSelected(TableCellViewModel.self)
            .map { URL(string: $0.result.url ?? "")! }
            .map { SFSafariViewController(url: $0) }
            .subscribe(onNext: { [weak self] safariViewController in
                self?.present(safariViewController,animated: true)
            })
            .disposed(by: disposeBag)
    }
}
