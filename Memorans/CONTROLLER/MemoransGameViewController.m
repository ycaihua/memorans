//
//  MemoransGameViewController.m
//  Memorans
//
//  Created by emi on 03/07/14.
//  Copyright (c) 2014 Emiliano D'Alterio. All rights reserved.
//

#import "MemoransGameViewController.h"
#import "MemoransTileView.h"
#import "MemoransTile.h"
#import "MemoransGameEngine.h"
#import "MemoransOverlayView.h"
#import "MemoransGameLevel.h"
#import "MemoransSharedLevelsPack.h"
#import "Utilities.h"

@interface MemoransGameViewController ()

#pragma mark - OUTLETS

@property(weak, nonatomic) IBOutlet UIView *tileArea;
@property(weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property(weak, nonatomic) IBOutlet UIButton *restartGameButton;
@property(weak, nonatomic) IBOutlet UIButton *nextLevelButton;
@property(weak, nonatomic) IBOutlet UIButton *backToLevelsButton;

#pragma mark - PROPERTIES

@property(nonatomic, strong) NSMutableArray *tileViews;
@property(nonatomic, strong) NSMutableArray *tileViewsLeft;
@property(nonatomic, strong) NSMutableArray *chosenTileViews;

@property(strong, nonatomic) CAGradientLayer *gradientLayer;

@property(nonatomic, strong) MemoransGameEngine *game;

@property(nonatomic) NSInteger wobblingTilesCount;

@property(nonatomic) BOOL isBadScore;
@property(nonatomic) BOOL isGameOver;

@end

@implementation MemoransGameViewController

#pragma mark - SETTERS AND GETTERS

- (NSMutableArray *)tileViews
{
    if (!_tileViews)
    {
        _tileViews = [[NSMutableArray alloc] initWithCapacity:[self currentLevel].tilesInLevel];
    }
    return _tileViews;
}

- (NSMutableArray *)tileViewsLeft
{
    if (!_tileViewsLeft)
    {
        _tileViewsLeft = [self.tileViews mutableCopy];
    }

    return _tileViewsLeft;
}

- (NSMutableArray *)chosenTileViews
{
    if (!_chosenTileViews)
    {
        _chosenTileViews = [[NSMutableArray alloc] initWithCapacity:2];
    }

    return _chosenTileViews;
}

- (CAGradientLayer *)gradientLayer
{
    if (!_gradientLayer)
    {
        _gradientLayer = [Utilities randomGradient];

        _gradientLayer.frame = self.view.bounds;
    }

    return _gradientLayer;
}

- (MemoransGameEngine *)game
{
    if (!_game)
    {
        _game = [[MemoransGameEngine alloc] initGameWithTilesCount:[self currentLevel].tilesInLevel
                                                        andTileSet:[self currentLevel].tileSetType];
    }
    return _game;
}

- (void)setCurrentLevelNumber:(NSInteger)currentLevelNumber
{
    if (currentLevelNumber >= 0 && currentLevelNumber < [[self levelsPack] count])
    {
        _currentLevelNumber = currentLevelNumber;
    }
}

#pragma mark - ACTIONS

- (IBAction)restartGameButtonTouched
{
    [Utilities playPopSound];

    [self restartGameWithNextLevel:NO];
}

- (IBAction)nextLevelButtonTouched
{
    [Utilities playUiiiSound];

    NSInteger lastLevelIndex = [[MemoransSharedLevelsPack sharedLevelsPack].levelsPack count] - 1;

    if (self.currentLevelNumber == lastLevelIndex)
    {
        [self performSegueWithIdentifier:@"toEndController" sender:self];
    }
    else
    {
        [self restartGameWithNextLevel:YES];
    }
}

- (IBAction)backToMenuButtonTouched
{

    [Utilities playPopSound];

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - GESTURES HANDLING

- (void)tileTapped:(UITapGestureRecognizer *)tileTapRec
{
    MemoransTileView *tappedTileView = (MemoransTileView *)tileTapRec.view;

    if (tappedTileView.paired || tappedTileView.shown || [self.chosenTileViews count] == 2)
    {
        return;
    }

    [self flipAndPlayTappedTileView:tappedTileView];
}

- (void)flipAndPlayTappedTileView:(MemoransTileView *)tappedTileView
{
    [Utilities playUeeeSound];

    [UIView transitionWithView:tappedTileView
        duration:0.3f
        options:UIViewAnimationOptionTransitionFlipFromRight
        animations:^{

            [self.chosenTileViews addObject:tappedTileView];

            tappedTileView.chosen = YES;
            tappedTileView.shown = YES;
        }
        completion:^(BOOL finished) { [self playTappedTileView:tappedTileView]; }];
}

#pragma mark - GAMEPLAY

- (void)playTappedTileView:(MemoransTileView *)tappedTileView
{
    if ([self.chosenTileViews indexOfObject:tappedTileView] != 1)
    {
        return;
    }

    [self playChosenTiles];

    if (!tappedTileView.paired)
    {
        [Utilities animateOverlayView:[self addMalusScoreOverlayView] withDuration:0.3f];

        [self addWobblingAnimationToView:self.chosenTileViews[0] withRepeatCount:4];
        [self addWobblingAnimationToView:self.chosenTileViews[1] withRepeatCount:4];

        [Utilities playIiiiSound];
    }
    else if (tappedTileView.paired)
    {
        [Utilities animateOverlayView:[self addBonusScoreOverlayView] withDuration:0.3f];

        [Utilities playUiiiSound];

        for (MemoransTileView *tileView in self.chosenTileViews)
        {
            [UIView transitionWithView:tileView
                duration:0.5f
                options:UIViewAnimationOptionTransitionCurlUp
                animations:^{}
                completion:^(BOOL finished) {

                    if ([self.chosenTileViews indexOfObject:tileView] == 1)
                    {
                        [self finishAndSave];
                    }
                }];
        }
    }
}

- (void)playChosenTiles
{
    if ([self.chosenTileViews count] == 2)
    {
        NSInteger firstTappedViewIndex = [self.tileViews indexOfObject:self.chosenTileViews[0]];

        NSInteger secondTappedViewIndex = [self.tileViews indexOfObject:self.chosenTileViews[1]];

        if (firstTappedViewIndex == NSNotFound || secondTappedViewIndex == NSNotFound)
        {
            return;
        }

        [self.game playGameTileAtIndex:firstTappedViewIndex];

        [self.game playGameTileAtIndex:secondTappedViewIndex];

        [self updateUIWithNewGame:NO];
    }
}

- (void)finishAndSave
{
    if ([self.chosenTileViews count] == 2)
    {
        MemoransTileView *firstTappedTileView = ((MemoransTileView *)self.chosenTileViews[0]);
        MemoransTileView *secondTappedTileView = ((MemoransTileView *)self.chosenTileViews[1]);

        [self.chosenTileViews removeAllObjects];

        firstTappedTileView.chosen = NO;
        secondTappedTileView.chosen = NO;

        if (firstTappedTileView.paired && secondTappedTileView.paired)
        {
            [self.tileViewsLeft removeObject:firstTappedTileView];
            [self.tileViewsLeft removeObject:secondTappedTileView];
        }

        if ([self.tileViewsLeft count] != 0)
        {
            if ([self archiveGameControllerStatus])
            {
                [self currentLevel].hasSave = YES;
            }
        }
        else
        {
            [self completeLevel];
        }
    }
}

- (void)completeLevel
{
    if ([self.tileViewsLeft count] == 0)
    {
        if ([self currentLevel].hasSave)
        {
            [self deleteSavedGameControllerStatus];

            [self currentLevel].hasSave = NO;
        }

        self.isGameOver = YES;

        if (!self.isBadScore)
        {
            [self currentLevel].completed = YES;

            [self addWobblingAnimationToView:self.nextLevelButton withRepeatCount:50];

            NSArray *endMessages = @[
                NSLocalizedString(@"Well Done!", @"End message 1"),
                NSLocalizedString(@"Great!", @"End message 2"),
                NSLocalizedString(@"Excellent!", @"End message 3"),
                NSLocalizedString(@"Superb!", @"End message 4"),
                NSLocalizedString(@"Outstanding!", @"End message 5"),
                NSLocalizedString(@"Awesome!", @"End message 6")
            ];

            MemoransOverlayView *endMessageOverlayView = [self addEndMessageOverlayView];

            endMessageOverlayView.overlayString = [NSString
                stringWithFormat:@"%@", endMessages[self.game.gameScore % [endMessages count]]];

            [Utilities animateOverlayView:endMessageOverlayView withDuration:1.5f];

            [self updateUIWithNewGame:NO];
        }
        else
        {
            [self restartGameWithNextLevel:NO];
        }
    }
}

- (void)restartGameWithNextLevel:(BOOL)next
{
    if (next)
    {
        self.currentLevelNumber++;

        self.isBadScore = NO;
    }
    else
    {
        if ([self currentLevel].hasSave)
        {
            [self deleteSavedGameControllerStatus];

            [self currentLevel].hasSave = NO;
        }
    }

    [self.tileArea.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    self.tileViews = nil;
    self.tileViewsLeft = nil;
    self.chosenTileViews = nil;
    self.game = nil;

    self.wobblingTilesCount = 0;

    [self updateUIWithNewGame:YES];
}

- (void)resumeGame
{
    _game = [NSKeyedUnarchiver
        unarchiveObjectWithFile:[self filePathForArchivingWithName:@"gameStatus.archive"]];

    _tileViews = [NSKeyedUnarchiver
        unarchiveObjectWithFile:[self filePathForArchivingWithName:@"tileViewsStatus.archive"]];

    UITapGestureRecognizer *tileTapRecog;

    for (MemoransTileView *tileView in self.tileViews)
    {
        tileTapRecog =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tileTapped:)];

        tileTapRecog.numberOfTapsRequired = 1;
        tileTapRecog.numberOfTouchesRequired = 1;

        [tileView addGestureRecognizer:tileTapRecog];

        [self.tileArea addSubview:tileView];

        if (tileView.chosen)
        {
            [self.chosenTileViews addObject:tileView];
        }

        if (tileView.paired)
        {
            [self.tileViewsLeft removeObject:tileView];
        }
    }
}

- (NSArray *)levelsPack { return [MemoransSharedLevelsPack sharedLevelsPack].levelsPack; }

- (MemoransGameLevel *)currentLevel
{
    if (self.currentLevelNumber > [[self levelsPack] count] - 1)
    {
        return nil;
    }

    return (MemoransGameLevel *)[self levelsPack][self.currentLevelNumber];
}

- (MemoransGameLevel *)nextLevel
{
    if (self.currentLevelNumber + 1 > [[self levelsPack] count] - 1)
    {
        return nil;
    }

    return (MemoransGameLevel *)[self levelsPack][self.currentLevelNumber + 1];
}

#pragma mark - CAAnimation AND CAAnimation DELEGATE METHODS

- (void)addWobblingAnimationToView:(UIView *)view withRepeatCount:(float)repeatCount
{
    CABasicAnimation *wobbling = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];

    [wobbling setFromValue:@(0.08f)];

    [wobbling setToValue:@(-0.08f)];

    [wobbling setDuration:0.1f];

    [wobbling setAutoreverses:YES];

    [wobbling setRepeatCount:repeatCount];

    wobbling.delegate = self;

    [view.layer addAnimation:wobbling forKey:@"wobbling"];
}

