#!/usr/bin/env bash

/usr/bin/vendor_perl/cpanm --local-lib=%h/perl5 local::lib && eval $(/usr/bin/perl -I %h/perl5/lib/perl5/ -Mlocal::lib)
/usr/local/bin/qq.pl
