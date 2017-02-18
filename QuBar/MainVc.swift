//
//  MainVc.swift
//  QuBar
//
//  Created by Andrii Narinian on 2/15/17.
//  Copyright © 2017 Andrii. All rights reserved.
//
import UIKit
import SceneKit

struct Page {
    var title: String
    var image: String
}

let PAGES = [
    Page(title: "1", image: "https://scontent-sof1-1.xx.fbcdn.net/v/t1.0-0/p480x480/16640884_252736925167951_42223909283015892_n.jpg?oh=80ca87bda06837da3e3e652848e09370&oe=5944065D"),
    Page(title: "2", image: "https://www.askideas.com/media/13/Woman-Laughing-Funny-Mouth-Picture.jpg"),
    Page(title: "3", image: "https://i.ytimg.com/vi/GchUiYAmlLM/maxresdefault.jpg"),
    Page(title: "4", image: "https://cs7051.vk.me/c638129/v638129046/23539/BbVMcyVZsAM.jpg"),
    Page(title: "5", image: "https://i.ytimg.com/vi/icqDxNab3Do/maxresdefault.jpg"),
    Page(title: "6", image: "https://i.ytimg.com/vi/95ImXirddgU/hqdefault.jpg")
]

var pagesCount: Int {
    return isHorisontalRotationLocked ? 4 : 6
}

class MainVc: UIViewController {
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var quBar: QuBar!
    @IBOutlet weak var switcher: UISwitch!
    @IBOutlet weak var switcher2: UISwitch!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    
    fileprivate let collapsedHeight:CGFloat = 70
    fileprivate let raisedHeight:CGFloat = 240
    fileprivate let collapsedBottom:CGFloat = -8
    fileprivate let raisedBottom:CGFloat = 34
    fileprivate var collapsedSwitcher:CGFloat = 0
    fileprivate var raisedSwitcher:CGFloat = 0
    fileprivate var collapsedReset:CGFloat = 0
    fileprivate var raisedReset:CGFloat = 0
    fileprivate var raisedLabel:CGFloat = 0
  
    
    var pageViewController: UIPageViewController!
    
    var currentPageIndex = 0{
        didSet{
            infoLabel.text = "#\(currentPageIndex + 1)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let pc = UIPageControl.appearance()
        pc.pageIndicatorTintColor = UIColor.lightGray
        pc.currentPageIndicatorTintColor = UIColor.black
        pc.backgroundColor = UIColor.white
        let btn = UIButton(type: .system)
        btn.setTitle("Restart", for: .normal)
        btn.addTarget(self, action: #selector(restartAction(sender:)), for: .touchUpInside)
        btn.isHidden = true
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageViewController.dataSource = self
        self.restartAction(sender: self)
        self.addChildViewController(self.pageViewController)
        let views = [
            "pg": self.pageViewController.view,
            "btn": btn,
            ]
        for (_, v) in views {
            v?.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(v!)
        }
        NSLayoutConstraint.activate(
            [
                NSLayoutConstraint(
                item: btn,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: self.view,
                attribute: .centerX,
                multiplier: 1,
                constant: 0),
             ] +
                NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|[pg]|",
                    options: .alignAllCenterX,
                    metrics: [:], views: views)
                +
                NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|-30-[pg]-[btn]-15-|",
                    options: .alignAllCenterX,
                    metrics: [:],
                    views: views
            )
        )
        self.pageViewController.didMove(toParentViewController: self)
        pageViewController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switcher2.superview?.bringSubview(toFront: switcher2)
        switcher.superview?.bringSubview(toFront: switcher)
        quBar.superview?.bringSubview(toFront: quBar)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        quBar.quBarDelegate = self
        quBar.showsStatistics = false
        raisedSwitcher = switcher.frame.origin.y
        raisedReset = switcher2.frame.origin.y
        raisedLabel = infoLabel.frame.origin.y
    }
    
    func restartAction(sender: AnyObject) {
        self.pageViewController.setViewControllers([self.viewControllerAtIndex(index: 0)], direction: .forward, animated: true, completion: nil)
    }
    
    func viewControllerAtIndex(index: Int) -> ContentViewController {
        if (pagesCount == 0) || (index >= pagesCount) {
            return ContentViewController()
        }
        let vc = ContentViewController()
        vc.pageIndex = index
        return vc
    }
    
