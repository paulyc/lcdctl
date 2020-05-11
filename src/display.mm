//
//  lcdctl Copyright (C) 2020 Paul Ciarlo <paul.ciarlo@gmail.com>
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this
//     list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#include "display.h"

#include <cstdio>
#include <cstdarg>

namespace salvatoresmundi {

std::string stringprintf(const char *fmt, ...) {
    std::string buf;
    buf.reserve(128);
    va_list args;
    va_start (args, fmt);
    do {
        int written = vsnprintf((char*)buf.data(), buf.max_size(), fmt, args);
        if (written >= 0) {
            if (written >= buf.max_size()) {
                buf.reserve(written+1);
                continue;
            }
        } else {
            fprintf(stderr, "stringprintf: vsnprintf errno [%d] %s\n", errno, strerror(errno));
        }
    } while (false);
    va_end (args);
    return buf;
}

DisplayMode::DisplayMode(CGDisplayModeRef mode) : _mode(mode) {}

DisplayMode::~DisplayMode() {
    if (_mode != NULL) {
        CGDisplayModeRelease(_mode);
    }
}

DisplayMode::DisplayMode(DisplayMode &&rhs) {
    this->_mode = rhs._mode;
    rhs._mode = NULL;
}

DisplayMode &DisplayMode::operator=(DisplayMode &&rhs) {
    this->_mode = rhs._mode;
    rhs._mode = NULL;
    return *this;
}

CGDisplayModeRef DisplayMode::getDisplayModeRef() const {
    return _mode;
}

std::string DisplayMode::toString() {
    return stringprintf("%lu x %lu @ %f", CGDisplayModeGetWidth(_mode), CGDisplayModeGetHeight(_mode), CGDisplayModeGetRefreshRate(_mode));
}
DisplayMode DisplayMode::getCurrentMainDisplayMode() {
    CGDirectDisplayID id = CGMainDisplayID();
    CGDisplayModeRef mode = CGDisplayCopyDisplayMode(id);
    return mode;
}
std::vector<DisplayMode> DisplayMode::getAllMainDisplayModes() {
    std::vector<DisplayMode> modes;
    CGDirectDisplayID id = CGMainDisplayID();
    CFArrayRef modesref = CGDisplayCopyAllDisplayModes(id, NULL);
    for (CFIndex i = 0; i < CFArrayGetCount(modesref); ++i) {
        CGDisplayModeRef m = CGDisplayModeRetain((CGDisplayModeRef)CFArrayGetValueAtIndex(modesref, i));
        modes.push_back(DisplayMode(m));
    }
    CFRelease(modesref);
    return modes;
}

void Display::showModes() {
    std::vector<DisplayMode> allModes = DisplayMode::getAllMainDisplayModes();
    
    printf("Current mode: %s\n", DisplayMode::getCurrentMainDisplayMode().toString().c_str());
    printf("Available modes:\n");
    for (size_t i = 0; i < allModes.size(); ++i) {
        printf("%lu: %s\n", i, allModes[i].toString().c_str());
    }
}

void Display::setMainDisplayMode(size_t indx) {
    CGDisplayConfigRef config;
    CGError err = kCGErrorSuccess;
    std::vector<DisplayMode> allModes = DisplayMode::getAllMainDisplayModes();
    do {
        if (indx >= allModes.size()) {
            fprintf(stderr, "Invalid mode %lu\n", indx);
            break;
        }
        err = CGBeginDisplayConfiguration(&config);
        if (err != kCGErrorSuccess) break;
        err = CGConfigureDisplayWithDisplayMode(config, CGMainDisplayID(), allModes[indx].getDisplayModeRef(), NULL);
        if (err != kCGErrorSuccess) break;
        err = CGCompleteDisplayConfiguration(config, kCGConfigurePermanently);
    } while (0);
    if (err != kCGErrorSuccess) {
        fprintf(stderr, "Display::setMainDisplayMode errno [%d] %s\n", errno, strerror(errno));
    }
}

}
