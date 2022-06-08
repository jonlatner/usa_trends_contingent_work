#To execute THIS file, you need to make sure that it has execute permissions
#To add execute type: chmod u+x usa_trends.sh
#Then to run it: ./usa_trends.sh	
#To verify, type: ls -l
#The first 4 letters of output for that file should be "-rwx"

#This file executes the following commands, which you could submit individually
#Here is a brief walk-through of the following lines of code:

#(1) Run latex on the document
#(2) Tell me how the job ended: 0=No Errors, 1+=Errors
#(3) Run bibtex on the document
#(4) Tell me how the job ended
#(5) Run latex on the document a second time
#(6) Tell me how the job ended
#(7) Run latex on the document a thrid time (not always necessary)
#(8) Tell me how the job ended
#(9-12) Delete those pesky files that latex automatically generates

#(2,4,6,8) are my preference for whether it all worked, can delete

pdflatex -interaction batchmode usa_trends.tex
echo "PDF1 =" $?

bibtex usa_trends
echo "BIB1 =" $?

pdflatex -interaction batchmode usa_trends.tex
echo "PDF2 =" $?

pdflatex -interaction batchmode usa_trends.tex
echo "PDF3 =" $?

rm *.aux
rm *.bbl
rm *.blg
rm *.log
rm *.out



