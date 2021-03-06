//
//  ControlViewController.mm
//  ControlLab
//
//  Created by Pablo Casado Varela on 19/02/13.
//  Copyright (c) 2013 Pablo Casado Varela. All rights reserved.
//

#import "ControlViewController.h"

@interface ControlViewController ()

@end

@implementation ControlViewController{
    NSArray *textures;
    GLKTextureInfo *textureFront;
    GLKTextureInfo *textureLeft;
    GLKTextureInfo *textureBack;
    GLKTextureInfo *textureRight;
    GLKTextureInfo *textureTop;
    GLKTextureInfo *textureBottom;
    NSOperationQueue *queueAccelerometer;
    NSOperationQueue *queueGyroscope;
    float factor;
    float factorUpDown;
    float ant;
    float antUpDown;
    float kFactorUpdate;

    UISwitch *onoff;
    GLfloat __modelview[16];
    GLfloat __projection[16];
    GLint __viewport[4];
    NSMutableArray *devices;
}

#pragma mark - Data Structures

#define kFilteringFactor 0.1
#define kAccelerometerFrequency 60.0 //Hz

#define kYMaxLandscapeRight 768.0
#define kXMaxLandscapeRight 1028.0

@synthesize baseEffect;
@synthesize glView;


typedef enum {
    kFaceFront = 0,
    kFaceLeft = 1,
    kFaceBack = 2,
    kFaceRight = 3,
    kFaceBottom = 4,
    kFaceTop = 5
} kFaceCubeType;




static const GLfloat textureCoordinates [] = {
    1.0,0.0,
    1.0,1.0,
    0.0,0.0,
    0.0,1.0
};

static const SceneVertex cubeFrontVertex [] = {
    {{-5.0f, -5.0f, 5.0f}, { 0.1f, 0.1f, 0.1f, 1.0f}},//0
    {{-5.0f,  5.0f, 5.0f}, { 0.1f, 0.1f, 0.1f, 1.0f}},//1
    {{ 5.0f, -5.0f, 5.0f}, { 0.1f, 0.1f, 0.1f, 1.0f}},//2
    {{ 5.0f,  5.0f, 5.0f}, { 0.1f, 0.1f, 0.1f, 1.0f}} //3
};
static const SceneVertex cubeRightVertex [] = {
    {{-5.0f, -5.0f,-5.0f}, { 0.1f, 0.1f, 0.1f, 1.0f}},//4
    {{-5.0f,  5.0f,-5.0f}, { 0.1f, 0.1f, 0.1f, 1.0f}},//5
    {{-5.0f, -5.0f, 5.0f}, { 0.1f, 0.1f, 0.1f, 1.0f}},//6
    {{-5.0f,  5.0f, 5.0f}, { 0.1f, 0.1f, 0.1f, 1.0f}} //7
};
static const SceneVertex cubeBackVertex [] = {
    {{ 5.0f, -5.0f,-5.0f}, { 0.1f, 0.1f, 0.1f, 1.0f}},//8
    {{ 5.0f,  5.0f,-5.0f}, { 0.1f, 0.1f, 0.1f, 1.0f}},//9
    {{-5.0f, -5.0f,-5.0f}, { 0.1f, 0.1f, 0.1f, 1.0f}},//10
    {{-5.0f,  5.0f,-5.0f}, { 0.1f, 0.1f, 0.1f, 1.0f}} //11
};
static const SceneVertex cubeLeftVertex [] = {
    {{ 5.0f, -5.0f, 5.0f}, { 0.1f, 0.1f, 0.1f, 1.0f}},//12
    {{ 5.0f,  5.0f, 5.0f}, { 0.1f, 0.1f, 0.1f, 1.0f}},//13
    {{ 5.0f, -5.0f,-5.0f}, { 0.1f, 0.1f, 0.1f, 1.0f}},//14
    {{ 5.0f,  5.0f,-5.0f}, { 0.1f, 0.1f, 0.1f, 1.0f}} //15
};
static const SceneVertex cubeBottomVertex [] = {
    {{-5.0f, -5.0f,-5.0f}, { 0.0f, 0.1f, 0.1f, 1.0f}},//16
    {{-5.0f, -5.0f, 5.0f}, { 0.0f, 0.1f, 0.1f, 1.0f}},//17
    {{ 5.0f, -5.0f,-5.0f}, { 0.0f, 0.1f, 0.1f, 1.0f}},//18
    {{ 5.0f, -5.0f, 5.0f}, { 0.0f, 0.1f, 0.1f, 1.0f}} //19
};
static const SceneVertex cubeTopVertex [] = {
    {{-5.0f,  5.0f, 5.0f}, { 0.1f, 0.1f, 0.1f, 1.0f}},//20
    {{-5.0f,  5.0f,-5.0f}, { 0.1f, 0.1f, 0.1f, 1.0f}},//21
    {{ 5.0f,  5.0f, 5.0f}, { 0.1f, 0.1f, 0.1f, 1.0f}},//22
    {{ 5.0f,  5.0f,-5.0f}, { 0.1f, 0.1f, 0.1f, 1.0f}} //23
};


