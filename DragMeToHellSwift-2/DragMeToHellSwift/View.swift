//
//  View.swift
//  DragMeToHellSwift
// This file explains out the logic for DragMetoHell App
//  Modified by :
//  1) Darshan Masti Prakash - 223909540
//  2) Manjunath Babu - 515114647
//  Source: Robert Irwin on 2/11/16.
//  References: Dotnet pearls for 2d swift matrix howto
//  Copyright © 2016 Robert Irwin. All rights reserved.


import UIKit
//Class to define a custom 2D Matrix to hold the Coordinate values
class CustomMatrix
{
    //storage array of bool values
    var storage = [[Bool]]()
    init() {
        //init the array of 10*10 matrix
        for _ in 0 ..< 10 {
            var subarr = [Bool]()
            for _ in 0..<10{
                subarr.append(false)
            }
            storage.append(subarr)
        }
    }
    //subscript functionality to easily access the array values
    subscript(trow: Int, tcolumn: Int) -> Bool {
        get {
            if(trow > 9 || tcolumn > 9)
            {
                return storage[trow-1][tcolumn-1]
            }
            else{
            //return value of matrix
            return storage[trow][tcolumn]
            }
        }
        set {
            // set the value of matrix
            storage[trow][tcolumn] = newValue
        }
    }
}

//Main view class
class MyView: UIView {
    var dw : CGFloat = 0;  var dh : CGFloat = 0    // width and height of cell
    var x : CGFloat = 0;   var y : CGFloat = 0     // touch point coordinates
    var row : Int = 0;     var col : Int = 0       // selected cell in cell grid
    var inMotion : Bool = false                    // true iff in process of dragging
    var isStart : Bool = true                      // true if the process is started for the first time
    var storeMat = CustomMatrix()                   // store custom matrix
    var imageViewsColl : [(UIImageView)] = []
    var imageRect : CGRect =  CGRectMake(0,0,0,0)
    var img : UIImage?
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //Check if there exists a clear path between the angel start and the last column
    func checkClearPath(temprow:Int, tempcol:Int) -> Bool
    {
        //if last column has been reached then return true
        if(tempcol == 9)
        {
            return true
        }
        //check if right of it has a clear path
        if(temprow+1 <= 9&&(storeMat[temprow+1,tempcol]  != true))
        {
            //recursive call to check clear path
            if(checkClearPath(temprow+1, tempcol: tempcol) == true)
            {
            return true
            }

        }
        //diagonal calls to check for clear path
        if(temprow-1 >= 0&&(storeMat[temprow-1,tempcol]  != true))
        {
            //left check
            if(temprow-1 >= 0&&tempcol+1<=9&&(checkClearPath(temprow-1, tempcol: tempcol+1) == true))
            {
                return true
            }
            //right check
            if(temprow+1 >= 0&&tempcol+1<=9&&(checkClearPath(temprow+1, tempcol: tempcol+1) == true))
            {
                return true
            }
        }
        return false
    }
    
