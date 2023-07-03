use v6;

=begin pod

=head1 NAME

LibraryCheck - Determine whether a shared library is available to be loaded

=head1 SYNOPSIS

=begin code :lang<raku>

use LibraryCheck;

if !library-exists('sndfile', v1) {
    die "Cannot load libsndfile";
}

=end code

=head1 DESCRIPTION

This module provides a mechanism that will determine whether a named
shared library is available and can be used by NativeCall.

It exports a single function C<library-exists> that returns a boolean to
indicate whether the named shared library can be loaded and used.
The library name should be supplied without any (OS-dependent) "lib"
prefix and no extension (for example, C<'crypt'> for C<libcrypt.so>).

This can be used in a builder to determine whether a module has a chance
of working (and possibly aborting the build), or in tests to cause the
tests that may rely on a missing library to be skipped.

The second positional argument is a L<Version> object that indicates the
version of the library that is required, it defaults to C<v1>, if you don't
care which version exists then it possible to pass a new Version object
without any version parts (i.e., C<Version.new()>). Many systems require
that the version is specified, so if portability is a concern, an actual
version number should be given.

If the C<:exception> adverb is passed to C<library-exists> then an
exception (C<X::NoLibrary>) will be thrown if the library isn't available
rather than returning C<False>. So the case above can be more simply
written as:

=for code :lang<raku>
library-check('sndfile', v1, :exception);


The implementation is somewhat of a hack currently and definitely shouldn't
be taken as an example of nice Raku code.

=end pod

module LibraryCheck {
   use NativeCall :TEST;

   class X::NoLibrary is Exception {
       has Str $.library;

       method message() returns Str {
           "library { $!library } was not found";
       }
   }

    my Bool %test-result;
    sub library-exists(Str $lib, Version $v = v1, :$exception --> Bool) is export {
        my $test-key = "$lib-{ $v.gist }";
        if not %test-result{$test-key}:exists {
            %test-result{$test-key} = True;
            my $f = sub {};
            my $soname = guess_library_name($lib, $v);
            $f does NativeCall::Native[$f, $soname];
            # This is required since 2019-10-13
            # will remove when there is a new release of Rakudo
            if $f.^can('setup-nativecall') {
                $f.setup-nativecall;
            }
            $f();
            CATCH {
                when /'Cannot locate native library'/  { %test-result{$test-key} = False }
                default { %test-result{$test-key} = True }
            }
        }

        if not %test-result{$test-key} and $exception {
            X::NoLibrary.new(library => $lib).throw;
        }
        %test-result{$test-key};
    }
}
