import os, shutil
from os import path

# loop through the entire internal tree
localRoot = os.getcwd()

# generate the index properly speaking
modelDir = "Curation"
outputDir = os.path.join(localRoot, "Executable Modules", "SBML_Qual_build")
fullPath_modelDir = os.path.join(localRoot, modelDir)

print(' > The output directory is: {0}' . format(outputDir))

# convert all files
for currentpath, folders, files in os.walk(fullPath_modelDir):
    for file in files:
        if '_stable.xml' in file:
            fullPath = os.path.join(currentpath, file)

            # convert both
            try:
                print(' > converting ' + file + ' ...', end = '')
                os.system('casq -s "' + fullPath + '"')
            except:
                print('(exception)')

            # move both output files to the respective folders (note: files are overwritten)
            fileName_sif = file[:-4] + '.sbml.sif'
            fileName_sbml = file[:-4] + '.sbml'
            file_sif = os.path.join(currentpath, fileName_sif)
            file_sbml = os.path.join(currentpath, fileName_sbml)
            if os.path.isfile(file_sif) and os.path.isfile(file_sbml):
                shutil.move(file_sif, os.path.join(outputDir, 'sif', fileName_sif))
                shutil.move(file_sbml, os.path.join(outputDir, 'sbml', fileName_sbml))
                print(' Done.')
