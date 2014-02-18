#!/usr/bin/python2

#Only work in ArchLinux

import os
import smtplib
import mimetypes
import sys
from email.MIMEMultipart import MIMEMultipart
from email.MIMEBase import MIMEBase
from email.MIMEText import MIMEText
from email.MIMEAudio import MIMEAudio
from email.MIMEImage import MIMEImage
from email.Encoders import encode_base64

def sendMail(subject, text, *attachmentFilePaths):
  gmailUser = 'yangling1984@gmail.com'
  gmailPassword = 'enurcamuahyparfb'
  recipient = 'yangling1984@free.kindle.cn'

  msg = MIMEMultipart()
  msg['From'] = gmailUser
  msg['To'] = recipient
  msg['Subject'] = subject
  msg.attach(MIMEText(text))

  for attachmentFilePath in attachmentFilePaths:
    msg.attach(getAttachment(attachmentFilePath))

  mailServer = smtplib.SMTP('smtp.gmail.com', 587)
  mailServer.ehlo()
  mailServer.starttls()
  mailServer.ehlo()
  mailServer.login(gmailUser, gmailPassword)
  mailServer.sendmail(gmailUser, recipient, msg.as_string())
  mailServer.close()

  print('Sent email to %s' % recipient)

def getAttachment(attachmentFilePath):
  contentType, encoding = mimetypes.guess_type(attachmentFilePath)

  if contentType is None or encoding is not None:
    contentType = 'application/octet-stream'

  mainType, subType = contentType.split('/', 1)
  file = open(attachmentFilePath, 'rb')

  if mainType == 'text':
    attachment = MIMEText(file.read())
  elif mainType == 'message':
    attachment = email.message_from_file(file)
  elif mainType == 'image':
    attachment = MIMEImage(file.read(),_subType=subType)
  elif mainType == 'audio':
    attachment = MIMEAudio(file.read(),_subType=subType)
  else:
    attachment = MIMEBase(mainType, subType)
  attachment.set_payload(file.read())
  encode_base64(attachment)

  file.close()

  attachment.add_header('Content-Disposition', 'attachment',   filename=os.path.basename(attachmentFilePath))
  return attachment

def clearKindleFolder(*kindleFolderFiles):
  if len(kindleFolderFiles) == 0:
    print('No file to clear')
    return
  for onefile in kindleFolderFiles:
    os.remove(onefile)
    print('%s is deleted' % onefile)

kindleFileFolder = '/home/yangling/Documents/Kindle/'
checksum_files = []
for theFile in os.listdir(kindleFileFolder):
  print(theFile)
  fullpath = os.path.join(kindleFileFolder, theFile)
  print(fullpath)
  if os.path.isfile(fullpath):
    checksum_files += [fullpath]
print(','.join(checksum_files))
if len(sys.argv) == 1:
  # No argument, load file from kindlefilefolder
  if len(checksum_files) == 0:
    print('There is no file in %s' % kindleFileFolder)
  else:
    sendMail('convert','convert',*checksum_files)
    clearKindleFolder(*checksum_files)
elif len(sys.argv) == 2:
  # The argument is either "-n" or file path
  if str(sys.argv[1]) == '-n':
    #load file from kindlefilefolder, but not convert
    if len(checksum_files) == 0:
      print('There is no file in %s' % kindleFileFolder)
    else:
      sendMail(' ',' ',*checksum_files)
      clearKindleFolder(*checksum_files)
  else:
    # the argument is file path
    sendMail('convert','convert',str(sys.argv[1]))
elif len(sys.argv) == 3:
  # the argument is file path and "-n"
  if str(sys.argv[1]) == '-n':
    sendMail(' ',' ',str(sys.argv[2]))
  elif str(sys.argv[2]) == '-n':
    sendMail(' ',' ',str(sys.argv[1]))
  else:
    print('Invalid argument.')
else:
  print('Invalid argument. You must specify a file. Append "-n" if you dont want convert')
