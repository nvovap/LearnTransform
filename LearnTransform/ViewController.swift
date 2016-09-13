//
//  ViewController.swift
//  LearnTransform
//
//  Created by nvovap on 9/13/16.
//  Copyright © 2016 nvovap. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    var testView: UIView!
    var valueScale: CGFloat = 1
    var isAnimation = false
    var drawPath = true
    
    var pathView: UIView?
    
    
    @IBOutlet weak var scaleValue: UILabel!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        
        testView.layer.borderColor = UIColor.red.cgColor
        testView.layer.borderWidth = 3
        testView.backgroundColor = UIColor.clear
        
        view.addSubview(testView)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func setToCentr(_ sender: UIButton) {
        testView.frame = CGRect(x: view.bounds.width/2, y: view.bounds.height/2, width: 60, height: 60)
    }
    
    @IBAction func applyScale(_ sender: AnyObject) {
        let scale = CGAffineTransform(scaleX: valueScale, y: valueScale)
        
        let bounds = testView.bounds.applying(scale)
        
        testView.bounds = bounds
    }
    
    @IBAction func animation() {
        
        let path = CGMutablePath()
        path.addArc(center: CGPoint.init(x:  view.bounds.width/2, y: view.bounds.height/2) , radius: 50, startAngle: CGFloat.pi, endAngle: 3*CGFloat.pi/2, clockwise: false)
        
      //  path.addArc(center: CGPoint.init(x:  view.bounds.width/2, y: view.bounds.height/2) , radius: 50, startAngle: CGFloat.pi, endAngle: 0, clockwise: false)
        
        
        let keyAnimation = CAKeyframeAnimation(keyPath: "position")
        keyAnimation.path = path
        keyAnimation.duration = 2
        testView.layer.add(keyAnimation, forKey: "position")
    }
    
    
    @IBAction func applyTransform(_ sender: UISlider) {
        
        valueScale = CGFloat(sender.value)
        
        scaleValue.text = "\(valueScale)"
        
//        let scale = CGAffineTransform(scaleX: CGFloat(1.5), y: CGFloat(1.5))
//       
//        let bounds = testView.bounds.applying(scale)
//        
//        testView.bounds = bounds
//     
//        
//        print("early \(testView.layer.transform)")
//       // print("early \(transform)")
//        
////        testView.layer.transform.m11 = CGFloat(value)
////        testView.layer.transform.m22 = CGFloat(value)
//        
//    //    testView.layer.transform = transform
//        
//        
//        
//        print("latter \(testView.layer.transform)")
    }


}

extension ViewController: CAAnimationDelegate {
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isAnimation {
            stop()
        }
        
        isAnimation = true
        
        if let touch = touches.first {
            let touchPoint = touch.location(in: view)
            
            let path = pathToPoint(point: touchPoint)
            
            followThePath(path: path)
            
            if drawPath {
                drawPath(path: path)
                
            }
            
            
        }
    }
    
    
    func drawPath(path: CGPath){
        if let pathView = pathView {
            pathView.removeFromSuperview()
        }
        
        pathView = PathDrawingView(path: path, frame: view.frame)
        
        pathView?.frame = view.frame
        view.addSubview(pathView!)
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        if flag {
             stop()
        }
        
    }
    
    
//    private func drawPath(path: CGPath) {
//        self
//    }
    
    private func stop() {
        
        let pLayer = testView.layer.presentation()
        let currentPos = pLayer?.position
        
        testView.layer.removeAnimation(forKey: "positionAnimate")
        testView.center = currentPos!
        
        isAnimation = false
        
        
    }
    
    
    private func pathToPoint(point: CGPoint) -> CGPath {
        let imagePos = testView.center
        let xDist = point.x - imagePos.x
        let yDist = point.y - imagePos.y
        
        //По теореме Пифагора вычисляем расстояние между картинкой и Т. Делим на два и получаем радиус дуги, начало которой будет в картинке, а конец – в нужной точке.
        let radius = sqrt(xDist*xDist + yDist*yDist)/2
        
        //Сначала будем работать в системе координат, где центр картинки и Т находятся на одной прямой, проходящей по оси Y. В этой системе координат, центр искомой окружности будет смещён на расстояние радиуса по оси X.
        let center = CGPoint(x: imagePos.x+radius, y: imagePos.y)
        
        //Находим угол между центром картинки и Т. Конечно, в исходной системе координат. Для этого используем найденый ранее вектор от Т к центру картинки.
        let angle = atan2(yDist, xDist)
        
        //Создаём матрицу поворота для перехода из произвольной системы координат к «настоящей».
        let transform = CGAffineTransform(translationX: imagePos.x, y: imagePos.y)
        transform.rotated(by: angle)
        transform.translatedBy(x: -imagePos.x, y: -imagePos.y)
        
        //Создаём путь. К этому моменту у нас есть все необходимые данные. Обратите внимание, что одна строчка закоментирована. Создаётся только одна дуга – мы хотим чтобы картинка остановилась в указаной точке, а не прошла через неё и вернулась обратно.
        let path  = CGMutablePath()
        path.addArc(center: center, radius: radius, startAngle: CGFloat.pi, endAngle: 0, clockwise: true, transform: transform)
       // path.addArc(center: center, radius: radius, startAngle: 0, endAngle: CGFloat.pi, clockwise: true, transform: transform)
        
        return path
        
    }
    
    
    func followThePath(path: CGPath) {
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        pathAnimation.path = path
        //Указывает, что анимация должна остаться после окончания. Это нужно, чтобы мы могли прочитать последнее значение. А вот зачем нужно это – будет понятно позже.
        pathAnimation.isRemovedOnCompletion = false
        //Указывает, что объект анимации (т.е. картинка, которую мы будем двигать) должна оставаться в том состоянии, в котором закончилась анимация. Если убрать, картинка будет перепрыгивать туда, откуда начинала движение.
        pathAnimation.fillMode = kCAAnimationPaced
        
        pathAnimation.delegate = self
        
        pathAnimation.duration = 2
        testView.layer.add(pathAnimation, forKey: "positionAnimate")
    }
    
    
}


class PathDrawingView : UIView {
    var path: CGPath!
    
    var strokeColor = UIColor.black
    var fillColor   = UIColor.clear
    
    
    init(path setPath: CGPath, frame: CGRect) {
        
        super.init(frame: frame)
        
        
        path = setPath
        
        self.backgroundColor = UIColor.clear
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func draw(_ rect: CGRect) {
        
        let ct = UIGraphicsGetCurrentContext()!
        ct.setStrokeColor(strokeColor.cgColor)
        ct.setFillColor(fillColor.cgColor)
        ct.addPath(path)
        ct.strokePath()
    }
    
    
}