- (void)animationDidStart:(CAAnimation *)anim { self.wobblingTilesCount++; }

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (!self.wobblingTilesCount)
    {
        return;
    }

    self.wobblingTilesCount--;

    if (!self.wobblingTilesCount)
    {
        for (MemoransTileView *tileView in self.chosenTileViews)
        {
            [UIView transitionWithView:tileView
                duration:0.3f
                options:UIViewAnimationOptionTransitionFlipFromLeft
                animations:^{ tileView.shown = NO; }
                completion:^(BOOL finished) {

                    if ([self.chosenTileViews indexOfObject:tileView] == 1)
                    {
                        [self finishAndSave];
                    }
                }];
        }
    }
}

#pragma mark - TILES SIZING AND PLACING

- (NSInteger)numOfTilesCols
{
    for (int r = 6; r >= 2; r--)
    {
        int c = ((int)[self currentLevel].tilesInLevel / r);

        if ([self currentLevel].tilesInLevel % r == 0 && r <= c)
        {
            return c;
        }
    }

    return 0;
}

- (NSInteger)numOfTilesRows
{
    for (int r = 6; r >= 2; r--)
    {
        int c = ((int)[self currentLevel].tilesInLevel / r);

        if ([self currentLevel].tilesInLevel % r == 0 && r <= c)
        {
            return r;
        }
    }

    return 0;
}

