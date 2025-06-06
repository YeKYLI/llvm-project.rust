//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef _LIBCPP___FWD_IOS_H
#define _LIBCPP___FWD_IOS_H

#include <__config>
#include <__fwd/string.h>

#if !defined(_LIBCPP_HAS_NO_PRAGMA_SYSTEM_HEADER)
#  pragma GCC system_header
#endif

_LIBCPP_BEGIN_NAMESPACE_STD

class _LIBCPP_EXPORTED_FROM_ABI ios_base;

template <class _CharT, class _Traits = char_traits<_CharT> >
class basic_ios;

using ios = basic_ios<char>;
#if _LIBCPP_HAS_WIDE_CHARACTERS
using wios = basic_ios<wchar_t>;
#endif

template <class _CharT, class _Traits>
class _LIBCPP_PREFERRED_NAME(ios) _LIBCPP_IF_WIDE_CHARACTERS(_LIBCPP_PREFERRED_NAME(wios)) basic_ios;

#if defined(_NEWLIB_VERSION)
// On newlib, off_t is 'long int'
using streamoff = long int; // for char_traits in <string>
#else
using streamoff = long long; // for char_traits in <string>
#endif

_LIBCPP_END_NAMESPACE_STD

#endif // _LIBCPP___FWD_IOS_H