    //function to draw rectangle
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!  // obtain graphics context
        //CGContextScaleCTM( context, 0.5, 0.5 )  // shrink into upper left quadrant
        let bounds = self.bounds          // get view's location and size
        let w = CGRectGetWidth( bounds )   // w = width of view (in points)
        let h = CGRectGetHeight( bounds ) // h = height of view (in points)
        self.dw = w/10.0                      // dw = width of cell (in points)
        self.dh = h/10.0                      // dh = height of cell (in points)
        // draw lines to form a 10x10 cell grid
        CGContextBeginPath( context )               // begin collecting drawing operations
        for i in 1..<10 {
            let iF = CGFloat(i)             // draw horizontal grid line
            CGContextMoveToPoint( context, 0, iF*(self.dh) )
            print("Height \(iF*self.dh)")
            CGContextAddLineToPoint( context, w, iF*self.dh )
        }
        for i in 1..<10 {  // draw vertical grid line
            let iFlt = CGFloat(i)
            CGContextMoveToPoint( context, iFlt*self.dw, 0 )
            CGContextAddLineToPoint( context, iFlt*self.dw, h )
            print("Width \(iFlt*self.dw)")
        }
        UIColor.grayColor().setStroke()                        // use gray as stroke color
        CGContextDrawPath( context, CGPathDrawingMode.Stroke ) // execute collected drawing ops
        let tl = self.inMotion ? CGPointMake( self.x, self.y ) // establish bounding box for image
                               : CGPointMake( CGFloat(row)*self.dw, CGFloat(col)*self.dh )
        imageRect = CGRectMake(tl.x, tl.y, self.dw, self.dh)
        if(self.col == 9) // checking if the last column has been reached
        {
            self.img = UIImage(named:"god.png")
            self.backgroundColor = UIColor.purpleColor()
        }
        else    //If no error then display Angel Image
        {
            self.img = UIImage(named:"angel.png")
            self.backgroundColor = UIColor.cyanColor()
        }
        if(isStart==true) //When app is started for the first time load all the co-ordinates of the images
        {
            isStart = false
            loadImages(tl) //loaded only for the first time
            if(self.inMotion == false){
                for i in 0 ..< 21 { //call animation method
                    performSelector( #selector(MyView.beginAnimation(_:)), withObject: self.imageViewsColl[i], afterDelay:1.0)}
            }
        }
        
        for j in 0 ..< 21 {
            if((imageViewsColl[j].layer.presentationLayer()?.frame.intersects(imageRect)) == true)// checking if imagescollectionviews matched with the current angel image coordinates
            {
                self.img = UIImage(named:"devil.png")
            }
        }
        img!.drawInRect(imageRect) //draw the image in the existing rectangular box
    }

    func loadImages(tl : CGPoint) //Load the images for the first time and then cache the coordinates so that it can be accessed next time
    {
        var extraImg : UIImage?
        var xCo : CGFloat = 0.0 , yCo  : CGFloat = 0.0;
            for _ in 0..<21
            {
                xCo =  CGFloat(arc4random_uniform(8))+1 //random generator for x coordinate
                yCo  = CGFloat(arc4random_uniform(8))+1 //random generator for y coordinate
                storeMat[Int(xCo),Int(yCo)] = true
                let imgTemp = "img\(arc4random_uniform(19)+1).jpg" //image loader
                let r1 = CGPointMake(xCo * self.dw , yCo * self.dh ) //point maker for x and y coordinate
                let newImageRect = CGRectMake(r1.x , r1.y ,self.dw, self.dh)
                extraImg = UIImage(named:imgTemp)
                let imageView = UIImageView(image: extraImg!)
                imageView.frame = newImageRect
                self.addSubview(imageView) //add to the subview
                self.imageViewsColl.append(imageView) //append and store the always updated coordinates of the animated obstacles
              
            }
        if(!checkClearPath(0,tempcol: 0)) //check for clear path
        {
            loadImages(tl) //load the images for the first time
        }
    }
    
    //animation core functionality written here
    func beginAnimation(imageView: UIImageView) {
        if(imageView.frame.origin.y <= 0 && !imageView.isAnimating()) { //check for y coordinated less than 0 and assign it to the bottom so that the animation has to again start from bottom to top
              imageView.frame.origin.y=10*self.dh
          }
        UIView.animateWithDuration(0.8 * Double(Int(imageView.frame.origin.y/self.dh)), //change this to make animation faster when this value is decreased
                                   delay: 0.0,
                                   options: [UIViewAnimationOptions.CurveLinear], //uniform animation
                                   animations: {
                                    imageView.frame =  CGRectMake(imageView.frame.origin.x , 0 ,self.dw, self.dh) //assign the coordinates to the frame
                                    var statFlag:Bool = true;
                                    if(self.col != 9){ //check for obstacles clashes during the animation
                                        for k in 0..<21 {
                                            if((self.imageRect).intersects(self.imageViewsColl[k].layer.presentationLayer()!.frame) == true)
                                            {
                                                self.backgroundColor = UIColor.redColor()
                                                self.img = UIImage(named:"devil.png")
                                                statFlag = false
                                                break
                                            }
                                        }
                                        if(statFlag == true)
                                        {
                                            self.backgroundColor = UIColor.cyanColor()
                                            self.img = UIImage(named:"angel.png")
                                        }
                                    }
                                   // self.img!.drawInRect(self.imageRect) //draw the image in the existing rectangular box
            },
            completion: { aniFin in self.beginAnimation(imageView)}
        )
    }

    //begin touches functionality
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) { //Touch has begun then calculate the position of the image
        var touchRow, touchCol : Int
        var xy : CGPoint
        super.touchesBegan(touches, withEvent: event)
        for t in touches {
            xy = t.locationInView(self)
            self.x = xy.x;  self.y = xy.y
            touchRow = Int(self.x / self.dw);  touchCol = Int(self.y / self.dh)
            self.inMotion = (self.row == touchRow  &&  self.col == touchCol)
        }
    }
    
    //touch move function
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {  //Touch has moved then calculate the position of the image
        var xy : CGPoint
        super.touchesMoved(touches, withEvent: event)
        for t in touches {
            xy = t.locationInView(self)
            
            self.x = xy.x;  self.y = xy.y
            print("Height1 \(Int(self.x / self.dw))")
            print("Width1 \(Int(self.y / self.dh))")

        }
        if self.inMotion{    // if in motion then set the default values of success and error
            if(self.col == 9) //success event needs to be set if last column has been reached
            {
                self.backgroundColor = UIColor.purpleColor() //set bg color to purple
            }
            else if (self.col != 9 && self.img == UIImage(named:"god.png"))
            {
                 self.backgroundColor = UIColor.cyanColor() //set bg color to cyan as the image has been moved from 9 column to previous columns
            }
            else if(self.col != 9 && self.img == UIImage(named:"devil.png"))
            {
                self.backgroundColor = UIColor.redColor() //set bg color to red
            }
            else if(self.col != 9 && self.img == UIImage(named:"angel.png"))
            {
                self.backgroundColor = UIColor.cyanColor() //set bg color to cyan
            }
            self.setNeedsDisplay()   // request view re-draw
        }
    }
    
    //if touch has ended then success evet needs to be set if last column has been reached
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        if self.inMotion {
            var touchRow : Int = 0;  var touchCol : Int = 0
            var xy : CGPoint
            for t in touches { //touchrow and touchcolumn needs to be tested
                xy = t.locationInView(self)
                self.x = xy.x;  self.y = xy.y
                touchRow = Int(self.x / self.dw)
                touchCol = Int(self.y / self.dh)
                print("Height2 \(touchRow)")
                print("Width2 \(touchCol)")
            }
            self.inMotion = false
            self.row = touchRow
            self.col = touchCol
            if(self.col == 9) //success event needs to be set if last column has been reached
            {
                self.backgroundColor = UIColor.purpleColor() //set bg color to purple
            }
            else if (self.col != 9 && self.img == UIImage(named:"god.png"))
            {
                self.backgroundColor = UIColor.cyanColor() //set bg color to cyan as the image has been moved from 9 column to previous columns
            }
            else if(self.col != 9 && self.img == UIImage(named:"devil.png"))
            {
                  self.backgroundColor = UIColor.redColor() //set bg color to red
            }
            else if(self.col != 9 && self.img == UIImage(named:"angel.png"))
            {
                self.backgroundColor = UIColor.cyanColor() //set bg color to cyan
            }
           self.setNeedsDisplay()
        }
    }
}
