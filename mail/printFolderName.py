#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import sys
from imapclient import imap_utf7

decoded = imap_utf7.decode(sys.argv[1])
print(decoded)
