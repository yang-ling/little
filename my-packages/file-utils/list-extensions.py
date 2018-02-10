#!/usr/bin/env python3
# Created on Wed Jan 31 18:14:26 CST 2018

'''
This tool will list all extensions under target folder
'''

__author__ = 'Yang Ling'
__version__ = '1.0'

import os

exts = set()


def main():
    '''
    This will be called if the script is directly invoked.
    '''
    for subdir, dirs, files in os.walk("."):
        for file in files:
            ext = os.path.splitext(file)[-1].lower()
            exts.add(ext)
    print(exts)


if __name__ == '__main__':
    main()
