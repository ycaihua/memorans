////
//  MemoransGameEngine.m
//  Memorans
//
//  Created by emi on 03/07/14.
//  Copyright (c) 2014 Emiliano D'Alterio. All rights reserved.
//

#import "MemoransGameEngine.h"
#import "MemoransTilePile.h"
#import "MemoransTile.h"

@interface MemoransGameEngine ()

#pragma mark - PROPERTIES

@property(nonatomic, strong) MemoransTile *previousSelectedTile;

@property(nonatomic, strong) MemoransTilePile *uniqueTilesPile;

@property(nonatomic, strong) NSMutableArray *tilesInGame;

@property(nonatomic) NSInteger gameScore;

@end

@implementation MemoransGameEngine

#pragma mark - SETTERS AND GETTERS

- (NSMutableArray *)tilesInGame
{
    if (!_tilesInGame)
    {
        _tilesInGame = [[NSMutableArray alloc] init];
    }
    return _tilesInGame;
}

#pragma mark - IN-GAME TILES HANDLING

- (void)addPairOfTilesToGame
{
    MemoransTile *newTile = [self.uniqueTilesPile extractRandomTileFromPile];

    [self.tilesInGame addObject:newTile];
    [self.tilesInGame addObject:[newTile copy]];
}

- (void)shuffleTilesInGame
{
    int numberOfTilesInGame = (int)[self.tilesInGame count];
    int jndex;

    for (int index = numberOfTilesInGame - 1; index > 0; index--)
    {
        jndex = arc4random() % index;
        [self.tilesInGame exchangeObjectAtIndex:jndex withObjectAtIndex:index];
    }
}

- (MemoransTile *)tileInGameAtIndex:(NSInteger)tileIndex
{
    if (tileIndex < [self.tilesInGame count])
    {
        return [self.tilesInGame objectAtIndex:tileIndex];
    }
    else
    {
        return nil;
    }
}

#pragma mark - GAMEPLAY

const int pairedBonus = 5;
const int notPairedMalus = -2;

- (MemoransTile *)playTileAtIndex:(NSInteger)tileIndex
{
    MemoransTile *selectedTile = self.tilesInGame[tileIndex];

    if (selectedTile.paired || selectedTile.selected)
    {
        return nil;
    }

    selectedTile.selected = YES;

    if (!self.previousSelectedTile)
    {
        self.previousSelectedTile = selectedTile;
    }
    else
    {
        if ([selectedTile isEqualToTile:self.previousSelectedTile])
        {
            self.gameScore += pairedBonus;
            selectedTile.paired = YES;
            self.previousSelectedTile.paired = YES;
        }
        else
        {
            self.gameScore += notPairedMalus;
            selectedTile.selected = NO;
            self.previousSelectedTile.selected = NO;
        }

        self.previousSelectedTile = nil;
    }

    return selectedTile;
}

#pragma mark - INITIALISERS

- (instancetype)initGameWithNum:(NSInteger)numOfGameTiles fromTileSet:(NSString *)tileSet
{
    self = [super init];

    if (!self)
    {
        return nil;
    }

    if (tileSet)
    {
        self.uniqueTilesPile = [[MemoransTilePile alloc] initWithSet:tileSet];
    }
    else
    {
        self.uniqueTilesPile = [[MemoransTilePile alloc] init];
    }

    if (numOfGameTiles % 2 != 0 || numOfGameTiles < 4)
    {
        numOfGameTiles = 6;
    }

    for (int i = 0; i < numOfGameTiles / 2; i++)
    {
        [self addPairOfTilesToGame];
    }

    [self shuffleTilesInGame];

    return self;
}

- (instancetype)init
{
    self = [super init];

    if (!self)
    {
        return nil;
    }

    self = [self initGameWithNum:0 fromTileSet:nil];

    return self;
}

@end