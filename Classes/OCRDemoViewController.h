//
//  OCRDemoViewController.h
//  OCRDemo
//
//  Created by Nolan Brown on 12/30/09.

//

#import <UIKit/UIKit.h>
#import "baseapi.h"

@interface OCRDemoViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
	UIImagePickerController *imagePickerController;
	TessBaseAPI *tess;
	UIImageView *iv;
	UILabel *label;
    UILabel *urllabel;
    NSString *dirurl;
}
@property (nonatomic, retain) IBOutlet UIImageView *iv;
@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UILabel *urllabel;


- (IBAction) findPhoto:(id) sender;
- (IBAction) takePhoto:(id) sender;

- (void) startTesseract;
- (void) reloadLabelurl:(NSString *)text;
- (NSString *) applicationDocumentsDirectory;
- (NSString *) ocrImage: (UIImage *) uiImage;
-(UIImage *)resizeImage:(UIImage *)image;
-(IBAction)abrirWeb:(id)sender;
-(NSString *)breakStringByNewlines:(NSString *)line;
-(NSString *)removeWhiteSpaceFromLine:(NSString *)line;
-(NSString *)BinaryToAsciiString:(NSString *)resul;

@end

