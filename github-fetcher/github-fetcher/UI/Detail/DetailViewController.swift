//
//  DetailViewController.swift
//  github-fetcher
//
//  Created by Zhong on 2023/10/9.
//  

import UIKit
import Combine
import SnapKit
import Kingfisher

class DetailViewController: UIViewController {
    
    private lazy var cancellables = Set<AnyCancellable>()
    
    private var viewModel: DetailViewModel?
    
    private lazy var imageView = UIImageView().then {
        $0.kf.indicatorType = .activity
    }
    
    private lazy var languageLabel = UILabel().then {
        $0.numberOfLines = 1
        $0.font = .boldSystemFont(ofSize: 16)
    }
    
    private lazy var starsLabel = UILabel().then {
        $0.numberOfLines = 1
        $0.font = .systemFont(ofSize: 14, weight: .medium)
    }
    
    private lazy var watchersLabel = UILabel().then {
        $0.numberOfLines = 1
        $0.font = .systemFont(ofSize: 14, weight: .medium)
    }
    
    private lazy var forksLabel = UILabel().then {
        $0.numberOfLines = 1
        $0.font = .systemFont(ofSize: 14, weight: .medium)
    }
    
    private lazy var issuesLabel = UILabel().then {
        $0.numberOfLines = 1
        $0.font = .systemFont(ofSize: 14, weight: .medium)
    }
    
    override func loadView() {
        
        super.loadView()
        
        let numbersVStack = UIStackView(
            arrangedSubviews: [starsLabel,
                               watchersLabel,
                               forksLabel,
                               issuesLabel]
        ).then {
            $0.axis = .vertical
            $0.alignment = .trailing
        }
        
        view.addSubview(imageView)
        view.addSubview(languageLabel)
        view.addSubview(numbersVStack)
        
        imageView.snp.makeConstraints {
            $0.width.equalTo(imageView.snp.height)
            $0.centerX.equalToSuperview()
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(25)
        }
        
        languageLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(20)
            $0.bottom.lessThanOrEqualToSuperview().offset(-25)
        }
        
        numbersVStack.snp.makeConstraints {
            $0.top.equalTo(languageLabel)
            $0.left.greaterThanOrEqualTo(languageLabel).offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.bottom.lessThanOrEqualToSuperview().offset(-25)
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        
        navigationItem.largeTitleDisplayMode = .never
    }
    
    func bind(viewModel: DetailViewModel?) {
        
        guard viewModel !== self.viewModel else { return }
        
        cancellables.removeAll()
        
        self.viewModel = viewModel
        
        guard let viewModel = viewModel else { return }
        
        viewModel.viewInfoPub
            .receive(on: OperationQueue.main)
            .sink { [weak self] item in
                guard let self else { return }
                
                navigationItem.title = item.name
                
                KF.url(item.imageURL)
                    .placeholder(ImagePlaceholder())
                    .fade(duration: 0.25)
                    .set(to: self.imageView)
                
                if let language = item.language {
                    self.languageLabel.text = "Written in \(language)"
                    self.languageLabel.isHidden = false
                } else {
                    self.languageLabel.text = nil
                    self.languageLabel.isHidden = true
                }
                
                starsLabel.text = "stars \(item.stars)"
                watchersLabel.text = "watchers \(item.watchers)"
                forksLabel.text = "forks \(item.forks)"
                issuesLabel.text = "issues \(item.issues)"
            }
            .store(in: &cancellables)
    }
}

private struct ImagePlaceholder: Placeholder {
    
    public func add(to imageView: KFCrossPlatformImageView) {
        imageView.backgroundColor = .lightGray
    }
    
    public func remove(from imageView: KFCrossPlatformImageView) {
        imageView.backgroundColor = .clear
    }
}