static const SceneVertex windowsA [] = {
    {{-1.35f, -0.5f, 4.95f}, { 0.1f, 0.1f, 0.1f, 0.6f}},//0
    {{-1.35f,  2.3f, 4.95f}, { 0.1f, 0.1f, 0.1f, 0.6f}},//1
    {{ 0.2f, -0.5f, 4.95f}, { 0.1f, 0.1f, 0.1f, 0.6f}},//2
    {{ 0.2f,  2.3f, 4.95f}, { 0.1f, 0.1f, 0.1f, 0.6f}} //3
};
// Panel Television
static const SceneVertex panelTV [] = {
    {{ 1.8f, -1.6f, -5.0f}, { 0.1f, 0.1f, 0.1f, 0.6f}},//0
    {{ 1.8f,  1.7f, -5.0f}, { 0.1f, 0.1f, 0.1f, 0.6f}},//1
    {{-1.5f, -1.6f, -5.0f}, { 0.1f, 0.1f, 0.1f, 0.6f}},//2
    {{-1.5f,  1.7f, -5.0f}, { 0.1f, 0.1f, 0.1f, 0.6f}} //3
};
// Persiana 31
static const SceneVertex blind31 [] = {
    {{ 5.0f, -0.6f, -2.8f}, { 0.1f, 0.1f, 0.1f, 0.6f}},//0
    {{ 5.0f,  5.0f, -2.8f}, { 0.1f, 0.1f, 0.1f, 0.6f}},//1
    {{ 2.8f, -0.6f, -5.0f}, { 0.1f, 0.1f, 0.1f, 0.6f}},//2
    {{ 2.8f,  3.3f, -5.0f}, { 0.1f, 0.1f, 0.1f, 0.6f}} //3
};
// Persiana 32
static const SceneVertex blind32 [] = {
    {{ 5.0f, -1.0f,  4.0f}, { 0.1f, 0.1f, 0.1f, 0.6f}},//0
    {{ 5.0f,  5.0f,  4.0f}, { 0.1f, 0.1f, 0.1f, 0.6f}},//1
    {{ 5.0f, -1.0f, -2.0f}, { 0.1f, 0.1f, 0.1f, 0.6f}},//2
    {{ 5.0f,  5.0f, -2.0f}, { 0.1f, 0.1f, 0.1f, 0.6f}} //3
};
// Persiana 32
static const SceneVertex blind33 [] = {
    {{ 2.2f, -0.5f, 5.0f}, { 0.1f, 0.1f, 0.1f, 0.6f}},//0
    {{ 2.2f,  2.5f, 5.0f}, { 0.1f, 0.1f, 0.1f, 0.6f}},//1
    {{ 5.0f, -0.5f, 5.0f}, { 0.1f, 0.1f, 0.1f, 0.6f}},//2
    {{ 5.0f,  5.0f, 5.0f}, { 0.1f, 0.1f, 0.1f, 0.6f}} //3
};

static const SceneVertex windowsB [] = {
    {{ 2.2f, -0.5f, 5.0f}, { 0.1f, 0.1f, 0.1f, 0.6f}},//0
    {{ 2.2f,  2.5f, 5.0f}, { 0.1f, 0.1f, 0.1f, 0.6f}},//1
    {{ 5.0f, -0.5f, 5.0f}, { 0.1f, 0.1f, 0.1f, 0.6f}},//2
    {{ 5.0f,  5.0f, 5.0f}, { 0.1f, 0.1f, 0.1f, 0.6f}} //3
};

static const SceneVertex light29 [] = {
    {{-3.0f,  5.0f, 3.0f}, { 1.0f, 0.1f, 0.1f, 0.6f}},//20
    {{-3.0f,  5.0f,-0.7f}, { 1.0f, 0.1f, 0.1f, 0.6f}},//21
    {{ 0.7f,  5.0f, 3.0f}, { 1.0f, 0.1f, 0.1f, 0.6f}},//22
    {{ 0.7f,  5.0f,-0.7f}, { 1.0f, 0.1f, 0.1f, 0.6f}} //23
};

