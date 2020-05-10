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

#ifndef com_salvatoresmundi_lcdctl_display_h
#define com_salvatoresmundi_lcdctl_display_h

#include <vector>
#include <string>

#include <CoreGraphics/CoreGraphics.h>
#include <Foundation/Foundation.h>

namespace salvatoresmundi {

std::string stringprintf(const char *fmt, ...);

class DisplayMode
{
public:
    DisplayMode(CGDisplayModeRef mode);
    ~DisplayMode();
    DisplayMode(const DisplayMode&) = delete;
    DisplayMode &operator=(const DisplayMode&) = delete;
    DisplayMode(DisplayMode &&rhs);
    DisplayMode &operator=(DisplayMode &&rhs);
    
    CGDisplayModeRef getDisplayModeRef() const;
    std::string toString();
    static DisplayMode getCurrentMainDisplayMode();
    static std::vector<DisplayMode> getAllMainDisplayModes();
private:
    CGDisplayModeRef _mode;
};

class Display
{
public:
    static void showModes();
    static void setMainDisplayMode(size_t indx);
};

} /* namespace salvatoresmundi */

#endif /* com_salvatoresmundi_lcdctl_display_h */
