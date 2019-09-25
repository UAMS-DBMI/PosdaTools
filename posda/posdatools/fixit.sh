#!/bin/bash

FILE=$1

# fix methods
sed -i -E "s/(\s+|^)method\s+(\w+)\(([^):]+)\)\s*\{/\1sub \2 {\n  my (\$self, \3) = @_;/g" $FILE
sed -i -E "s/(\s+|^)method\s+(\w+)\((\\$\w+)\:\s*([^)]+)\)\s*\{/\1sub \2 {\n  my (\3, \4) = @_;/g" $FILE
sed -i -E "s/(\s+|^)method\s+(\w+)[^{]*\{/\1sub \2 {\n  my (\$self) = @_;/g" $FILE

# fix funcs
sed -i -E "s/\bfunc\s+(\w+)\(([^):]+)\)\s*\{/sub \1 {\n  my (\2) = @_;/g" $FILE
sed -i -E "s/\bfunc\s+(\w+)\((\\$\w+)\:\s*([^)]+)\)\s*\{/sub \1 {\n  my (\2, \3) = @_;/g" $FILE
sed -i -E "s/\bfunc\s+(\w+)[^{]*\{/sub \1 {/g" $FILE

# Fix anonymous funcs
sed -i -E "s/func\s*\(([^)]+)\)\s*\{/sub {\n  my (\1) = @_;/g" $FILE
sed -i -E "s/func\s*\(?\)?\s*\{/sub {/g" $FILE

sed -i -E "/Method::Signatures::Simple/d" $FILE
