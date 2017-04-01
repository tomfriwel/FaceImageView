//
//  ViewController.m
//  FaceImageView
//
//  Created by tomfriwel on 01/04/2017.
//  Copyright © 2017 tomfriwel. All rights reserved.
//

#import "ViewController.h"
#import "FaceImageView.h"

@interface ViewController ()
@property (strong, nonatomic) FaceImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"test"];
    self.imageView = [[FaceImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    self.scrollView.contentSize = image.size;
    [self.scrollView addSubview:self.imageView];
    [self.imageView setImage:image];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