static const NSInteger gTileMargin = 5;

- (CGFloat)tileWidth
{
    NSInteger colWidth = self.tileArea.bounds.size.width / [self numOfTilesCols];

    return colWidth - gTileMargin * 2;
}

- (CGFloat)tileHeight
{
    NSInteger colHeight = self.tileArea.bounds.size.height / [self numOfTilesRows];

    return colHeight - gTileMargin * 2;
}

- (CGRect)frameForTileAtRow:(NSInteger)i Col:(NSInteger)j
{
    CGFloat colWidth = self.tileArea.bounds.size.width / self.numOfTilesCols;
    CGFloat colHeight = self.tileArea.bounds.size.height / self.numOfTilesRows;

    CGFloat frameOriginX = j * colWidth + gTileMargin;
    CGFloat frameOriginY = i * colHeight + gTileMargin;

    return CGRectMake(frameOriginX, frameOriginY, self.tileWidth, self.tileHeight);
}

#pragma mark - VIEWS MANAGEMENT AND UPDATE

- (void)updateUIWithNewGame:(BOOL)newGame
{
    if (newGame)
    {
        MemoransOverlayView *startMessageOverlayView = [self addStartMessageOverlayView];

        if ([self currentLevel].hasSave)
        {
            [self resumeGame];

            startMessageOverlayView.overlayString =
                NSLocalizedString(@"Game\nResumed", @"Start message 1");
        }
        else
        {
            [self createAndAnimateTileViews];

            if (self.isBadScore && self.isGameOver)
            {
                startMessageOverlayView.overlayString =
                    NSLocalizedString(@"Bad Score\nTry Again", @"Start message 2");

                startMessageOverlayView.overlayColor =
                    [Utilities colorFromHEXString:@"#FF1300" withAlpha:1];
            }
            else
            {
                NSString *levelString = NSLocalizedString(@"Level", @"Start message 3");

                startMessageOverlayView.overlayString = [NSString
                    stringWithFormat:@"%@ %d\n%@", levelString, (int)self.currentLevelNumber + 1,
                                     [self currentLevel].tileSetType];
            }
        }

        [self.view.layer insertSublayer:self.gradientLayer atIndex:0];

        [self.nextLevelButton.layer removeAllAnimations];

        [Utilities animateOverlayView:startMessageOverlayView withDuration:1.8f];

        self.isGameOver = NO;
    }

    if ([self.tileViews count] < 6)
    {
        [self restartGameWithNextLevel:NO];

        return;
    }

    if ([self.tileViewsLeft count] != 0)
    {
        MemoransTile *gameTile;
        NSInteger tileIndex;

        for (MemoransTileView *tileView in self.tileViews)
        {
            tileIndex = [self.tileViews indexOfObject:tileView];

            if (tileIndex != NSNotFound)
            {
                gameTile = [self.game gameTileAtIndex:tileIndex];

                tileView.imageID = gameTile.tileID;
                tileView.paired = gameTile.paired;
            }
        }
    }

    self.nextLevelButton.hidden = ![self currentLevel].completed;

    self.isBadScore = (self.game.gameScore < 0);

    self.scoreLabel.attributedText = [Utilities
        styledAttributedStringWithString:[NSString
                                             stringWithFormat:@"★ %d", (int)self.game.gameScore]
                           andAlignement:NSTextAlignmentCenter
                                andColor:nil
                                 andSize:60
                          andStrokeColor:nil];
}

