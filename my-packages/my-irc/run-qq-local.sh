#!/usr/bin/env bash

/usr/bin/vendor_perl/cpanm --local-lib=~/perl5 local::lib && eval $(/usr/bin/perl -I ~/perl5/lib/perl5/ -Mlocal::lib)
/usr/bin/vendor_perl/cpanm Mojo::Webqq
/usr/bin/vendor_perl/cpanm -v Mojo::IRC::Server::Chinese
/usr/local/bin/qq.pl
