#!/usr/bin/env bash

function process_app {
  
  FILES=$(
    find ../$1 -type f -iname "*.pm"
  )

  # echo $app;
  # echo $FILES;

  # generate graph in .dot format (-z, -o)
  # without displaying class attributes (A)
  # without dispalying class methods (M)
  # silently (-S)
  autodia.pl -M -A -S -z -o $app.dot -i "$FILES" > /dev/null
  perl process_dot.pl $app.dot
}

APPS="
PosdaCuration
PhiFixer
ReviewPhi
CountGetter
SubmissionSender
GenericApp
";


for app in $APPS; do
  process_app $app;
done


