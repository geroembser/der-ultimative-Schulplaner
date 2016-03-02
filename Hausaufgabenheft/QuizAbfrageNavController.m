//
//  QuizAbfrageNavController.m
//  Hausaufgabenheft
//
//  Created by Gero Embser on 28.02.16.
//  Copyright © 2016 Bischöfliche Marienschule Mönchengladbach. All rights reserved.
//

#import "QuizAbfrageNavController.h"
#import "QuizPageViewController.h"

@interface QuizAbfrageNavController ()

@end

@implementation QuizAbfrageNavController

#pragma mark - Initialisieren
- (instancetype)init {
    self = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"quizAbfrageNavController"];
    
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithQuiz:(Quiz *)quiz {
    self = [self init];
    
    if (self) {
        //den rootViewController für diesen NavigationController auf den QuizPageViewController setzen
        QuizPageViewController *quizPageViewController = [[QuizPageViewController alloc]initWithQuiz:quiz];
        
        [self setViewControllers:@[quizPageViewController] animated:NO];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}


@end
