conf
==

how to work with this directy:

* jq is unable to deep-merge two json files
* we want to minimize the required packages for running this tool

for this reason there is a .HEAD and a .TAIL file in this directory

The json files from the subdirectories *master*/conf and *worker*/conf

Depending which image we are building, one of these files is concatenated into the middle,
between the HEAD and TAIL file.

You are responsible for keeping the syntax of these three files working.