static const SceneVertex doorA [] = {
    {{-3.9f, -1.35f, 4.95f}, { 0.1f, 0.1f, 0.1f, 0.6f}},//0
    {{-3.9f,  1.7f, 4.95f}, { 0.1f, 0.1f, 0.1f, 0.6f}},//1
    {{-2.4f, -1.35f, 4.95f}, { 0.1f, 0.1f, 0.1f, 0.6f}},//2
    {{-2.4f,  1.7f, 4.95f}, { 0.1f, 0.1f, 0.1f, 0.6f}} //3
};

#pragma mark - Actualization Data Rotation

- (void) updateFactor:(float)fact {
    factor += fact;
}

- (void) updateFactorUpDown:(float)fact {
    factorUpDown += fact;

    if (factorUpDown > 3.14/2 ) {
        factorUpDown = 3.14/2;
    }
    else if (factorUpDown < -3.14/2) {
        factorUpDown = -3.14/2;
    }
}

- (void)pan:(UIPanGestureRecognizer *)gesture {
    float x = [gesture locationInView:self.view].x;
    float y = [gesture locationInView:self.view].y;

    float fromLeftToRight = x - ant;
    float fromUptoDown = y - antUpDown;

    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *activo;
    if (standardUserDefaults) {
        activo = [[NSNumber alloc] init] ;
        activo = [standardUserDefaults objectForKey:@"panGesture"];

    }
    if ([activo isEqualToNumber:[NSNumber numberWithInt:1]]) {
        if (fromLeftToRight > 0.5) {
            [self updateFactor:0.03];

        }
        else if (fromLeftToRight < -0.5){
            [self updateFactor:-0.03];

        }
        else
            [self updateFactor:0.0];

        if (fromUptoDown > 0.5) {
            [self updateFactorUpDown:-0.03];

        }
        else if (fromUptoDown < -0.5){
            [self updateFactorUpDown:0.03];
            
        }
        else
            [self updateFactorUpDown:0.0];
        ant = x;
        antUpDown = y;

    }



}

- (void)tap:(UIPanGestureRecognizer *)gesture {

    CGPoint point = [gesture locationInView:self.view];

    [self getOGLPos:point];

}

- (void)getMatrixOpenGL {
    __viewport[0] = 0;
    __viewport[1] = 0;
    __viewport[2] = 1024;
    __viewport[3] = 768;


    GLKMatrix4 modelview = baseEffect.transform.modelviewMatrix;
    GLKMatrix4 projection = baseEffect.transform.projectionMatrix;


    __modelview[0] = modelview.m00; __projection[0] = projection.m00;
    __modelview[1] = modelview.m01; __projection[1] = projection.m01;
    __modelview[2] = modelview.m02; __projection[2] = projection.m02;
    __modelview[3] = modelview.m03; __projection[3] = projection.m03;
    __modelview[4] = modelview.m10; __projection[4] = projection.m10;
    __modelview[5] = modelview.m11; __projection[5] = projection.m11;
    __modelview[6] = modelview.m12; __projection[6] = projection.m12;
    __modelview[7] = modelview.m13; __projection[7] = projection.m13;
    __modelview[8] = modelview.m20; __projection[8] = projection.m20;
    __modelview[9] = modelview.m21; __projection[9] = projection.m21;
    __modelview[10] = modelview.m22; __projection[10] = projection.m22;
    __modelview[11] = modelview.m23; __projection[11] = projection.m23;
    __modelview[12] = modelview.m30; __projection[12] = projection.m30;
    __modelview[13] = modelview.m31; __projection[13] = projection.m31;
    __modelview[14] = modelview.m32; __projection[14] = projection.m32;
    __modelview[15] = modelview.m33; __projection[15] = projection.m33;

}

