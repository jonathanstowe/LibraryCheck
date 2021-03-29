# LibraryCheck

Determine whether a shared library is available to be loaded by Raku

![Build Status](https://github.com/jonathanstowe/LibraryCheck/workflows/CI/badge.svg)

## Synopsis

```raku
use LibraryCheck;

if !library-exists('sndfile', v1) {
    die "Cannot load libsndfile";
}
```

## Description

This module provides a mechanism that will determine whether a named
shared library is available and can be used by NativeCall.

It exports a single function `library-exists` that returns a boolean to
indicate whether the named shared library can be loaded and used. The
library name should be supplied without any (OS-dependent) "lib" prefix
and no extension (for example, `'crypt'` for `libcrypt.so`).

This can be used in a builder to determine whether a module has a chance
of working (and possibly aborting the build), or in tests to cause the
tests that may rely on a missing library to be skipped.

The second positional argument is a [Version](Version) object that
indicates the version of the library that is required, it defaults to
`v1`, if you don't care which version exists then it possible to pass a
new Version object without any version parts (i.e., `Version.new()`).
Many systems require that the version is specified, so if portability is
a concern, an actual version number should be given.

If the `:exception` adverb is passed to `library-exists` then an
exception (`X::NoLibrary`) will be thrown if the library isn't available
rather than returning `False`. So the case above can be more simply
written as:

```raku
library-check('sndfile', v1, :exception);
```

The implementation is somewhat of a hack currently and definitely
shouldn't be taken as an example of nice Raku code.

## Installation

Assuming you have a working Rakudo installation you should be able to
install this with *zef*:

    # From the source directory

    zef install .

    # Remote installation

    zef install LibraryCheck

Other install mechanisms may be become available in the future.

## Support

Suggestions/patches are welcomed via github at https://github.com/jonathanstowe/LibraryCheck/issues

I'd be particularly interested in having it work properly on all the platforms that rakudo will work on.

## Licence

Please see the [LICENCE](LICENCE) file in the distribution.

© Jonathan Stowe 2015 - 2021
