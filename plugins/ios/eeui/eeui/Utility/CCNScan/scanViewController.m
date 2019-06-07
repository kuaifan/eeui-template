//
//  scanViewController.m
//  CCNScan
//
//  Created by zcc on 16/4/14.
//  Copyright © 2016年 CCN. All rights reserved.
//

#import "scanViewController.h"
#import "DeviceUtil.h"
#import "LBXScanView.h"
#import "WXConvert.h"
#import "UINavigationConfig.h"
#import <AVFoundation/AVFoundation.h>

#define mainWidth [UIScreen mainScreen].bounds.size.width
#define mainHeight [UIScreen mainScreen].bounds.size.height
#define iPhoneXSeries (([[UIApplication sharedApplication] statusBarFrame].size.height == 44.0f) ? (YES):(NO))

@interface scanViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,AVCaptureMetadataOutputObjectsDelegate>{
    UIImagePickerController *imagePicker;
}

@property ( strong , nonatomic ) AVCaptureDevice * device;
@property ( strong , nonatomic ) AVCaptureDeviceInput * input;
@property ( strong , nonatomic ) AVCaptureMetadataOutput * output;
@property ( strong , nonatomic ) AVCaptureSession * session;
@property ( strong , nonatomic ) AVCaptureStillImageOutput * stillImageOutput;
@property ( strong , nonatomic ) AVCaptureVideoPreviewLayer * previewLayer;

@property ( strong , nonatomic ) LBXScanView *scanView;
@property ( strong , nonatomic ) LBXScanViewStyle *scanStyle;

@property (nonatomic, strong) UIView *bottomItemsView;
@property (nonatomic, strong) UIButton *btnFlash;
@property (nonatomic,assign) BOOL isOpenFlash;

@property (nonatomic,assign)BOOL isScanSuccess;

@end

@implementation scanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.modalPresentationCapturesStatusBarAppearance = NO;
    
    UIBarButtonItem *navRightButton = [[UIBarButtonItem alloc]initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(choicePhoto)];
    self.navigationItem.rightBarButtonItems = [UINavigationConfig itemSpace:navRightButton];
    self.navigationItem.title = @"二维码/条码";
    self.navigationController.navigationBar.barTintColor = [WXConvert UIColor:@"#93c0ff"];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    //扫描框
    [self loadScanerView];
    
    //底部按钮
    [self loadBottomView];
    
    //开始扫描
    [self requestCameraPemissionWithResult:^(BOOL granted) {
        if (granted) {
            [self performSelector:@selector(startScan) withObject:nil afterDelay:0.3];
        }else{
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"无法访问相机"
                                                  message:@"请在iPhone的""设置-隐私-相册""中允许相机访问"
                                                  preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction
                                        actionWithTitle:@"确定"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * _Nonnull action) {
                                            [[[DeviceUtil getTopviewControler] navigationController] popViewControllerAnimated:YES];
                                        }]];
            [[DeviceUtil getTopviewControler] presentViewController:alertController animated:YES completion:nil];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    
    //[self.navigationController setNavigationBarHidden:NO animated:YES];

    if (_session != nil) {
        [self.session startRunning];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.scanView) {
        [self.scanView startScanAnimation];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear: animated];
    
    //[self.navigationController setNavigationBarHidden:YES animated:YES];

    [self.session stopRunning];
    [self.scanView stopScanAnimation];
}

- (void)loadScanerView
{
    CGFloat plusY = self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    self.scanStyle = [[LBXScanViewStyle alloc] init];
    self.scanStyle.animationImage = [UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_weixin_line"];
    self.scanStyle.colorAngle = [UIColor greenColor];
    self.scanView = [[LBXScanView alloc] initWithFrame:CGRectMake(0, plusY, self.view.frame.size.width, self.view.frame.size.height) style:self.scanStyle];
    [self.view addSubview:self.scanView];
    
    if (self.desc.length > 0) {
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(25, self.view.frame.size.height - (iPhoneXSeries ? 284 : 248) + plusY, self.view.frame.size.width - 50, 100)];
        lab.textColor = [UIColor whiteColor];
        lab.lineBreakMode = NSLineBreakByWordWrapping;
        lab.numberOfLines = 0;
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont systemFontOfSize:16.0f];
        lab.text = self.desc;
        [self.view addSubview:lab];
    }
}

- (void)loadBottomView
{
    if (_bottomItemsView) {
        return;
    }
    CGFloat plusY = self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    self.bottomItemsView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame) - (iPhoneXSeries ? 200 : 164) + plusY, CGRectGetWidth(self.view.frame), 84)];
    _bottomItemsView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    [self.view addSubview:_bottomItemsView];
    
    CGSize size = CGSizeMake(65, 65);
    _btnFlash = [[UIButton alloc]init];
    _btnFlash.bounds = CGRectMake(0, 0, size.width, size.height);
    _btnFlash.center = CGPointMake(CGRectGetWidth(_bottomItemsView.frame)/2, CGRectGetHeight(_bottomItemsView.frame)/2);
    [_btnFlash setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_flash_nor"] forState:UIControlStateNormal];
    [_btnFlash addTarget:self action:@selector(openOrCloseFlash) forControlEvents:UIControlEventTouchUpInside];
    
    [_bottomItemsView addSubview:_btnFlash];
}