-(void) getOGLPos:(CGPoint)winPos {

    //    float coord[4][3];
    //    [self getMatrixOpenGL];


    for (ControlLabNSDevice *d in devices) {
        [self getMatrixOpenGL];

        if ([d isSelected:winPos withModelview:__modelview andProjection:__projection andViewPort:__viewport]) {
            NSLog(@"Tocado Device: %@", [d getName]);
            if ([d getTypeOfDevice] == kWindows) {
                [self drawInterfaceDeviceWindow:[d getIdentificador]];
            }
            if ([d getTypeOfDevice] == kDoors) {
                [self drawInterfaceDeviceDoor:[d getIdentificador]];
            }
            if ([d getTypeOfDevice] == kPannel) {
                [self drawInterfaceDevicePannel:[d getIdentificador]];
            }
            if ([d getTypeOfDevice] == kLight) {
                [self drawInterfaceDeviceLight:[d getIdentificador]];
            }
        }
    }
/*
    // Distinguir Portrait y Lanscape
    // Control Device Orientation
    UIInterfaceOrientation isOrientation = self.interfaceOrientation;
    if (isOrientation == UIInterfaceOrientationPortrait) {

    }
    else if (isOrientation == UIInterfaceOrientationPortraitUpsideDown) {

    }
    else if (isOrientation == UIInterfaceOrientationLandscapeLeft) {
        NSLog(@"Landscape Left");
    }
    else if (isOrientation == UIInterfaceOrientationLandscapeRight) {

        //        NSLog(@"Touch: X: %.f, Y: %.f", winPos.x, winPos.y);


        //NSLog(@"############# PUERTA #############");
        // DETECCION PUERTA
        glhProjectf(-3.9f, 1.7f, 4.95f, __modelview, __projection, __viewport, coord[0]);
        //NSLog(@"Esquina Superior Derecha puerta X: %.f, Y: %.f, Z: %f", coord[0][0], (float)__viewport[3] - coord[0][1], coord[0][2]);

        glhProjectf(-2.4f, 1.7f, 4.95f, __modelview, __projection, __viewport, coord[1]);
        //NSLog(@"Esquina Superior Izquierda puerta X: %.f, Y: %.f, Z: %f", coord[1][0], (float)__viewport[3] - coord[1][1], coord[1][2]);

        glhProjectf(-3.9f, -1.35f, 4.95f, __modelview, __projection, __viewport, coord[2]);
        //NSLog(@"Esquina inferior Derecha puerta X: %.f, Y: %.f, Z: %f", coord[2][0], (float)__viewport[3] - coord[2][1], coord[2][2]);

        glhProjectf(-2.4f, -1.35f, 4.95f, __modelview, __projection, __viewport, coord[3]);
        //NSLog(@"Esquina inferior izquierda puerta X: %.f, Y: %.f, Z: %f", coord[3][0], (float)__viewport[3] - coord[3][1], coord[3][2]);

        float xMin, xMax, yMin, yMax, zCoordinate;
        xMin = yMin = 1028.0;
        xMax = yMax = zCoordinate = 0.0;
        for (int i = 0; i < 4; i++) {
            if (coord[i][0] > xMax) {
                xMax = coord[i][0];
            }
            if (coord[i][0] < xMin) {
                xMin = coord[i][0];
            }
            if ((float)__viewport[3] - coord[i][1] > yMax) {
                yMax = (float)__viewport[3] - coord[i][1];
            }
            if ((float)__viewport[3] - coord[i][1] < yMin) {
                yMin = (float)__viewport[3] - coord[i][1];
            }
            if (coord[i][2] < 0.0 || coord[i][2] > 1.0) {
                zCoordinate = coord[i][2];
            }

        }


        if (yMin < 0.0) {
            yMin = 0.0;
        }
        if (yMax > kYMaxLandscapeRight) {
            yMax = kYMaxLandscapeRight;
        }
        if (xMin < 0.0) {
            xMin = 0.0;
        }
        if (xMax > kXMaxLandscapeRight) {
            xMax = kXMaxLandscapeRight;
        }

        NSLog(@"X Max: %.f, Min: %.f", xMax, xMin);
        NSLog(@"Y Max: %.f, Min: %.f", yMax, yMin);
        NSLog(@"Touch X: %f, Y: %f", winPos.x, winPos.y);


        if (winPos.x > xMin && winPos.x < xMax) {
            if (winPos.y > yMin && winPos.y < yMax) {
                if (zCoordinate == 0.0) {
                    //                    NSLog(@"Puerta Tocada");
                    //                    NSLog(@"Coordenada Z: %f", zCoordinate);
                    [self drawInterfaceDeviceDoor];
                            }

            }
        }


        // DETECCION VENTANA
        //        NSLog(@"############# VENTANA #############");
        glhProjectf(-1.35f, 2.3f, 4.95f, __modelview, __projection, __viewport, coord[0]);
        //        NSLog(@"Esquina Superior Derecha Ventana X: %.f, Y: %.f, Z: %f", coord[0][0], (float)__viewport[3] - coord[0][1], coord[0][2]);

        glhProjectf(0.2f, 2.3f, 4.95f, __modelview, __projection, __viewport, coord[1]);
        //        NSLog(@"Esquina Superior Izquierda Ventana X: %.f, Y: %.f, Z: %f", coord[1][0], (float)__viewport[3] - coord[1][1], coord[1][2]);

        glhProjectf(-1.35f, -0.5f, 4.95f, __modelview, __projection, __viewport, coord[2]);
        //        NSLog(@"Esquina inferior Derecha Ventana X: %.f, Y: %.f, Z: %f", coord[2][0], (float)__viewport[3] - coord[2][1], coord[2][2]);

        glhProjectf(0.2f, -0.5f, 4.95f, __modelview, __projection, __viewport, coord[3]);
        //        NSLog(@"Esquina inferior izquierda Ventana X: %.f, Y: %.f, Z: %f", coord[3][0], (float)__viewport[3] - coord[3][1], coord[3][2]);


        xMin = yMin = 1028.0;
        xMax = yMax = zCoordinate = 0.0;
        for (int i = 0; i < 4; i++) {

            if (coord[i][0] > xMax) {
                xMax = coord[i][0];
            }
            if (coord[i][0] < xMin) {
                xMin = coord[i][0];
            }
            if ((float)__viewport[3] - coord[i][1] > yMax) {
                yMax = (float)__viewport[3] - coord[i][1];
            }
            if ((float)__viewport[3] - coord[i][1] < yMin) {
                yMin = (float)__viewport[3] - coord[i][1];
            }
            if (coord[i][2] < 0.0 || coord[i][2] > 1.0) {
                zCoordinate = coord[i][2];
            }

        }

        if (yMin < 0.0) {
            yMin = 0.0;
        }
        if (yMax > kYMaxLandscapeRight) {
            yMax = kYMaxLandscapeRight;
        }
        if (xMin < 0.0) {
            xMin = 0.0;
        }
        if (xMax > kXMaxLandscapeRight) {
            xMax = kXMaxLandscapeRight;
        }
        NSLog(@"X Max: %.f, Min: %.f", xMax, xMin);
        NSLog(@"Y Max: %.f, Min: %.f", yMax, yMin);
        NSLog(@"Touch X: %f, Y: %f", winPos.x, winPos.y);


        if (winPos.x > xMin && winPos.x < xMax) {
            if (winPos.y > yMin && winPos.y < yMax) {

                if (zCoordinate == 0.0 ) {
                    //                    NSLog(@"Ventana Tocada");
                    //                    NSLog(@"Coordenada Z: %f", zCoordinate);
                    [self drawInterfaceDeviceWindow];

                }

            }
        }
        

    }
 */
}

