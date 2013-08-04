#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''recursively process subdirectories of given directory or
for a single file downloading appropriate cover images from 
Google Images if MP3 (.mp3), FLAC (.flac), M4A (.m4a), 
Musepack (.mpc), Ogg FLAC (.oga), Ogg Vorbis (.ogg), 
Ogg Speex (.spx), Monkey's Audio (.ape), WavePack (.wv) 
files are found'''


'''author: James Stewart
https://launchpad.net/coverlovin
adjusted by: Thomas Funk <t.funk@web.de>
'''

import os, sys
import urllib, urllib2
import simplejson
import mutagen
import logging
from optparse import OptionParser
import subprocess

# version
version = '2.5.4'

# logging
log = logging.getLogger('coverlovin')
log.setLevel(logging.INFO)
handler = logging.StreamHandler()
formatter = logging.Formatter("%(message)s")
handler.setFormatter(formatter)
log.addHandler(handler)

# google images
defaultReferer = "https://launchpad.net/coverlovin"
googleImagesUrl = "https://ajax.googleapis.com/ajax/services/search/images"

def sanitise_for_url(inputString):
    '''sanitise a string such that it can be used in a url'''

    # return blank string if none provided
    if inputString == None:
        return ""

    # process inputString
    words = inputString.split(' ')
    outputString = ''
    for word in words:
        try:
            word = urllib.quote(word.encode('utf-8'))
            outputString += word + '+'
        except Exception, err:
            log.error("Exception: " + str(err))
    
    # drop trailing '+'
    outputString = outputString[:-1]

    return outputString

def dl_cover(urlList, directory, fileName, overWrite=False):
    '''download cover image from url in list to given directory/fileName'''

    coverImg = os.path.join(directory, fileName)
    
    # move existing file if overWrite enabled
    if os.path.isfile(coverImg) and overWrite:
        log.info("%s exists and overwrite enabled - moving to %s.bak" % (coverImg, coverImg))
        os.rename(coverImg, (coverImg + '.bak'))
    # download cover image from urls in list
    for url in urlList:
        log.debug('opening url: ' + url)
        urlOk = True
        # open connection
        try:
            coverImgWeb = urllib2.urlopen(url, None, 10)
        except Exception, err:
            log.error('exception: ' + str(err))
            urlOk = False
        # download file
        if urlOk:
            log.info('downloading cover image\n from: %s\n to: %s' % (url, coverImg))
            coverImgLocal = open(os.path.join(directory, fileName), 'w')
            coverImgLocal.write(coverImgWeb.read())
            coverImgWeb.close()
            coverImgLocal.close()
            # cover successfully downloaded so return
            return True

    # no cover image downloaded
    return False

def get_cover(song_details, coverFile, resultCount):
    '''get covers from google search'''
    
    # build filename
    fileName = build_covername(coverFile, song_details)
    if not os.path.exists(os.path.join( song_details['thisDir'], fileName)):
        keywords = []
        for key in coverFile['keys']:
            # change content if '/' is found
            #new_content = song_details[key].replace('/', '°')
            keywords.append(song_details[key])
        urls = get_img_urls(keywords, fileType=coverFile['extension'], fileSize=coverFile['size'], resultCount=resultCount)
        if len(urls) > 0:
            log.debug('gathered %i urls for %s:' % (len(urls), str(keywords)))
            for url in urls:
                log.debug(' %s' % url)

            # download cover image
            if not coverFile['externalDir'] == '':
                dl_cover(urls, coverFile['externalDir'], fileName, overWrite=coverFile['overwrite'])
            else:
                dl_cover(urls, song_details['thisDir'], fileName, overWrite=coverFile['overwrite'])
        else:
            log.info('no urls found for '+str(keywords))
            fileName = ''
    else:
        if not coverFile['externalDir'] == '':
            coverFile['externalDir'] = song_details['thisDir']
            
    if coverFile['printinfo'] == True:
        song_details['cover'] = fileName
        print_file_info(song_details, coverFile['externalDir'])                
        
    
def get_img_urls(searchWords, fileType='jpg', fileSize='small', resultCount=8, referer=defaultReferer):
    '''return list of cover urls obtained by searching
    google images for searchWords'''

    imgUrls = []

    # sanitise searchwords
    searchWords = [sanitise_for_url(searchWord) for searchWord in searchWords]
    
    # construct url
    url = googleImagesUrl + '?v=1.0&q='
    
    # add searchwords
    for searchWord in searchWords:
        url += searchWord + '+'
    url = url[:-1]
    
    # add other parameters
    url += '&as_filetype=' + fileType
    url += '&imgsz=' + fileSize
    url += '&rsz=' + str(resultCount)
    request = urllib2.Request(url, None, {'Referer': referer})
    
    # open url
    try:
        log.debug('opening url: %s' % url)
        response = urllib2.urlopen(request, None, 10)
    except Exception, err:
        log.error('exception: ' + str(err))
        return imgUrls
    
    # load json response
    try:
        results = simplejson.load(response)
    except Exception, err:
        log.error('exception: ' + str(err))
        return imgUrls
    
    # add results to list
    if results:
        for result in results['responseData']['results']:
            imgUrls.append(result['url'])

    return imgUrls

def build_covername(coverFile, fileResults):
    '''returns cover name by key words'''
    
    covername = ''
    i = 1
    for key in coverFile['keys']:
        # change content if '/' is found
        new_content = fileResults[key].replace('/', '|')
        if not i == len(coverFile['keys']):
            covername += new_content+coverFile['delimiter']
        else:
            covername += new_content+'.'+coverFile['extension']
        i += 1
    
    return covername

def process_dir(thisDir, results=[], coverFile='', dirDepth=1):
    '''Recursively process sub-directories of given directory,
    gathering artist/album info per-directory.

    Call initially with empty results. Results will be
    gradually populated by recursive calls.'''

    dirs = []
    files = []
    global gDepth
    gDepth += 1
    
    # read directory contents
    if os.path.exists(thisDir): 
        try:
            for item in os.listdir(thisDir):
                itemFullPath=os.path.join(thisDir, item)
                if os.path.isdir(itemFullPath):
                    dirs.append(itemFullPath)
                else:
                    files.append(item)
        except OSError, err: 
            log.error(err)
            return results
    else:
        log.error('directory does not exist: %s' % (thisDir))
        return results
    
    # sort dirs and files to be processed in order
    dirs.sort()
    files.sort()
    
    if dirDepth > gDepth or dirDepth == 0:
        # recurse into subdirs
        for directory in dirs:
            results = process_dir(directory, results=results, coverFile=coverFile, dirDepth=dirDepth)
    
    # continue processing this dir once subdirs have been processed
    log.debug("evaluating " + thisDir)
    for filename in files:
        fileFullPath = os.path.join(thisDir, filename)
        
        # check file for id3 tag info
        result = process_file(fileFullPath, coverFile)
        if result == None:
            continue
        else:
            results.append(result)
    
    # no artist or album info found, return results unchanged
    return results

def process_file(filepath, coverFile=''):
    rc = None
    results={'thisDir':os.path.split(filepath)[0],
             'artist':'',
             'album':'',
             'title':'',
             'cover':''}
    filename = os.path.split(filepath)[1]
    data = ''
    
    # check file for id3 tag info
    try:
        id3e = mutagen.File(filepath, easy=True)
        id3f = mutagen.File(filepath)
        
        # not supported filetype
        if not id3e == None: 
            # mp3
            if 'audio/mp3' in id3e._mimes[0]:
                for key in id3f.tags:
                    if key.startswith("APIC:"):
                        results['cover'] = id3f.tags[key].desc
                        data = id3f.tags[key].data
                        break
            
            # flac
            elif 'audio/x-flac' in id3e._mimes[0]:
                if not id3f.pictures[0].desc == '':
                    results['cover'] = id3f.pictures[0].desc
                    data = id3f.pictures[0].data
            
            # ogg vorbis / ogg speex
            elif 'audio/vorbis' in id3e._mimes[0] or 'audio/x-speex' in id3e._mimes[0]:
                if 'COVERARTDESCRIPTION' in id3e.tags:
                    results['cover'] = id3e.tags['COVERARTDESCRIPTION'][0]
                    data = id3e.tags['COVERART'][0]
    
    except Exception, err:
        if str(err) == 'not a Musepack file':
            log.error('exception: not a Musepack file or version > 8')
        else:
            log.error('exception: ' + str(err))
        
        log.error("file '%s' will be ignored" % filename)
        return rc

    if not id3e == None: 
        # get values and sanitise nulls
        if 'artist' in id3e:
            results['artist'] = id3e['artist'][0]
        if 'album' in id3e:
            results['album'] = id3e['album'][0]
        if 'title' in id3e:
            results['title'] = id3e['title'][0]
    
    # if either artist or album or title found, append to results and return
    if results['artist'] or results['album'] or results['title'] or results['cover']:
        log.info("album details found in %s:\nartist: %s\nalbum: %s\ntitle: %s\nembedded cover: %s" % (filename, results['artist'], results['album'], results['title'], results['cover']))
        
        # build cover name
        covername = build_covername(coverFile, results)
        
        # check if covername contains delimiter and filetype only
        bad_name = coverFile['delimiter']+'.'+coverFile['extension']
        if not covername == bad_name:
            # check if cover not available already
            coverpath = os.path.join(results['thisDir'], covername)
            if not coverFile['externalDir'] == '':
                if not os.path.exists(coverpath):
                    coverpath = os.path.join(coverFile['externalDir'], covername)

            if not os.path.exists(coverpath):
                if results['cover'] == '':
                    rc = results
                
                # if embedded cover found save on disk
                else:
                    log.debug("embedded cover file saving as: %s" % covername)
                    if not coverFile['externalDir'] == '':
                        temppath = os.path.join(coverFile['externalDir'], results['cover'])
                    else:
                        temppath = os.path.join(results['thisDir'], results['cover'])
                    
                    fd = open(temppath, 'w')
                    fd.write(data)
                    fd.close()
                    
                    if coverFile['size'] == 'small':
                        size = '150'
                    elif coverFile['size'] == 'medium':
                        size = '300'
                    else:
                        size = '600'
                    
                    convert_rc = convert_cover(temppath, coverpath, size)
                    if convert_rc == False:
                        results['cover'] = ''
                        rc = results
                    else:
                        results['cover'] = covername
                    
                    os.remove(temppath)
            else:
                results['cover'] = covername
                rc = results
        else:
            results['cover'] = ''
    
#    if coverFile['printinfo'] == True:
#        print_file_info(results, coverFile['externalDir'])
#    else:
    return rc

def convert_cover(sourcepath, destpath, width):
    try:
        # fix problem with backtic in paths
        sourcepath = sourcepath.replace("`", "\`")
        destpath = destpath.replace("`", "\`")
        cmd = 'convert -resize '+width+' "'+sourcepath+'" "'+destpath+'"'
        retcode = subprocess.check_output([cmd], shell=True)
        return True
    except Exception as err:
        log.error('exception: ' + str(err))
        return False
        
def print_file_info(fileinfo, external_dir):
    '''print file info as a space separated string list 
    <artist> <album> <title> <coverpath>'''
    
    '''
    results={'thisDir':os.path.split(filepath)[0],
             'artist':'',
             'album':'',
             'title':'',
             'cover':''}
    '''
    if fileinfo == None:
        out_str = '"---" "---" "---" "---"'
    else:
        if fileinfo['artist'] == '':
            fileinfo['artist'] = '---'
        if fileinfo['album'] == '':
            fileinfo['album'] = '---'
        if fileinfo['title'] == '':
            fileinfo['title'] = '---'
        out_str = '"'+fileinfo['artist']+'" "'+fileinfo['album']+'" "'+fileinfo['title']+'" "'
        
        if not fileinfo['cover'] == '':
            if not external_dir == '':
                coverpath = os.path.join(external_dir, fileinfo['cover'])
            else:
                coverpath = os.path.join(fileinfo['thisDir'], fileinfo['cover'])
            out_str = out_str+coverpath+'"'
        else:
            out_str = out_str+'---"'
        
        out_str = out_str.encode("utf-8")

    print out_str
    sys.exit(0)
    
def parse_args_opts():
    '''parse command line argument and options'''

    googImgOpts = ["small", "medium", "large"]
    fileTypeOpts = ["jpg", "png", "gif"]
    parameters = {}

    parser = OptionParser()
    parser.add_option("-s", "--size", dest="size", action="store", default="medium", help="file size: small, medium, or large (default: medium)")
    parser.add_option("-i", "--image", dest="image", action="store", default="jpg", help="image format, eg jpg, png, gif (default: jpg)")
    parser.add_option("-n", "--name", dest="name", action="store", default="artist,album", help="cover image file name. Comma seperated key list. Keys: artist,album,title (default: artist,album)")
    parser.add_option("--delimiter", dest="delimiter", action="store", default="-", help="cover image file name delimiter (default: -)")
    parser.add_option("-r", "--referer", dest="referer", action="store", default=defaultReferer, help="referer url (default: %s)" % defaultReferer)
    parser.add_option("-c", "--count", dest="count", action="store", default="8", type="int", help="image lookup count (default: 8))")
    parser.add_option("-o", "--overwrite", dest="overwrite", action="store_true", default=False, help="overwrite (default False)")
    parser.add_option("-f", "--file", dest="file", action="store", default='', help="file to scan")
    parser.add_option("-d", "--directory", dest="dir", action="store", default='', help="directory to scan")
    parser.add_option("-x", "--extern", dest="external_dir", action="store", default='', help="external directory for covers")
    parser.add_option("--depth", dest="depth", action="store", default="1", type="int", help="directory depth to scan (default 1). 0 is unlimited")
    parser.add_option("--info", dest="info", action="store_true", default=False, help="get file info (default False)")
    parser.add_option("--debug", dest="debug", action="store_true", default=False, help="show debug (default False)")
    parser.add_option("--version", dest="version", action="store_true", default=False, help="show version")
    parser.set_usage("Usage: coverlovin.py [options]")
    (options, args) = parser.parse_args()

    # show version
    if options.version:
        print 'coverlovin V '+version
        sys.exit(0)
        
    # check if file OR directory is set
    if options.file == '' and options.dir == '':
        log.error("File or directory must be set")
        parser.print_help()
        sys.exit(2)
    else:
        if options.dir == '':
            parameters['musicDir'] = ''
            if not os.path.isfile(options.file):
                log.error(options.file + " is not a valid file")
                parser.print_help()
                sys.exit(2)
            else:
                parameters['musicFile'] = options.file
        else:
            parameters['musicFile'] = ''
            if not os.path.isdir(options.dir):
                log.error(options.dir + " is not a valid directory")
                parser.print_help()
                sys.exit(2)
            else:
                parameters['musicDir'] = options.dir

    # check external dir
    if not options.external_dir == '':
        if not os.path.isdir(options.external_dir):
            log.error(options.external_dir + " is not a valid directory")
            parser.print_help()
            sys.exit(2)
            
    # if '--info' set check if '-f' is set also
    if options.file == '' and options.info == True:
        log.error("option '--info' only usable with -f")
        parser.print_help()
        sys.exit(2)
    
    # set fileSize or bail if invalid
    if options.size in googImgOpts:
        parameters['fileSize'] = options.size
    else:
        log.error(options.size + " is not a valid size")
        parser.print_help()
        sys.exit(2)
    
    # check keyword list
    keylist = options.name.replace(' ','').split(',')
    rest = set(keylist) - set(['artist', 'album', 'title'])
    if not len(rest) == 0:
        log.error('wrong key(s) "%s" in cover name' % ', '.join(rest))
        parser.print_help()
        sys.exit(2)

    # set other variables
    parameters['printFileInfo'] = options.info
    parameters['fileType'] = options.image
    parameters['fileNameKeys'] = keylist
    parameters['delimiter'] = options.delimiter
    parameters['referer'] = options.referer
    parameters['resultCount'] = int(options.count)
    parameters['overWrite'] = options.overwrite
    parameters['dirDepth'] = int(options.depth)
    parameters['debug'] = options.debug
    parameters['externalDir'] = options.external_dir

    return parameters

def main():
    '''recursively download cover images for music files in a
    given directory and its sub-directories (--depth limits 
    directory scann depth) or for given file only.'''

    parameters = parse_args_opts()

    global gDepth
    gDepth = 0
    
    musicDir = ''
    musicFile = ''
    
    # allocate args/opts to vars, converting to utf-8
    if not parameters['musicDir'] == '':
        musicDir = unicode(parameters['musicDir'], 'utf-8')
    
    if not parameters['musicFile'] == '':
        musicFile = unicode(parameters['musicFile'], 'utf-8')

    fileType = unicode(parameters['fileType'], 'utf-8')
    fileNameKeys = parameters['fileNameKeys']
    fileNameDelimiter = unicode(parameters['delimiter'], 'utf-8')
    fileSize = unicode(parameters['fileSize'], 'utf-8')
    referer = unicode(parameters['referer'], 'utf-8')
    externalDir = unicode(parameters['externalDir'], 'utf-8')
    resultCount = parameters['resultCount']
    overWrite = parameters['overWrite']
    dirDepth = parameters['dirDepth']
    debug = parameters['debug']
    printInfo = parameters['printFileInfo']
    
    # set loglevel to debug
    if debug:
        log.setLevel(logging.DEBUG)
    
    coverFile = {'keys':fileNameKeys,
                 'delimiter':fileNameDelimiter,
                 'extension':fileType,
                 'size':fileSize,
                 'overwrite':overWrite,
                 'printinfo':printInfo,
                 'externalDir':externalDir}

    if not musicDir == '':
        '''
        gather list of dictionaries with this format:
        results={'thisDir':os.path.split(filepath)[0],
                 'artist':'',
                 'album':'',
                 'title':'',
                 'cover':''}
        '''
        musicDirs = process_dir(musicDir, coverFile=coverFile, dirDepth=dirDepth)
        # download covers
        for details in musicDirs:
            get_cover(details, coverFile, resultCount)
    else:
        details = process_file(musicFile, coverFile)
        if not details == None:
            get_cover(details, coverFile, resultCount)

        if coverFile['printinfo'] == True:
            print_file_info(details, coverFile['externalDir'])
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
