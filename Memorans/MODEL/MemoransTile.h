//
//  MemoransTile.h
//  Memorans
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Created by emi on 01/07/14.
//
//

#import <Foundation/Foundation.h>

// From Apple docs: The NSCoding protocol declares the two methods that a class must implement so
// that instances of that class can be encoded and decoded. This capability provides the basis for
// archiving.

// From Apple docs: The NSCopying protocol declares a method for providing functional copies of an
// object. The exact meaning of “copy” can vary from class to class, but a copy must be a
// functionally independent object with values identical to the original at the time the copy was
// made.

@interface MemoransTile : NSObject <NSCopying, NSCoding>

#pragma mark - PUBLIC PROPERTIES

@property(nonatomic) NSInteger tileValue;
@property(nonatomic) NSInteger tilePoints;

// The type to which a tile belongs (es:"Happy").

@property(strong, nonatomic) NSString *tileSetType;

// The tile id to uniquely identify a tile in the game.

@property(strong, nonatomic, readonly) NSString *tileID;

// Whether the tile is currently chosen or not.

@property(nonatomic) BOOL selected;

// Whether the tile has been paired or not.

@property(nonatomic) BOOL paired;

#pragma mark - PUBLIC METHODS

// Custom comparison for 2 tiles objects.

- (BOOL)isEqualToTile:(MemoransTile *)otherTile;

// The list of available tile tile types (es:"Happy", "Angry" etc...)

+ (NSArray *)allowedTileSets;

#pragma mark - GLOBAL VARS

// The max value a tile can have (it's for identifying them inside a particular set)

extern const int gMaxTileValue;

// The min value a tile can have (it's for identifying them inside a particular set)

extern const int gMinTileValue;

@end