- (void) drawInterfaceDeviceDoor:(NSString *)device {
    ControlLabkDoorViewController *vc = [[ControlLabkDoorViewController alloc] initWithNibName:nil bundle:nil];
    [vc getIdentify:device];
    popover = [[UIPopoverController alloc ]initWithContentViewController:vc];
    popover.delegate = self;
    popover.popoverContentSize = CGSizeMake(300, 600);
    [popover presentPopoverFromRect:CGRectMake(0, 0, 300, 300) inView:self.view permittedArrowDirections: 0 animated:YES];


}

- (void) drawInterfaceDeviceWindow:(NSString *)device {
    ControlLabkWindowViewController *vc = [[ControlLabkWindowViewController alloc] initWithNibName:nil bundle:nil];
    [vc getIdentify:device];
    popover = [[UIPopoverController alloc ]initWithContentViewController:vc];
    popover.delegate = self;
    popover.popoverContentSize = CGSizeMake(300, 600);
    [popover presentPopoverFromRect:CGRectMake(0, 0, 300, 300) inView:self.view permittedArrowDirections: 0 animated:YES];

}

- (void) drawInterfaceDevicePannel:(NSString *)device {
    ControlLabkPannelViewController *vc = [[ControlLabkPannelViewController alloc] initWithNibName:nil bundle:nil];
    [vc getIdentify:device];
    popover = [[UIPopoverController alloc ]initWithContentViewController:vc];
    popover.delegate = self;
    popover.popoverContentSize = CGSizeMake(300, 620);
    [popover presentPopoverFromRect:CGRectMake(0, 0, 300, 650) inView:self.view permittedArrowDirections: 0 animated:YES];

}
- (void) drawInterfaceDeviceLight:(NSString *)device {

    ControlLabkLightViewController *vc = [[ControlLabkLightViewController alloc] initWithNibName:nil bundle:nil];
    [vc getIdentify:device];
    popover = [[UIPopoverController alloc ]initWithContentViewController:vc];
    popover.delegate = self;
    popover.popoverContentSize = CGSizeMake(300, 600);
    [popover presentPopoverFromRect:CGRectMake(0, 0, 300, 300) inView:self.view permittedArrowDirections: 0 animated:YES];

}



