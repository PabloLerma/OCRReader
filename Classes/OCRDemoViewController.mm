//
//  OCRDemoViewController.m
//  OCRDemo
//
//  Created by Nolan Brown on 12/30/09.
//

#import "OCRDemoViewController.h"
#import "baseapi.h"
#include <math.h>
static inline double radians (double degrees) {return degrees * M_PI/180;}

@implementation OCRDemoViewController

@synthesize iv,label,urllabel;


// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization

    }
    return self;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad {
	[super viewDidLoad];
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"textura.jpg"]];
    self.view.backgroundColor = background;
    [background release];

  [self startTesseract];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[iv release];
	iv = nil;
	[label release];
	label = nil;
    [super dealloc];

}


#pragma mark -
#pragma mark IBAction
- (IBAction) takePhoto:(id) sender
{
	imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
	
	[self presentModalViewController:imagePickerController animated:YES];
}
- (IBAction) findPhoto:(id) sender
{
	imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
	
	[self presentModalViewController:imagePickerController animated:YES];
}

#pragma mark -

- (NSString *) applicationDocumentsDirectory
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *documentsDirectoryPath = [paths objectAtIndex:0];
	return documentsDirectoryPath;
}

#pragma mark -
#pragma mark Image Processsing
- (void) startTesseract
{
	//code from http://robertcarlsen.net/2009/12/06/ocr-on-iphone-demo-1043

	NSString *dataPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"tessdata"];    
	/*
	 Set up the data in the docs dir
	 want to copy the data to the documents folder if it doesn't already exist
	 */

	NSFileManager *fileManager = [NSFileManager defaultManager];
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:dataPath]) {
		// get the path to the app bundle (with the tessdata dir)
		NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
		NSString *tessdataPath = [bundlePath stringByAppendingPathComponent:@"tessdata"];
		if (tessdataPath) {
			[fileManager copyItemAtPath:tessdataPath toPath:dataPath error:NULL];
		}
	}
  
	NSString *dataPathWithSlash = [[self applicationDocumentsDirectory] stringByAppendingString:@"/"];
	setenv("TESSDATA_PREFIX", [dataPathWithSlash UTF8String], 1);
	
	// init the tesseract engine.
	tess = new TessBaseAPI();
	tess->SimpleInit([dataPath cStringUsingEncoding:NSUTF8StringEncoding],  // Path to tessdata-no ending /.
					 "plm",  // ISO 639-3 string or NULL.
					 false);
	
	
}

- (NSString *) ocrImage: (UIImage *) uiImage
{
	
	//code from http://robertcarlsen.net/2009/12/06/ocr-on-iphone-demo-1043
	
	CGSize imageSize = [uiImage size];
	double bytes_per_line	= CGImageGetBytesPerRow([uiImage CGImage]);
	double bytes_per_pixel	= CGImageGetBitsPerPixel([uiImage CGImage]) / 8.0;
	
	CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider([uiImage CGImage]));
	const UInt8 *imageData = CFDataGetBytePtr(data);
	
	// this could take a while. maybe needs to happen asynchronously.
	char* text = tess->TesseractRect(imageData,(int)bytes_per_pixel,(int)bytes_per_line, 0, 0,(int) imageSize.height,(int) imageSize.width);
	
	// Do something useful with the text!
	NSLog(@"Converted text: %@",[NSString stringWithCString:text encoding:NSUTF8StringEncoding]);
    NSString *resul = [NSString stringWithCString:text encoding:NSUTF8StringEncoding];
    [self reloadLabelurl:resul];
    
	return resul;
}


