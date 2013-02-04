//
//  CellView.m
//  Test5
//
//  Created by Devaraj NS on 29/01/13.
//  Copyright (c) 2013 Devaraj NS. All rights reserved.
//

#import "CellView.h"

@implementation CellView
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{    
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont systemFontOfSize:15];
        self.textLabel.numberOfLines = 1; 
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        CGRect buttonFrame = CGRectMake(self.bounds.size.width, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = buttonFrame;
        [button setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        [self addSubview:button];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.textLabel.textColor=[UIColor blueColor];
    [super touchesBegan:touches withEvent:event];     
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.textLabel.textColor=[UIColor blackColor];
    [super touchesEnded:touches withEvent:event];    
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.textLabel.textColor=[UIColor blackColor];
    [super touchesCancelled:touches withEvent:event];    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated]; 
}
@end
