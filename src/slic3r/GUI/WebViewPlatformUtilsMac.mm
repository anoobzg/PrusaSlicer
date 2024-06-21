#include "WebViewPlatformUtils.hpp"

#import <WebKit/WKWebView.h>
#import <WebKit/WKNavigationDelegate.h>
#import <Foundation/Foundation.h>
#import <Foundation/NSURLSession.h>

@interface MyNavigationDelegate: NSObject<WKNavigationDelegate> {
    id<WKNavigationDelegate> _delegate;
    NSString* _username;
    NSString* _passwd;
}
- (id) initWithOriginalDelegate: (id<WKNavigationDelegate>) delegate userName: (const char*) username password: (const char*) password;
@end

@implementation MyNavigationDelegate
- (id) initWithOriginalDelegate: (id<WKNavigationDelegate>) delegate userName: (const char*) username password: (const char*) password {
    if (self = [super init]) {
        _delegate = delegate;
        _username = [[NSString alloc] initWithFormat:@"%s", username];
        _passwd = [[NSString alloc] initWithFormat:@"%s", password];
    }
    return self;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler WK_SWIFT_ASYNC(3) {
    if ([_delegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)]) {
        [_delegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction preferences:(WKWebpagePreferences *)preferences decisionHandler:(void (^)(WKNavigationActionPolicy, WKWebpagePreferences *))decisionHandler WK_SWIFT_ASYNC(4) API_AVAILABLE(macos(10.15), ios(13.0)) {
    if ([_delegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:preferences:decisionHandler:)]) {
        [_delegate webView:webView decidePolicyForNavigationAction:navigationAction preferences:preferences decisionHandler:decisionHandler];
    } else {
        decisionHandler(WKNavigationActionPolicyAllow, preferences);
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler WK_SWIFT_ASYNC(3) {
    if ([_delegate respondsToSelector:@selector(webView:decidePolicyForNavigationResponse:decisionHandler:)]) {
        [_delegate webView:webView decidePolicyForNavigationResponse: navigationResponse decisionHandler: decisionHandler];
    } else {
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    if ([_delegate respondsToSelector:@selector(webView:didStartProvisionalNavigation:)]) {
        [_delegate webView:webView didStartProvisionalNavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    if ([_delegate respondsToSelector:@selector(webView:didReceiveServerRedirectForProvisionalNavigation:)]) {
        [_delegate webView:webView didReceiveServerRedirectForProvisionalNavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    if ([_delegate respondsToSelector:@selector(webView:didFailProvisionalNavigation:withError:)]) {
        [_delegate webView:webView didFailProvisionalNavigation:navigation withError:error];
    }
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    if ([_delegate respondsToSelector:@selector(webView:didCommitNavigation:)]) {
        [_delegate webView:webView didCommitNavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    if ([_delegate respondsToSelector:@selector(webView:didFinishNavigation:)]) {
        [_delegate webView:webView didFinishNavigation:navigation];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    if ([_delegate respondsToSelector:@selector(webView:didFailNavigation:withError:)]) {
        [_delegate webView:webView didFailNavigation:navigation withError:error];
    }
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler WK_SWIFT_ASYNC_NAME(webView(_:respondTo:)) {
    //challenge.protectionSpace.realm
    completionHandler(
        NSURLSessionAuthChallengeUseCredential,
        [NSURLCredential credentialWithUser: _username password: _passwd persistence: NSURLCredentialPersistenceForSession]
    );
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView API_AVAILABLE(macos(10.11), ios(9.0)) {
    if ([_delegate respondsToSelector:@selector(webViewWebContentProcessDidTerminate:)]) {
        [_delegate webViewWebContentProcessDidTerminate:webView];
    }
}

- (void)webView:(WKWebView *)webView authenticationChallenge:(NSURLAuthenticationChallenge *)challenge shouldAllowDeprecatedTLS:(void (^)(BOOL))decisionHandler WK_SWIFT_ASYNC_NAME(webView(_:shouldAllowDeprecatedTLSFor:)) WK_SWIFT_ASYNC(3) API_AVAILABLE(macos(11.0), ios(14.0)) {
    if ([_delegate respondsToSelector:@selector(webView:authenticationChallenge:shouldAllowDeprecatedTLS:)]) {
        [_delegate webView:webView authenticationChallenge:challenge shouldAllowDeprecatedTLS:decisionHandler];
    } else {
        decisionHandler(YES);
    }
}

- (void)webView:(WKWebView *)webView navigationAction:(WKNavigationAction *)navigationAction didBecomeDownload:(WKDownload *)download API_AVAILABLE(macos(11.3), ios(14.5)) {
    if ([_delegate respondsToSelector:@selector(webView:navigationAction:didBecomeDownload:)]) {
        [_delegate webView:webView navigationAction:navigationAction didBecomeDownload:download];
    }
}

- (void)webView:(WKWebView *)webView navigationResponse:(WKNavigationResponse *)navigationResponse didBecomeDownload:(WKDownload *)download API_AVAILABLE(macos(11.3), ios(14.5)) {
    if ([_delegate respondsToSelector:@selector(webView:navigationResponse:didBecomeDownload:)]) {
        [_delegate webView:webView navigationResponse:navigationResponse didBecomeDownload:download];
    }
}
@end


namespace Slic3r::GUI {
void setup_webview_with_credentials(wxWebView* web_view, const std::string& username, const std::string& password)
{
    WKWebView* backend = static_cast<WKWebView*>(web_view->GetNativeBackend());
    if (![backend.navigationDelegate isKindOfClass:MyNavigationDelegate.class]) {
        backend.navigationDelegate = [[MyNavigationDelegate alloc]
            initWithOriginalDelegate:backend.navigationDelegate
                            userName:username.c_str()
                            password:password.c_str()];
    }
}
}