//http://www.iphonedevsdk.com/forum/iphone-sdk-development/7307-resizing-photo-new-uiimage.html#post33912
-(UIImage *)resizeImage:(UIImage *)image {
	
	CGImageRef imageRef = [image CGImage];
	CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
	CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();
	
	if (alphaInfo == kCGImageAlphaNone)
		alphaInfo = kCGImageAlphaNoneSkipLast;
	
	int width, height;
	
	width = 640;//[image size].width;
	height = 640;//[image size].height;
	
	CGContextRef bitmap;
	
	if (image.imageOrientation == UIImageOrientationUp | image.imageOrientation == UIImageOrientationDown) {
		bitmap = CGBitmapContextCreate(NULL, width, height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, alphaInfo);
		
	} else {
		bitmap = CGBitmapContextCreate(NULL, height, width, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, alphaInfo);
		
	}
	
	if (image.imageOrientation == UIImageOrientationLeft) {
		NSLog(@"image orientation left");
		CGContextRotateCTM (bitmap, radians(90));
		CGContextTranslateCTM (bitmap, 0, -height);
		
	} else if (image.imageOrientation == UIImageOrientationRight) {
		NSLog(@"image orientation right");
		CGContextRotateCTM (bitmap, radians(-90));
		CGContextTranslateCTM (bitmap, -width, 0);
		
	} else if (image.imageOrientation == UIImageOrientationUp) {
		NSLog(@"image orientation up");	
		
	} else if (image.imageOrientation == UIImageOrientationDown) {
		NSLog(@"image orientation down");	
		CGContextTranslateCTM (bitmap, width,height);
		CGContextRotateCTM (bitmap, radians(-180.));
		
	}
	
	CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef);
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	UIImage *result = [UIImage imageWithCGImage:ref];
	
	CGContextRelease(bitmap);
	CGImageRelease(ref);
	
	return result;	
}


#pragma mark -
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker 
		didFinishPickingImage:(UIImage *)image
				  editingInfo:(NSDictionary *)editingInfo
{
	
	// Dismiss the image selection, hide the picker and
	
	//show the image view with the picked image
	
	[picker dismissModalViewControllerAnimated:YES];
	UIImage *newImage = [self resizeImage:image];
	iv.image = newImage;
	NSString *text = [self ocrImage:newImage];
	label.text = text;
	
}

-(NSString *)breakStringByNewlines:(NSString *)line {
    NSArray *myarray = [line componentsSeparatedByString:@"\n"];
    NSString * result = [[myarray valueForKey:@"description"] componentsJoinedByString:@""];
    return result;
} // breakStringByNewlines

-(NSString *)removeWhiteSpaceFromLine:(NSString *)line {
    NSString *newline = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return newline;
} // removeWhiteSpaceFromLine

-(NSString *)BinaryToAsciiString:(NSString *)resul {
    //NSLog(@"String intro: %@",resul);
    NSMutableString *result = [NSMutableString string];
    const char *b_str = [resul cStringUsingEncoding:NSASCIIStringEncoding];
    char c;
    int i = 0; /* index, used for iterating on the string */
    int p = 7; /* power index, iterating over a byte, 2^p */
    int d = 0; /* the result character */
     while ((c = b_str[i])) { /* get a char */
        if (p == 0) { /* if it's a space, save the char + reset indexes */
            if (c == '1') d += pow(2, p);
            //NSLog(@"numerito: %d",d);
            [result appendFormat:@"%c", d];
            p = 7; d = 0;
        } else { /* else add its value to d and decrement
                   p for the next iteration */
            if (c == '1') d += pow(2, p);
            --p;
            //NSLog(@"traza 2: %@",result);
        }
        ++i;
    } [result appendFormat:@"%c", d]; /* this saves the last byte */

    //NSLog(@"traza 3: %@",result);
    return [NSString stringWithString:result];
}

-(void)reloadLabelurl:(NSString *)text {
    NSString *direccion = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSLog(@"ñeñe: %@",direccion);
    NSString *nueva = [self breakStringByNewlines:direccion];
    NSLog(@"JAJA: %@",nueva);
    
    NSString *finalString = [[[[nueva stringByReplacingOccurrencesOfString:@"◣" withString:@"0"] stringByReplacingOccurrencesOfString:@"◢" withString:@"0"]stringByReplacingOccurrencesOfString:@"◥" withString:@"1"]stringByReplacingOccurrencesOfString:@"◤" withString:@"1"];
    
    NSLog(@"JOJO: %@",finalString);
    
    NSString *ultimo = [self BinaryToAsciiString:finalString];
    
    NSLog(@"Last one: %@",ultimo);
    NSString *url = @"http://is.gd"; 
    NSString *urlcompleta = [NSString stringWithFormat:@"%@/%@/", url, ultimo];
    
    NSLog(@"Dirección web: %@", urlcompleta)    ;
    dirurl = urlcompleta;
    urllabel.text = dirurl;
}

-(IBAction)abrirWeb:(id)sender
{
    if (dirurl!=NULL) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dirurl]];
        
    }
    NSLog(@"Saliendo del método abrirWeb...")    ;
}

@end
