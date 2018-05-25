//
//  MoreInfoViewController.swift
//  TestCamera
//
//  Created by 周凯旋 on 5/21/18.
//  Copyright © 2018 Kaixuan Zhou. All rights reserved.
//

import UIKit


class MoreInfoViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let chartViewWidth : CGFloat  = self.view.frame.size.width
        let chartViewHeight : CGFloat = self.view.frame.size.height
        let aaChartView = AAChartView()
        aaChartView.frame = CGRect(x:0,y:0,width:chartViewWidth,height:chartViewHeight)
        // set the content height of aachartView
        // aaChartView?.contentHeight = self.view.frame.size.height
        self.view.addSubview(aaChartView)
        
        let aaChartModel = AAChartModel.init()
            .chartType(AAChartType.Column)//Can be any of the chart types listed under `AAChartType`.
            .animationType(AAChartAnimationType.Bounce)
            .title("UTI Statistics")//The chart title
            .subtitle("Gender View")//The chart subtitle
            .dataLabelEnabled(false) //Enable or disable the data labels. Defaults to false
            .tooltipValueSuffix("%")//the value suffix of the chart tooltip
            .categories(["Chance of getting UTI at least once in life", "Getting recurrence UTIs"])
            .colorsTheme(["#fe117c","#06caf4"])
            .series([
                AASeriesElement()
                    .name("Female")
                    .data([70,30])
                    .toDic()!,
                AASeriesElement()
                    .name("Male")
                    .data([30,15])
                    .toDic()!,])
        
        
        aaChartView.aa_drawChartWithChartModel(aaChartModel)
        
        let backButton = UIButton(frame: .zero)
        view.addSubview(backButton)
        backButton.setTitle("back", for: .normal)
        backButton.setTitleColor(UIColor.black, for: .normal)
        backButton.backgroundColor=UIColor.white
        backButton.alpha=0.5
        backButton.addTarget(self, action: #selector(self.pressButton(_:)), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 30)])
    }
    
    @objc func pressButton(_ sender: UIButton){ //<- needs `@objc`
        sender.setTitleColor(UIColor.darkGray, for: .normal)
        present(UTIViewController(),animated: true,completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
