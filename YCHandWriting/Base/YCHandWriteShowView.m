//
//  YCHandWriteShowView.m
//  YCHandWriting
//
//  Created by mac on 2017/8/2.
//  Copyright © 2017年 HYC. All rights reserved.
//

#import "YCHandWriteShowView.h"

@interface YCHandWriteShowView ()
@property (nonatomic, strong) NSMutableArray *strokes;

@end
@implementation YCHandWriteShowView

#pragma mark - Custom Accessor
- (NSMutableArray *)strokes{
    if (_strokes == nil) {
        _strokes = [[NSMutableArray alloc] init];
    }
    return _strokes;
}

#pragma mark ------------------- Privacy ----------------------
// 采集点集
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        NSMutableArray *newStackOfPoints = [NSMutableArray array];
        [newStackOfPoints addObject:[NSValue valueWithCGPoint:[touch locationInView:self]]];
        [self.strokes addObject:newStackOfPoints];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        [[self.strokes lastObject] addObject:[NSValue valueWithCGPoint:[touch locationInView:self]]];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch* touch in touches) {
        [[self.strokes lastObject] addObject:[NSValue valueWithCGPoint:[touch locationInView:self]]];
    }
}




/*
 // 插入数据库
 - (int)insertChar:(CharacterModel *)model {
 int charId = 0;
 [self.hanziDb executeUpdate:@"insert into characters(chinese, pinyin, pointsString) values(?,?,?)", model.chinese, model.pinyin, model.pointsString];
 
 NSString *queryString = [NSString stringWithFormat:@"select id from characters where chinese = '%@'", model.chinese];
 FMResultSet* set = [self.hanziDb executeQuery:queryString];
 
 if([set next]) {
 charId = [set intForColumn:@"id"];
 }
 for (int i=0; i<model.inputPointGrids.count; i++) {
 NSArray *aStroke = model.inputPointGrids[i];
 for (NSValue *aPointValue in aStroke) {
 CGPoint aPoint = [aPointValue CGPointValue];
 [self.hanziDb executeUpdate:@"insert into points(id, pointX, pointY, strokeid) values(?,?,?,?)", [NSNumber numberWithInt:charId],[NSNumber numberWithInt:(int)aPoint.x],[NSNumber numberWithInt:(int)aPoint.y], [NSNumber numberWithInt:i+1]];
 }
 }
 return charId;
 }

 
 
 // 取相对坐标
 - (void)turnToGrids {
 self.strokeCount = self.inputStrokes.count;
 // 格子宽度
 float gridWidth = kScreenWidth/10;
 for (int k=0; k<self.inputStrokes.count; k++) {
 // 存储一个笔画的所有点到一个数组
 NSMutableArray *strokPointGrids = [NSMutableArray array];
 NSArray *inputStrokesArray = self.inputStrokes[k];
 for (int l = 0; l<inputStrokesArray.count; l++) {
 NSValue *value = inputStrokesArray[l];
 if (l == 0) {
 [self.strokeStartPoints addObject:value];
 }
 if (l == self.inputStrokes.count-1) {
 [self.strokeEndPoints addObject:value];
 }
 CGPoint point = [value CGPointValue];
 CGPoint grid = CGPointMake(ceil(point.x/gridWidth), ceil(point.y/gridWidth));
 BOOL shouldAdd = NO;
 if (strokPointGrids.count == 0) {
 shouldAdd = YES;
 } else {
 NSValue *lastValue = strokPointGrids.lastObject;
 CGPoint lastGrid = [lastValue CGPointValue];
 if (lastGrid.x != grid.x || lastGrid.y != grid.y) {
 shouldAdd = YES;
 }
 }
 if (shouldAdd) {
 [strokPointGrids addObject:[NSValue valueWithCGPoint:grid]];
 if (![self.pointsString isEqualToString: @""] && ![self.pointsString hasSuffix:@"*"]) {
 [self.pointsString appendString:[NSString stringWithFormat:@"|"]];
 }
 [self.pointsString appendString:[NSString stringWithFormat:@"%d,%d", (int)grid.x, (int)grid.y]];
 }
 }
 if (k != self.inputStrokes.count-1) {
 [self.pointsString appendString:@"*"];
 }
 [self.inputPointGrids addObject:strokPointGrids];
 }
 }
 
 // 最终的查询语句
 NSString *queryString4 = [NSString stringWithFormat:@"select a.strokeid as strokeid,a.samecount as samecount,a.ucount as ucount,a.pcount as pcount from ( select strokeid, count(*) as samecount, (select count(*) from input_points where id=p.id and strokeid= %d ) as ucount, (select count(*) from points where id=p.id and strokeid=p.strokeid) as pcount from points p where exists(select * from input_points u where u.id=p.id and u.strokeid=%d and (abs(u.pointX-p.pointX) + abs(u.pointY-p.pointY))<2 ) and p.strokeid not in (%@) and p.id=%d group by strokeid ) a order by abs(a.pcount - a.samecount) asc", j, j, hasStrokeid, model.charID];

*/

@end