-(void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    NSLog(@"Popover dismissed");
}


- (void)viewDidLoad {
    [super viewDidLoad];



    // Do any additional setup after loading the view, typically from a nib.

    factor = 0.0;
    factorUpDown = 0.0;
    kFactorUpdate = 0.01;

    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View Controller´s view is not a GLKView");

    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:view.context];

    self.delegate = self;

    baseEffect = [[GLKBaseEffect alloc] init];

    // Cargo Texturas
    [self loadTextures];

    // Cargo Gyroscope
    [self loadGyroscope];


    // Añado reconocimiento de arrastre de imagen
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:panGesture];
    // Añado reconocimiento de tap de imagen
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tapGesture];

    ControlLabCustomToolBar *toolbar = [[ControlLabCustomToolBar alloc] init];


    [self.view addSubview:toolbar];


    // Create devices
    devices = [[NSMutableArray alloc] init];

    ControlLabNSDevice *door = [[ControlLabNSDevice alloc] initWithFirstCoordinate:doorA[0] andSecond:doorA[1] andThird:doorA[2] andFourth:doorA[3]];
    [door setIdDevice:@"" andName:@"Front Door" andType:kDoors];
    [devices addObject:door];
    ControlLabNSDevice *window = [[ControlLabNSDevice alloc] initWithFirstCoordinate:windowsA[0] andSecond:windowsA[1] andThird:windowsA[2] andFourth:windowsA[3]];
    [window setIdDevice:@"" andName:@"Blind" andType:kWindows];
    [devices addObject:window];

    ControlLabNSDevice *window1 = [[ControlLabNSDevice alloc] initWithFirstCoordinate:blind31[0] andSecond:blind31[1] andThird:blind31[2] andFourth:blind31[3]];
    [window1 setIdDevice:@"31" andName:@"Blind" andType:kWindows];
    [devices addObject:window1];

    ControlLabNSDevice *window2 = [[ControlLabNSDevice alloc] initWithFirstCoordinate:blind32[0] andSecond:blind32[1] andThird:blind32[2] andFourth:blind32[3]];
    [window2 setIdDevice:@"32" andName:@"Blind" andType:kWindows];
    [devices addObject:window2];

    ControlLabNSDevice *window3 = [[ControlLabNSDevice alloc] initWithFirstCoordinate:blind33[0] andSecond:blind33[1] andThird:blind33[2] andFourth:blind33[3]];
    [window3 setIdDevice:@"33" andName:@"Blind" andType:kWindows];
    [devices addObject:window3];

    ControlLabNSDevice *pannel = [[ControlLabNSDevice alloc] initWithFirstCoordinate:panelTV[0] andSecond:panelTV[1] andThird:panelTV[2] andFourth:panelTV[3]];
    [pannel setIdDevice:@"5" andName:@"Pannel" andType:kPannel];
    [devices addObject:pannel];
    
    ControlLabNSDevice *light1 = [[ControlLabNSDevice alloc] initWithFirstCoordinate:light29[0] andSecond:light29[1] andThird:light29[2] andFourth:light29[3]];
    [light1 setIdDevice:@"29" andName:@"Lighting" andType:kLight];
    [devices addObject:light1];

}


#pragma mark - Gyroscope Inicializa la carga de los datos del giroscopio