- (void)createAndAnimateTileViews
{
    MemoransTileView *tileView;

    CGRect tileOnBoardFrame;

    UITapGestureRecognizer *tileTapRecog;

    NSString *tileBackImage =
        [NSString stringWithFormat:@"tileBackRibbon%d", (int)self.currentLevelNumber % 6];

    NSInteger tileYOffset;

    for (int i = 0; i < self.numOfTilesRows; i++)
    {
        for (int j = 0; j < self.numOfTilesCols; j++)
        {
            tileOnBoardFrame = [self frameForTileAtRow:i Col:j];

            tileView = [[MemoransTileView alloc] initWithFrame:tileOnBoardFrame];

            tileView.onBoardCenter = tileView.center;

            tileYOffset = arc4random() % (int)self.view.frame.size.height;

            tileView.center =
                CGPointMake(tileOnBoardFrame.origin.x + tileOnBoardFrame.size.width / 2,
                            (self.view.frame.origin.y - tileYOffset) - tileView.frame.size.height);

            tileView.tileBackImage = tileBackImage;

            tileTapRecog =
                [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tileTapped:)];

            tileTapRecog.numberOfTapsRequired = 1;
            tileTapRecog.numberOfTouchesRequired = 1;

            [tileView addGestureRecognizer:tileTapRecog];

            [self.tileViews addObject:tileView];

            [self.tileArea addSubview:tileView];

            [UIView animateWithDuration:2.0f
                                  delay:0
                 usingSpringWithDamping:0.6f
                  initialSpringVelocity:0.4f
                                options:0
                             animations:^{ tileView.center = tileView.onBoardCenter; }
                             completion:nil];
        }
    }
}

