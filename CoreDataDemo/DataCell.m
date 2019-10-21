//
//  DataCell.m
//  CoreDataDemo
//
//  Created by hello on 2019/10/19.
//  Copyright © 2019 Dio. All rights reserved.
//

#import "DataCell.h"

@interface DataCell()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sexLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *heightLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@end

@implementation DataCell

- (void)awakeFromNib {
    [super awakeFromNib];

}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.nameLabel.text = [NSString stringWithFormat:@"%@",self.model.name];
    self.sexLabel.text = [NSString stringWithFormat:@"性别:%@",self.model.sex];
    self.ageLabel.text = [NSString stringWithFormat:@"年龄:%hd",self.model.age];
    self.heightLabel.text = [NSString stringWithFormat:@"身高:%.1f",self.model.height];
    self.numberLabel.text = [NSString stringWithFormat:@"分数:%hd",self.model.number];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

@end