- (void) loadGyroscope {

    CMMotionManager *mm = [[CMMotionManager alloc] init];
    ControlLabAppDelegate *appDelegate = (ControlLabAppDelegate *)[[UIApplication sharedApplication] delegate];

    mm = appDelegate.mm;
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *activo;
    if (standardUserDefaults) {
        activo = [[NSNumber alloc] init] ;
        activo = [standardUserDefaults objectForKey:@"gyroscope"];

    }
    if ([activo isEqualToNumber:[NSNumber numberWithInt:0]]) {
        CMMotionManager *mm = [[CMMotionManager alloc] init];
        ControlLabAppDelegate *appDelegate = (ControlLabAppDelegate *)[[UIApplication sharedApplication] delegate];

        mm = appDelegate.mm;

        [mm stopGyroUpdates];

    }
    else {
        if ([mm isGyroAvailable]) {
            if ([mm isGyroActive] == NO) {
                [mm setGyroUpdateInterval:1.0f / kAccelerometerFrequency];
                queueGyroscope = [[NSOperationQueue alloc] init];
                [mm startGyroUpdatesToQueue:queueGyroscope withHandler:^(CMGyroData *gyroData, NSError *error){

                    // Control Device Orientation
                    UIInterfaceOrientation isOrientation = self.interfaceOrientation;

                    //                NSLog(@"Rotation Rate: %f", gyroData.rotationRate.x);
                    //                if (abs((float)gyroData.rotationRate.x)> 0.005 || abs((float)gyroData.rotationRate.y)> 0.005) {
                    if (isOrientation == UIInterfaceOrientationPortrait) {

                        [self updateFactor:-gyroData.rotationRate.y * kFactorUpdate];
                        [self updateFactorUpDown:gyroData.rotationRate.x * kFactorUpdate];
                    }
                    else if (isOrientation == UIInterfaceOrientationPortraitUpsideDown) {

                        [self updateFactor:gyroData.rotationRate.y * kFactorUpdate];
                        [self updateFactorUpDown:-gyroData.rotationRate.x * kFactorUpdate];
                    }
                    else if (isOrientation == UIInterfaceOrientationLandscapeLeft) {

                        [self updateFactor:gyroData.rotationRate.x * kFactorUpdate];
                        [self updateFactorUpDown:gyroData.rotationRate.y * kFactorUpdate];
                    }
                    else if (isOrientation == UIInterfaceOrientationLandscapeRight) {

                        [self updateFactor:-gyroData.rotationRate.x * kFactorUpdate];
                        [self updateFactorUpDown:-gyroData.rotationRate.y * kFactorUpdate];
                    }
                    

                }];
            }
        }

    }



}

- (void) stopGyroscope{
    // Stop CMMotionManager
    NSNumber *gyroscope = [[NSNumber alloc] initWithInt:0];
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];

    if (standardUserDefaults) {
        [standardUserDefaults setObject:gyroscope forKey:@"gyroscope"];
        [standardUserDefaults synchronize];
    }

}


#pragma mark - Carga Texturas

- (void) loadTextures {

    UIImage *image = [UIImage imageNamed:@"FRONT_LIGHT_ON.png"];
    NSError *error;
    textureFront = [GLKTextureLoader textureWithCGImage:image.CGImage options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:GLKTextureLoaderOriginBottomLeft] error:&error];
    if (error)
        NSLog(@"Error loading texture from image: %@", error);
    image = [UIImage imageNamed:@"LEFT_LIGHT_ON.png"];
    textureLeft = [GLKTextureLoader textureWithCGImage:image.CGImage options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:GLKTextureLoaderOriginBottomLeft] error:&error];
    if (error)
        NSLog(@"Error loading texture from image: %@", error);
    image = [UIImage imageNamed:@"BACK_LIGHT_ON.png"];
    textureBack = [GLKTextureLoader textureWithCGImage:image.CGImage options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:GLKTextureLoaderOriginBottomLeft] error:&error];
    if (error)
        NSLog(@"Error loading texture from image: %@", error);
    image = [UIImage imageNamed:@"RIGHT_LIGHT_ON.png"];
    textureRight = [GLKTextureLoader textureWithCGImage:image.CGImage options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:GLKTextureLoaderOriginBottomLeft] error:&error];
    if (error)
        NSLog(@"Error loading texture from image: %@", error);
    image = [UIImage imageNamed:@"BOTTOM_LIGHT_ON.png"];
    textureBottom = [GLKTextureLoader textureWithCGImage:image.CGImage options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:GLKTextureLoaderOriginBottomLeft] error:&error];
    if (error)
        NSLog(@"Error loading texture from image: %@", error);
    image = [UIImage imageNamed:@"TOP_LIGHT_ON.png"];
    textureTop = [GLKTextureLoader textureWithCGImage:image.CGImage options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:GLKTextureLoaderOriginBottomLeft] error:&error];
    if (error)
        NSLog(@"Error loading texture from image: %@", error);


}

- (void) tearDownGL {
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"Did Receive Memory Warning");
}


#pragma mark - Process Drawing OpenGL ES

