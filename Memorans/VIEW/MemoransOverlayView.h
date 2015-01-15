//
//  MemoransScoreOverlayView.h
//  Memorans
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.
//
//  Created by emi on 21/07/14.
//
//

#import <UIKit/UIKit.h>

@interface MemoransOverlayView : UIView

#pragma mark - PUBLIC PROPERTIES

// The actual text displayed by the overlay view.

@property(strong, nonatomic) NSString *overlayString;

// The overlay text colour.

@property(strong, nonatomic) UIColor *overlayColor;

// The overlay text font size.

@property(nonatomic) CGFloat fontSize;

#pragma mark - INIT

// A handy initialiser to get a totally configured overlay view.

- (instancetype)initWithString:(NSString *)string
                      andColor:(UIColor *)color
                   andFontSize:(CGFloat)fontSize;

@end