    @IBAction func outterTapperDidTap(_ sender: UITapGestureRecognizer) {
        quBar.stopRotating()
        quBar.rotate(toFaceIndex: currentPageIndex, dir: nil)
        quBar.collapse()
    }
    @IBAction func pannerDidPan(_ sender: UIPanGestureRecognizer) {
        quBar.pannerDidPan(sender)
    }
    @IBAction func didSwitch2(_ sender: UISwitch) {
        if sender.isOn {
            isGoingToRemainSolid = false
            infoLabel.text = "fade mode ON"
            infoLabel.textAlignment = .right
        } else {
            isGoingToRemainSolid = true
            infoLabel.text = "fade mode OFF"
            infoLabel.textAlignment = .right
        }
    }
    @IBAction func didSwitch(_ sender: UISwitch) {
        if sender.isOn {
            isHorisontalRotationLocked = true
            infoLabel.text = "horizontal mode ON"
            infoLabel.textAlignment = .left
        } else {
            isHorisontalRotationLocked = false
            infoLabel.text = "horizontal mode OFF (free roll)"
            infoLabel.textAlignment = .left
        }
    }
    
    func hideUI() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.switcher.frame.origin.y = self.raisedSwitcher + 100
            self.switcher2.frame.origin.y = self.raisedReset + 100
            self.infoLabel.frame.origin.y = self.raisedLabel + 100
            self.view.layoutIfNeeded()
        })
    }
    func showUI() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.switcher.frame.origin.y = self.raisedSwitcher
            self.switcher2.frame.origin.y = self.raisedReset
            self.infoLabel.frame.origin.y = self.raisedLabel
            self.view.layoutIfNeeded()
        })
    }
}

// MARK: - Page View Controller Delegate
extension MainVc: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let vc = pendingViewControllers.first as? ContentViewController {
            let previousIndex = currentPageIndex
            currentPageIndex = vc.pageIndex
            quBar.stopRotating()
            quBar.collapse()
            quBar.rotate(toFaceIndex: currentPageIndex, dir: previousIndex < currentPageIndex ? .left : .right)
        }
    }
}

// MARK: - Page View Controller Data Source
extension MainVc: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        if (index == 0 || index == NSNotFound) {
            return nil
        }
        index -= 1
        currentPageIndex = index
        return self.viewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        if (index == NSNotFound) {
            return nil
        }
        index += 1
        if (index == pagesCount) {
            return nil
        }
        return self.viewControllerAtIndex(index: index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pagesCount
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

extension MainVc: QuBarDelegate {
    func collapse() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.heightConstraint.constant = self.collapsedHeight
            self.bottomConstraint.constant = self.collapsedBottom
            self.view.layoutIfNeeded()
        })
    }
    func raize() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.heightConstraint.constant = self.raisedHeight
            self.bottomConstraint.constant = self.raisedBottom
            self.view.layoutIfNeeded()
        })
    }
    func didFadeIn(){
        DispatchQueue.main.async {
            self.hideUI()
        }
    }
    func willFadeOut() {
        DispatchQueue.main.async {
            self.showUI()
        }
    }
    func didRotateToface(withIndex index: Int, dir: direction?) {
        if currentPageIndex == index { return }
        DispatchQueue.main.async {
            self.pageViewController.setViewControllers([self.viewControllerAtIndex(index: index)], direction: dir == .right ? .forward : .reverse, animated: true) { (flag) in
                self.currentPageIndex = index
            }
        }
    }
}

class ContentViewController: UIViewController {
    var pageIndex: Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        let lb = UILabel()
        lb.textAlignment = .center
        lb.text = PAGES[self.pageIndex].title
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        //iv.image = UIImage(named: "\(pageIndex + 1)")
        ImageLoader.sharedLoader.imageForUrl(urlString: PAGES[self.pageIndex].image) { (image, url) -> () in
            iv.image = image
        }
        let views = [
            "iv": iv,
            "lb": lb,
            ]
        for (_, v) in views {
            v.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(v)
        }
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[lb]-|",      options: .alignAllCenterX, metrics: [:], views: views) +
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-[iv]-|",      options: .alignAllCenterX, metrics: [:], views: views) +
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-[lb]-[iv]-|", options: .alignAllCenterX, metrics: [:], views: views)
        )
    }
}

class ImageLoader {
    var cache = NSCache<AnyObject, AnyObject>()
    class var sharedLoader : ImageLoader {
        struct Static {
            static let instance : ImageLoader = ImageLoader()
        }
        return Static.instance
    }
    func imageForUrl(urlString: String, completionHandler:@escaping (_ image: UIImage?, _ url: String) -> ()) {
        DispatchQueue.global(qos: .background).async {()in
            let data: NSData? = self.cache.object(forKey: urlString as AnyObject) as? NSData
            if let goodData = data {
                let image = UIImage(data: goodData as Data)
                DispatchQueue.main.async {() in
                    completionHandler(image, urlString)
                }
                return
            }
            guard let url = URL(string: urlString) else { return }
            let downloadTask = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
                if (error != nil) {
                    completionHandler(nil, urlString)
                    return
                }
                guard let data = data else { return }
                let image = UIImage(data: data)
                self.cache.setObject(data as AnyObject, forKey: urlString as AnyObject)
                DispatchQueue.main.async(execute: {() in
                    completionHandler(image, urlString)
                })
                return
            })
            downloadTask.resume()
        }
    }
}