-  (void) glkView:(GLKView *)view drawInRect:(CGRect)rect {

    glClearColor(0.5, 0.5, 0.5, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);

    baseEffect.texture2d0.enabled = TRUE;
    baseEffect.texture2d0.envMode = GLKTextureEnvModeReplace;



    GLKMatrix4 matrix = GLKMatrix4Multiply(GLKMatrix4MakeXRotation(factorUpDown),GLKMatrix4MakeYRotation(factor));


    baseEffect.transform.modelviewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeLookAt(0, 0, -3, 0, 0, -1, 0, 1, 0), matrix);
    //    baseEffect.transform.modelviewMatrix = GLKMatrix4Multiply(GLKMatrix4Make    // Perspectiva 60º

    //    baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(1.047, 1024 / 768, 0.1, -20);
    baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45), 1024/768,0.1 ,20);

    [baseEffect prepareToDraw];


    // Habilito Color, Posicion y Textura
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);

    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, textureCoordinates);


    // Cara FRONT #########################################

    [self drawFaceCube:kFaceFront];

    // Cara LEFT #########################################

    [self drawFaceCube:kFaceLeft];

    // Cara BACK #########################################

    [self drawFaceCube:kFaceBack];

    // Cara RIGHT #########################################

      [self drawFaceCube:kFaceRight];

    // Cara TOP #########################################

    [self drawFaceCube:kFaceTop];

    // Cara BOTTOM #########################################

    [self drawFaceCube:kFaceBottom];



    // Deshabilito Color, Posicion y Textura

    baseEffect.texture2d0.enabled = FALSE;
    glDisableVertexAttribArray(GLKVertexAttribColor);
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    glDisableVertexAttribArray(GLKVertexAttribTexCoord0);



    [self tearDownGL];

    // Draw Devices #########################################
    glEnable (GL_BLEND);
    glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribColor);

    baseEffect.useConstantColor = YES;
    [baseEffect prepareToDraw];


    //   [self drawDevice:kWindows];
    //   [self drawDevice:kDoors];


    glDisableVertexAttribArray(GLKVertexAttribPosition);
    glDisableVertexAttribArray(GLKVertexAttribColor);

    glDisable(GL_BLEND);

}

- (void) drawDevice: (kDevices) type {
    switch (type) {
        case kWindows:
            glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), &windowsB[0].position);
            glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), &windowsB[0].color);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            break;
        case kDoors:
            glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), &doorA[0].position);
            glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), &doorA[0].color);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            break;

        default:
            break;
    }
}

- (void) drawFaceCube: (kFaceCubeType) type {
    switch (type) {
        case kFaceFront:
            //            baseEffect.texture2d0.target = textureFront.target;
            baseEffect.texture2d0.name = textureFront.name;
            [baseEffect prepareToDraw];

            glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), &cubeFrontVertex[0].color);
            glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), &cubeFrontVertex[0].position);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

            break;
        case kFaceLeft:
            //            baseEffect.texture2d0.target = textureLeft.target;
            baseEffect.texture2d0.name = textureLeft.name;
            [baseEffect prepareToDraw];

            glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), &cubeLeftVertex[0].color);
            glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), &cubeLeftVertex[0].position);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

            break;
        case kFaceBack:
            //            baseEffect.texture2d0.target = textureBack.target;
            baseEffect.texture2d0.name = textureBack.name;
            [baseEffect prepareToDraw];

            glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), &cubeBackVertex[0].color);
            glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), &cubeBackVertex[0].position);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

            break;
        case kFaceRight:
            //            baseEffect.texture2d0.target = textureRight.target;
            baseEffect.texture2d0.name = textureRight.name;
            [baseEffect prepareToDraw];

            glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), &cubeRightVertex[0].color);
            glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), &cubeRightVertex[0].position);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

            break;
        case kFaceBottom:
            //            baseEffect.texture2d0.target = textureTop.target;
            baseEffect.texture2d0.name = textureTop.name;
            [baseEffect prepareToDraw];

            glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), &cubeTopVertex[0].color);
            glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), &cubeTopVertex[0].position);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

            break;
        case kFaceTop:
            //            baseEffect.texture2d0.target = textureBottom.target;
            baseEffect.texture2d0.name = textureBottom.name;
            [baseEffect prepareToDraw];
            
            glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), &cubeBottomVertex[0].color);
            glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), &cubeBottomVertex[0].position);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            
            break;
            
        default:
            break;
    }
}

- (void) glkViewControllerUpdate:(GLKViewController *)controller {
    [self loadGyroscope];

}



@end