//开关闪光灯
- (void)openOrCloseFlash
{
    [self.input.device lockForConfiguration:nil];
    self.input.device.torchMode = _isOpenFlash ? AVCaptureTorchModeOff : AVCaptureTorchModeOn;
    [self.input.device unlockForConfiguration];
    
    if (_isOpenFlash) {
        [_btnFlash setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_flash_nor"] forState:UIControlStateNormal];
    } else {
        [_btnFlash setImage:[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_btn_flash_down"] forState:UIControlStateNormal];
    }
    self.isOpenFlash = !_isOpenFlash;
}

//开始扫描
- (void)startScan {
    if (_device == nil) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    if (!_device) {
        return;
    }
    if (_input == nil) {
        _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
    }
    if (!_input){
        return;
    }
    if (_output == nil) {
        _output = [[AVCaptureMetadataOutput alloc] init];
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    }
    if (_stillImageOutput == nil) {
        _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        [_stillImageOutput setOutputSettings:[[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil]];
    }
    if (_session == nil) {
        _session = [[AVCaptureSession alloc] init];
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
    }
    if (_previewLayer == nil) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    
    if ([_session canAddInput:_input]) {
        [_session addInput:_input];
    }    
    if ([_session canAddOutput:_output]) {
        [_session addOutput:_output];
    }
    if ([_session canAddOutput:_stillImageOutput]){
        [_session addOutput:_stillImageOutput];
    }
    //扫码类型
    [_output setMetadataObjectTypes:[self defaultMetaDataObjectTypes]];
    //预览层
    _previewLayer.frame = self.view.frame;
    [self.view.layer insertSublayer:_previewLayer atIndex:0];
    [self.view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
    //开始扫描
    [_session startRunning];
}

//扫码回调
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (!_isScanSuccess){
        NSString *content = @"";
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
        content = metadataObject.stringValue;
        
        if (![content isEqualToString:@""]) {
            //震动
            [self playBeep];
            _isScanSuccess = YES;

            NSDictionary *dic = @{@"status":@"success", @"url":content, @"source":@"photo"};
            self.scanerBlock(dic);
            
            if (self.successClose) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }else{
            NSLog(@"没内容");
            NSDictionary *dic = @{@"status":@"error", @"url":@"", @"source":@"photo"};
            self.scanerBlock(dic);
        }
    }
}

#pragma mark - 从相册识别二维码
- (void) choicePhoto {
    imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

//音效震动
#define SOUNDID  1109  //1012 -iphone   1152 ipad  1109 ipad

- (void) playBeep {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSound(SOUNDID);
}

#pragma mark - ImagePickerDelegate
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *content = @"" ;
    //取出选中的图片
    UIImage *pickImage = info[UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImagePNGRepresentation(pickImage);
    CIImage *ciImage = [CIImage imageWithData:imageData];
    
    //创建探测器
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
    NSArray *feature = [detector featuresInImage:ciImage];
    
    //取出探测到的数据
    for (CIQRCodeFeature *result in feature) {
        content = result.messageString;
    }
    __weak typeof(self) weakSelf = self;
    //选中图片后先返回扫描页面，然后跳转到新页面进行展示
    [picker dismissViewControllerAnimated:NO completion:^{
        if (![content isEqualToString:@""]) {
            //震动
            [weakSelf playBeep];
            NSDictionary *dic = @{@"status":@"success", @"url":content, @"source":@"camera"};
            self.scanerBlock(dic);
            if (self.successClose) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }else{
            NSLog(@"没扫到东西");
            NSDictionary *dic = @{@"status":@"success", @"url":@"", @"source":@"camera"};
            self.scanerBlock(dic);
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSArray *)defaultMetaDataObjectTypes {
    NSMutableArray *types = [@[AVMetadataObjectTypeQRCode,
                               AVMetadataObjectTypeUPCECode,
                               AVMetadataObjectTypeCode39Code,
                               AVMetadataObjectTypeCode39Mod43Code,
                               AVMetadataObjectTypeEAN13Code,
                               AVMetadataObjectTypeEAN8Code,
                               AVMetadataObjectTypeCode93Code,
                               AVMetadataObjectTypeCode128Code,
                               AVMetadataObjectTypePDF417Code,
                               AVMetadataObjectTypeAztecCode] mutableCopy];
    if (@available(iOS 8.0, *)) {
        [types addObjectsFromArray:@[AVMetadataObjectTypeInterleaved2of5Code,
                                     AVMetadataObjectTypeITF14Code,
                                     AVMetadataObjectTypeDataMatrixCode
                                     ]];
    }
    return types;
}

- (void)requestCameraPemissionWithResult:(void(^)( BOOL granted))completion {
    if ([AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)]) {
        AVAuthorizationStatus permission =
        [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        switch (permission) {
            case AVAuthorizationStatusAuthorized:
                completion(YES);
                break;
                
            case AVAuthorizationStatusDenied:
            case AVAuthorizationStatusRestricted:
                completion(NO);
                break;
                
            case AVAuthorizationStatusNotDetermined: {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         if (granted) {
                             completion(true);
                         } else {
                             completion(false);
                         }
                     });
                    
                 }];
            }
            break;
        }
    }
}


@end
