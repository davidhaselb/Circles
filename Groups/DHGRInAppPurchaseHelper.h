//
//  DHGRInAppPurchaseHelper.h
//  Circles
//
//  Created by David Haselberger on 22/09/15.
//  Copyright (c) 2015 David Haselberger. All rights reserved.
//
//
//#import <Foundation/Foundation.h>
//#import <StoreKit/StoreKit.h>
//
//
//
//
//#define circlesInAppPurchaseHelperProductsFetchedNotification @"circlesInAppPurchaseHelperProductsFetchedNotification"
//#define circlesInAppPurchaseTransactionFailedNotification @"circlesInAppPurchaseTransactionFailedNotification"
//#define circlesInAppPurchaseHelperTransactionSucceededNotification @"circlesInAppPurchaseManagerTransactionSucceededNotification"
//
//
//@interface DHGRInAppPurchaseHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
//{
//    IBOutlet NSPanel* theIAPPanel;
//    IBOutlet NSTextField* priceField;
//    IBOutlet NSButton* purchaseButton;
//    SKProduct *proUpgradeProduct;
//    SKProductsRequest *productsRequest;
//}
//
//@property (nonatomic, assign) BOOL notPurchased;
//
//- (IBAction)openIAPSheet:(id)sender;
//- (IBAction)theIAPSheetCancel:(id)sender;
//- (IBAction)theIAPSheetOK:(id)sender;
//- (void)openIAP:(id)sender;
//- (BOOL)isProPurchase;
//- (void)restoreIAP:(id)sender;
//- (void)restoreCompletedTransactions;
//- (void)checkExportMenuTitle;
//
//- (void)loadStore;
//- (BOOL)canMakePurchases;
//- (void)purchaseProUpgrade;
//
//
//@end
