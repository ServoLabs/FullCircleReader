//
//  PDFView.m
//  FullCircleReader
//
//  Created by Brian Montgomery on 3/3/12.
//  Copyright (c) 2012 Servo Labs, LLC. All rights reserved.
//

#import "PDFPageView.h"

@implementation PDFPageView
@synthesize page = _page;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
// - (void)drawRect:(CGRect)rect {
//     CGContextRef context = UIGraphicsGetCurrentContext();
//     CGContextSaveGState(context);
//     CGFloat frameHeight = self.frame.size.height;
//     CGContextTranslateCTM(context, 0, frameHeight);
//     CGContextScaleCTM(context, 1.0, -1.0);
//     CGContextDrawPDFPage(context, _page);
//     CGContextRestoreGState(context);
// }

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	CGFloat frameWidth = self.frame.size.width;
	CGFloat frameHeight = self.frame.size.height;
    
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, 0, frameHeight);
	CGContextScaleCTM(context, 1.0, -1.0);
    
	CGRect pageRect = CGPDFPageGetBoxRect(self.page, kCGPDFBleedBox);
	CGFloat pageWidth = pageRect.size.width;
	CGFloat pageHeight = pageRect.size.height;
	CGFloat scaleRatioX = 1;
    CGFloat scaleRatioY = 1;
    
    scaleRatioY = frameHeight / pageHeight;
    scaleRatioX = frameWidth / pageWidth;
    
	CGFloat xOffset = (frameWidth - pageWidth
                       * scaleRatioX) / 2;
	CGFloat yOffset = (frameHeight - pageHeight
                       * scaleRatioY) / 2;
    
	CGAffineTransform pdfTransform =
    CGPDFPageGetDrawingTransform(
                                 self.page, kCGPDFMediaBox,
                                 CGRectMake(xOffset, yOffset, pageWidth, pageHeight), 
                                 0, true);
	CGContextConcatCTM(context, CGAffineTransformScale(
                                                       pdfTransform, (frameWidth / pageWidth), (frameHeight / pageHeight)) );
	CGContextDrawPDFPage(context, self.page);
    
	CGContextRestoreGState(context);
}

@end
