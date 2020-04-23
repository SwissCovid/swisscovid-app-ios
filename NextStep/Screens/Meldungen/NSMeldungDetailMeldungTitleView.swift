///

import UIKit

class NSMeldungDetailMeldungTitleView: UIView, NSTitleViewProtocol {
    // MARK: - API

    public var meldungen: [NSMeldungModel] = [] {
        didSet { update() }
    }

    // MARK: - Initial Views

    private var headers: [NSMeldungDetailMeldungSingleTitleHeader] = []
    private var stackScrollView = NSStackScrollView(axis: .horizontal, spacing: 0)

    private let pageControl = UIPageControl()
    private let overlapInset: CGFloat

    private var firstUpdate = true

    // MARK: - Init

    init(overlapInset: CGFloat) {
        self.overlapInset = overlapInset

        super.init(frame: .zero)

        backgroundColor = .ns_blue
        setupStackScrollView()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Layout

    private func setupStackScrollView() {
        pageControl.pageIndicatorTintColor = UIColor.ns_text.withAlphaComponent(0.46)
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.alpha = 0.0

        addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(overlapInset + NSPadding.medium)
        }

        addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(pageControl.snp.top)
        }

        stackScrollView.scrollView.isPagingEnabled = true
        stackScrollView.scrollView.delegate = self
    }

    // MARK: - Protocol

    func startInitialAnimation() {
        pageControl.alpha = 1.0

        for h in headers {
            h.startInitialAnimation()
        }
    }

    func updateConstraintsForAnimation() {
        for h in headers {
            h.updateConstraintsForAnimation()
        }

        firstUpdate = false
    }

    // MARK: - Update

    private func update() {
        for hv in headers {
            hv.removeFromSuperview()
        }

        stackScrollView.removeAllViews()
        headers.removeAll()

        for m in meldungen {
            let v = NSMeldungDetailMeldungSingleTitleHeader(setupOpen: firstUpdate)
            v.meldung = m

            stackScrollView.addArrangedView(v)

            v.snp.makeConstraints { make in
                make.width.equalTo(self)
            }

            headers.append(v)
        }

        stackScrollView.scrollView.setContentOffset(.zero, animated: false)

        pageControl.numberOfPages = headers.count
        pageControl.currentPage = 0
    }
}

extension NSMeldungDetailMeldungTitleView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let fraction = (scrollView.contentOffset.x / scrollView.contentSize.width)
        let number = Int(fraction * CGFloat(pageControl.numberOfPages))
        pageControl.currentPage = number
    }
}

extension Date {
    func ns_differenceInDaysWithDate(date: Date) -> Int {
        let calendar = Calendar.current

        let date1 = calendar.startOfDay(for: self)
        let date2 = calendar.startOfDay(for: date)

        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return components.day ?? 0
    }
}