- (MemoransOverlayView *)addBonusScoreOverlayView
{
    MemoransOverlayView *bonusScoreOverlayView = [[MemoransOverlayView alloc]
        initWithString:[NSString stringWithFormat:@"+%d", (int)self.game.lastDeltaScore]
              andColor:[Utilities colorFromHEXString:@"#0BD318" withAlpha:1]
           andFontSize:300];

    [self.view addSubview:bonusScoreOverlayView];

    return bonusScoreOverlayView;
}

- (MemoransOverlayView *)addMalusScoreOverlayView
{
    MemoransOverlayView *malusScoreOverlayView = [[MemoransOverlayView alloc]
        initWithString:[NSString stringWithFormat:@"%d", (int)self.game.lastDeltaScore]
              andColor:[Utilities colorFromHEXString:@"#FF1300" withAlpha:1]
           andFontSize:300];

    [self.view addSubview:malusScoreOverlayView];

    return malusScoreOverlayView;
}

- (MemoransOverlayView *)addEndMessageOverlayView
{
    MemoransOverlayView *endMessageOverlayView =
        [[MemoransOverlayView alloc] initWithString:nil andColor:nil andFontSize:190];

    [self.view addSubview:endMessageOverlayView];

    return endMessageOverlayView;
}

- (MemoransOverlayView *)addStartMessageOverlayView
{
    MemoransOverlayView *startMessageOverlayView =
        [[MemoransOverlayView alloc] initWithString:nil andColor:nil andFontSize:190];

    [self.view addSubview:startMessageOverlayView];

    return startMessageOverlayView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tileArea.backgroundColor = [UIColor clearColor];

    NSAttributedString *restartGameString =
        [Utilities styledAttributedStringWithString:@"↺"
                                      andAlignement:NSTextAlignmentCenter
                                           andColor:nil
                                            andSize:60
                                     andStrokeColor:nil];

    [self.restartGameButton setAttributedTitle:restartGameString forState:UIControlStateNormal];

    self.restartGameButton.exclusiveTouch = YES;

    NSAttributedString *nextLevelString =
        [Utilities styledAttributedStringWithString:@"▶︎"
                                      andAlignement:NSTextAlignmentRight
                                           andColor:nil
                                            andSize:60
                                     andStrokeColor:nil];

    [self.nextLevelButton setAttributedTitle:nextLevelString forState:UIControlStateNormal];

    self.nextLevelButton.exclusiveTouch = YES;

    NSAttributedString *backToLevelsString =
        [Utilities styledAttributedStringWithString:@"⬅︎"
                                      andAlignement:NSTextAlignmentLeft
                                           andColor:nil
                                            andSize:60
                                     andStrokeColor:nil];

    [self.backToLevelsButton setAttributedTitle:backToLevelsString forState:UIControlStateNormal];

    self.backToLevelsButton.exclusiveTouch = YES;

    [self.view bringSubviewToFront:self.tileArea];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateUIWithNewGame:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[MemoransSharedLevelsPack sharedLevelsPack] archiveLevelsStatus];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [self.gradientLayer removeFromSuperlayer];

    self.gradientLayer = nil;
}

- (BOOL)prefersStatusBarHidden { return YES; }

- (void)didReceiveMemoryWarning { [super didReceiveMemoryWarning]; }

#pragma mark - ARCHIVING

- (NSString *)filePathForArchivingWithName:(NSString *)filename
{
    NSString *documentDirectory =
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];

    return [documentDirectory stringByAppendingPathComponent:filename];
}

- (BOOL)archiveGameControllerStatus
{
    BOOL gameArchiving = [NSKeyedArchiver
        archiveRootObject:self.game
                   toFile:[self filePathForArchivingWithName:@"gameStatus.archive"]];

    BOOL tileViewsArchiving = [NSKeyedArchiver
        archiveRootObject:self.tileViews
                   toFile:[self filePathForArchivingWithName:@"tileViewsStatus.archive"]];

    return (gameArchiving && tileViewsArchiving);
}

- (BOOL)deleteSavedGameControllerStatus
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSError *gameError;

    BOOL gameArchiveRemoval =
        [fileManager removeItemAtPath:[self filePathForArchivingWithName:@"gameStatus.archive"]
                                error:&gameError];

    NSError *tileError;

    BOOL tileViewsArchiveRemoval =
        [fileManager removeItemAtPath:[self filePathForArchivingWithName:@"tileViewsStatus.archive"]
                                error:&tileError];

    return (gameArchiveRemoval && tileViewsArchiveRemoval);
}

@end
